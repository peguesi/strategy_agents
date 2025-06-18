#!/usr/bin/env python3
"""
Smart Screenpipe Menu Bar Controller
Controls audio recording and shows visual status
Enhanced for Strategy Agents setup
"""

import rumps
import subprocess
import requests
import json
import time
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
import webbrowser

# Add parent directory to path for imports
sys.path.append(str(Path(__file__).parent.parent))

def find_screenpipe_binary():
    """Find the screenpipe executable in common locations"""
    possible_paths = [
        "/Users/zeh/.local/bin/screenpipe",
        "/usr/local/bin/screenpipe",
        os.path.expanduser("~/.cargo/bin/screenpipe"),
        "/opt/homebrew/bin/screenpipe",
        "/Users/zeh/Local_Projects/screenpipe/target/release/screenpipe",
    ]
    
    # Also check if it's in PATH
    try:
        result = subprocess.run(["which", "screenpipe"], capture_output=True, text=True)
        if result.returncode == 0 and result.stdout.strip():
            possible_paths.insert(0, result.stdout.strip())
    except:
        pass
    
    for path in possible_paths:
        if os.path.isfile(path) and os.access(path, os.X_OK):
            return path
    
    return None

# Find screenpipe binary at module level
SCREENPIPE_BIN = find_screenpipe_binary()
if not SCREENPIPE_BIN:
    print("WARNING: Could not find screenpipe binary!")
    SCREENPIPE_BIN = "screenpipe"  # Fallback to PATH

class ScreenpipeController(rumps.App):
    def __init__(self):
        super(ScreenpipeController, self).__init__("🔍", quit_button=None)
        
        self.recording_state = "unknown"  # unknown, full, video_only, disabled
        
        # Define paths relative to this setup
        self.base_path = Path(__file__).parent.parent
        self.data_path = self.base_path / "data"
        self.logs_path = self.base_path / "logs"
        self.config_path = self.base_path / "config"
        
        # Ensure directories exist
        self.data_path.mkdir(exist_ok=True)
        self.logs_path.mkdir(exist_ok=True)
        self.config_path.mkdir(exist_ok=True)
        
        # Set up menu
        self.menu = [
            "📊 Status & Control",
            None,  # Separator
            "🎤 Enable Full Recording (Video + Audio)",
            "📹 Video Only Recording", 
            "⏸️ Pause All Recording",
            None,
            "🔍 Quick Search",
            "📱 Open Web Interface",
            "📤 Export Today's Data",
            "🛠️ Open Data Folder",
            "📋 View Logs",
            None,
            "❌ Quit"
        ]
        
        # Check status every 15 seconds
        self.timer = rumps.Timer(self.update_status, 15)
        self.timer.start()
        self.update_status(None)
        
        self.log("Menu bar controller started")
        self.log(f"Using screenpipe binary: {SCREENPIPE_BIN}")
    
    def log(self, message):
        """Log to our dedicated log file"""
        log_file = self.logs_path / "menubar.log"
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(log_file, "a") as f:
            f.write(f"[{timestamp}] {message}\n")
    
    def get_screenpipe_status(self):
        """Get current Screenpipe status"""
        try:
            response = requests.get("http://localhost:3030/health", timeout=3)
            return response.json() if response.status_code == 200 else None
        except:
            return None
    
    def check_audio_recording(self):
        """Check if audio is currently being recorded"""
        try:
            # Check if we have recent audio data (last 2 minutes)
            two_min_ago = (datetime.now() - timedelta(minutes=2)).isoformat() + "Z"
            response = requests.get(
                "http://localhost:3030/search", 
                params={"content_type": "audio", "start_time": two_min_ago, "limit": 1},
                timeout=3
            )
            
            if response.status_code == 200:
                data = response.json()
                return len(data.get("data", [])) > 0
            return False
        except:
            return False
    
    def update_status(self, timer):
        """Update menu bar icon based on recording status"""
        status_data = self.get_screenpipe_status()
        
        if not status_data:
            self.title = "🔍❌"  # Screenpipe not running
            self.recording_state = "disabled"
            return
        
        # Check if healthy or degraded
        status = status_data.get("status", "unknown")
        audio_status = status_data.get("audio_status", "unknown")
        frame_status = status_data.get("frame_status", "unknown")
        
        if frame_status != "ok":
            self.title = "🔍🔴"  # Error state
            self.recording_state = "disabled"
        elif audio_status in ["ok", "running"]:
            self.title = "🎤🟢"  # Full recording (video + audio)
            self.recording_state = "full"
        elif audio_status in ["disabled", "not_started"]:
            self.title = "📹🟡"  # Video only
            self.recording_state = "video_only"
        else:
            self.title = "🔍🟡"  # Degraded but working
            self.recording_state = "video_only"
    
    def restart_screenpipe_with_audio(self, enable_audio=True):
        """Restart Screenpipe with or without audio using our data directory"""
        try:
            # Kill existing Screenpipe processes
            subprocess.run(["pkill", "-f", SCREENPIPE_BIN], capture_output=True)
            time.sleep(2)  # Wait for cleanup
            
            # Also kill by port just to be sure
            subprocess.run(["lsof", "-ti", ":3030", "|" "xargs", "kill", "-9"], shell=True, capture_output=True)
            time.sleep(1)
            
            # Start with appropriate settings pointing to our data directory
            cmd = [
                SCREENPIPE_BIN, 
                "--port", "3030",
                "--data-dir", str(self.data_path)
            ]
            if not enable_audio:
                cmd.append("--disable-audio")
            
            # Start in background and log to our logs directory
            log_file = self.logs_path / "screenpipe.log"
            error_file = self.logs_path / "screenpipe_stderr.log"
            with open(log_file, "a") as out, open(error_file, "a") as err:
                subprocess.Popen(cmd, stdout=out, stderr=err)
            
            # Wait a moment for startup
            time.sleep(5)  # Give it more time to start
            
            # Verify it started
            if self.get_screenpipe_status():
                mode = "Full Recording" if enable_audio else "Video Only"
                rumps.notification("Screenpipe", f"Switched to {mode}", "")
                self.log(f"Screenpipe started: {mode}")
                self.update_status(None)
                return True
            else:
                rumps.alert("Error", "Failed to restart Screenpipe")
                self.log("ERROR: Failed to restart Screenpipe")
                return False
                
        except Exception as e:
            rumps.alert("Error", f"Failed to control Screenpipe:\n{str(e)}")
            self.log(f"ERROR: {str(e)}")
            return False
    
    def stop_screenpipe(self):
        """Stop all Screenpipe recording"""
        try:
            subprocess.run(["pkill", "-f", SCREENPIPE_BIN], capture_output=True)
            rumps.notification("Screenpipe", "Recording Paused", "")
            self.title = "🔍⏸️"
            self.recording_state = "disabled"
            self.log("Screenpipe stopped")
            return True
        except Exception as e:
            rumps.alert("Error", f"Failed to stop Screenpipe:\n{str(e)}")
            self.log(f"ERROR stopping: {str(e)}")
            return False
    
    @rumps.clicked("📊 Status & Control")
    def show_status(self, _):
        status_data = self.get_screenpipe_status()
        
        if not status_data:
            rumps.alert("Screenpipe Status", "❌ Not Running\n\nUse menu options to start recording.")
            return
        
        # Get recording stats
        try:
            search_response = requests.get("http://localhost:3030/search?limit=1", timeout=3)
            total_entries = "Unknown"
            if search_response.status_code == 200:
                search_data = search_response.json()
                total_entries = search_data.get("pagination", {}).get("total", "Unknown")
        except:
            total_entries = "Unknown"
        
        # Get data directory size
        data_size = "Unknown"
        try:
            total_size = sum(f.stat().st_size for f in self.data_path.rglob('*') if f.is_file())
            data_size = f"{total_size / (1024**3):.2f} GB"
        except:
            pass
        
        # Format status
        status_icon = {
            "full": "🎤🟢 Full Recording (Video + Audio)",
            "video_only": "📹🟡 Video Only Recording", 
            "disabled": "⏸️ Recording Paused"
        }.get(self.recording_state, "❓ Unknown State")
        
        status_text = f"""{status_icon}

Health: {status_data.get('status', 'Unknown')}
Total Entries: {total_entries}
Data Size: {data_size}

Frame Status: {status_data.get('frame_status', 'Unknown')}
Audio Status: {status_data.get('audio_status', 'Unknown')}

Last Frame: {status_data.get('last_frame_timestamp', 'None')}
Last Audio: {status_data.get('last_audio_timestamp', 'None')}

Data Directory: {self.data_path}"""
        
        rumps.alert("Screenpipe Status", status_text)
    
    @rumps.clicked("🎤 Enable Full Recording (Video + Audio)")
    def enable_full_recording(self, _):
        if self.recording_state == "full":
            rumps.alert("Already Active", "Full recording is already enabled!")
            return
        
        self.restart_screenpipe_with_audio(enable_audio=True)
    
    @rumps.clicked("📹 Video Only Recording")
    def enable_video_only(self, _):
        if self.recording_state == "video_only":
            rumps.alert("Already Active", "Video-only recording is already enabled!")
            return
            
        self.restart_screenpipe_with_audio(enable_audio=False)
    
    @rumps.clicked("⏸️ Pause All Recording")
    def pause_recording(self, _):
        if self.recording_state == "disabled":
            rumps.alert("Already Paused", "Recording is already paused!")
            return
            
        self.stop_screenpipe()
    
    @rumps.clicked("🔍 Quick Search")
    def quick_search(self, _):
        if not self.get_screenpipe_status():
            rumps.alert("Error", "Screenpipe is not running!")
            return
            
        response = rumps.Window(
            title="Search Screenpipe",
            message="Enter search terms:",
            default_text="",
            ok="Search",
            cancel="Cancel",
            dimensions=(250, 20)
        ).run()
        
        if response.clicked and response.text:
            self.perform_search(response.text)
    
    def perform_search(self, search_term):
        """Perform search and show results"""
        try:
            response = requests.get(
                "http://localhost:3030/search",
                params={"q": search_term, "limit": 10},
                timeout=5
            )
            
            if response.status_code == 200:
                data = response.json()
                results = data.get("data", [])
                
                if results:
                    result_text = f"Found {len(results)} results for '{search_term}':\n\n"
                    
                    for i, result in enumerate(results[:5], 1):
                        timestamp = result.get("timestamp", "")
                        content = result.get("content", "")[:80]
                        content_type = result.get("content_type", "")
                        type_icon = "🎤" if content_type == "audio" else "📹"
                        
                        # Format timestamp
                        try:
                            dt = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
                            time_str = dt.strftime("%m/%d %H:%M")
                        except:
                            time_str = timestamp[:16]
                        
                        result_text += f"{i}. {type_icon} {time_str}\n   {content}...\n\n"
                    
                    if len(results) > 5:
                        result_text += f"... and {len(results) - 5} more results"
                    
                    rumps.alert("Search Results", result_text)
                else:
                    rumps.alert("No Results", f"No results found for '{search_term}'")
            else:
                rumps.alert("Error", f"Search failed: {response.status_code}")
                
        except Exception as e:
            rumps.alert("Error", f"Search failed:\n{str(e)}")
    
    @rumps.clicked("📱 Open Web Interface")
    def open_web_interface(self, _):
        if not self.get_screenpipe_status():
            rumps.alert("Error", "Screenpipe is not running!")
            return
        webbrowser.open("http://localhost:3030")
    
    @rumps.clicked("📤 Export Today's Data")
    def export_today(self, _):
        if not self.get_screenpipe_status():
            rumps.alert("Error", "Screenpipe is not running!")
            return
            
        try:
            today = datetime.now().strftime("%Y-%m-%d")
            start_time = f"{today}T00:00:00Z"
            
            response = requests.get(
                "http://localhost:3030/search",
                params={"start_time": start_time, "limit": 1000},
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                filename = f"screenpipe_{today}.json"
                
                # Save to our data directory
                filepath = self.data_path / filename
                
                with open(filepath, 'w') as f:
                    json.dump(data, f, indent=2)
                
                entries_count = len(data.get("data", []))
                rumps.notification(
                    "Export Complete",
                    f"Exported {entries_count} entries",
                    f"Saved to {filepath}"
                )
                self.log(f"Exported {entries_count} entries to {filepath}")
            else:
                rumps.alert("Error", f"Export failed: {response.status_code}")
                
        except Exception as e:
            rumps.alert("Error", f"Export failed:\n{str(e)}")
            self.log(f"ERROR exporting: {str(e)}")
    
    @rumps.clicked("🛠️ Open Data Folder")
    def open_data_folder(self, _):
        subprocess.run(["open", str(self.data_path)])
    
    @rumps.clicked("📋 View Logs")
    def view_logs(self, _):
        subprocess.run(["open", str(self.logs_path)])
    
    @rumps.clicked("❌ Quit")
    def quit_app(self, _):
        self.log("Menu bar controller stopping")
        rumps.quit_application()

if __name__ == "__main__":
    app = ScreenpipeController()
    app.run()
