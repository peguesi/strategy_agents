# Common Integration Patterns 🔗

> **Reusable integration patterns for connecting popular business tools with the Strategy Agents platform.**

This document provides tested integration patterns for the most commonly requested business tools. Each pattern includes configuration examples, workflow templates, and troubleshooting guidance.

## 📋 Table of Contents

1. [CRM Integrations](#crm-integrations)
2. [Project Management Tools](#project-management-tools)
3. [Communication Platforms](#communication-platforms)
4. [Financial & Accounting](#financial--accounting)
5. [Marketing & Analytics](#marketing--analytics)
6. [Development Tools](#development-tools)
7. [E-commerce Platforms](#e-commerce-platforms)
8. [Cloud Storage & Documents](#cloud-storage--documents)

---

## 🤝 CRM Integrations

### **HubSpot Integration Pattern**

#### **Configuration**
```python
# MCP Server Integration
class HubSpotMCP:
    def __init__(self):
        self.api_key = os.getenv("HUBSPOT_API_KEY")
        self.base_url = "https://api.hubapi.com"
        
    async def sync_contacts_to_linear(self):
        """Sync HubSpot contacts to Linear projects"""
        contacts = await self.get_hubspot_contacts()
        
        for contact in contacts:
            if contact.get("lifecyclestage") == "customer":
                await self.create_linear_project({
                    "name": f"Client: {contact['firstname']} {contact['lastname']}",
                    "description": f"Company: {contact.get('company', 'N/A')}",
                    "teamId": "client-projects-team-id"
                })
```

#### **n8n Workflow Template**
```json
{
  "name": "HubSpot to Linear Sync",
  "nodes": [
    {
      "parameters": {
        "resource": "contact",
        "operation": "getAll",
        "filters": {
          "property": "lifecyclestage",
          "operator": "EQ",
          "value": "customer"
        }
      },
      "type": "n8n-nodes-base.hubspot",
      "name": "Get HubSpot Customers"
    },
    {
      "parameters": {
        "url": "https://api.linear.app/graphql",
        "method": "POST",
        "headers": {
          "Authorization": "Bearer {{$env.LINEAR_API_KEY}}",
          "Content-Type": "application/json"
        },
        "body": {
          "query": "mutation ProjectCreate($input: ProjectCreateInput!) { projectCreate(input: $input) { project { id name } } }",
          "variables": {
            "input": {
              "name": "Client: {{$node['Get HubSpot Customers'].json['properties']['firstname']}} {{$node['Get HubSpot Customers'].json['properties']['lastname']}}",
              "teamId": "{{$env.LINEAR_TEAM_ID}}"
            }
          }
        }
      },
      "type": "n8n-nodes-base.httpRequest",
      "name": "Create Linear Project"
    }
  ]
}
```

---

### **Salesforce Integration Pattern**

#### **Configuration**
```python
class SalesforceMCP:
    def __init__(self):
        self.client_id = os.getenv("SALESFORCE_CLIENT_ID")
        self.client_secret = os.getenv("SALESFORCE_CLIENT_SECRET")
        self.username = os.getenv("SALESFORCE_USERNAME")
        self.password = os.getenv("SALESFORCE_PASSWORD")
        self.security_token = os.getenv("SALESFORCE_SECURITY_TOKEN")
        
    async def oauth_flow(self):
        """Handle Salesforce OAuth authentication"""
        auth_data = {
            "grant_type": "password",
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "username": self.username,
            "password": f"{self.password}{self.security_token}"
        }
        
        response = await self.http_client.post(
            "https://login.salesforce.com/services/oauth2/token",
            data=auth_data
        )
        
        return response.json()["access_token"]
```

#### **Environment Variables**
```bash
# Salesforce Configuration
SALESFORCE_CLIENT_ID=your_salesforce_app_client_id
SALESFORCE_CLIENT_SECRET=your_salesforce_app_client_secret
SALESFORCE_USERNAME=your_salesforce_username
SALESFORCE_PASSWORD=your_salesforce_password
SALESFORCE_SECURITY_TOKEN=your_salesforce_security_token
SALESFORCE_INSTANCE_URL=https://yourinstance.salesforce.com
```

---

## 📋 Project Management Tools

### **Asana Integration Pattern**

#### **Configuration**
```python
class AsanaMCP:
    def __init__(self):
        self.access_token = os.getenv("ASANA_ACCESS_TOKEN")
        self.base_url = "https://app.asana.com/api/1.0"
        
    async def sync_tasks_to_linear(self, project_id):
        """Sync Asana tasks to Linear issues"""
        tasks = await self.get_asana_tasks(project_id)
        
        for task in tasks:
            linear_issue = await self.create_linear_issue({
                "title": task["name"],
                "description": task.get("notes", ""),
                "teamId": os.getenv("LINEAR_TEAM_ID"),
                "assigneeId": await self.map_asana_user_to_linear(task.get("assignee")),
                "priority": self.map_asana_priority_to_linear(task.get("priority"))
            })
```

#### **Workflow Automation**
```json
{
  "name": "Asana Task Completion Notification",
  "trigger": {
    "type": "webhook",
    "url": "/asana-webhook",
    "events": ["task.completed"]
  },
  "steps": [
    {
      "action": "update_linear_issue",
      "status": "completed"
    },
    {
      "action": "notify_slack",
      "channel": "#project-updates",
      "message": "✅ Task completed: {{task.name}}"
    },
    {
      "action": "update_client_dashboard",
      "project_progress": "calculate_completion_percentage"
    }
  ]
}
```

---

### **Monday.com Integration Pattern**

#### **Configuration**
```python
class MondayMCP:
    def __init__(self):
        self.api_token = os.getenv("MONDAY_API_TOKEN")
        self.api_url = "https://api.monday.com/v2"
        
    async def get_board_items(self, board_id):
        """Fetch all items from a Monday.com board"""
        query = """
        query {
            boards(ids: [%s]) {
                items {
                    id
                    name
                    column_values {
                        id
                        text
                        value
                    }
                }
            }
        }
        """ % board_id
        
        response = await self.graphql_request(query)
        return response["data"]["boards"][0]["items"]
```

#### **Environment Variables**
```bash
# Monday.com Configuration
MONDAY_API_TOKEN=your_monday_api_token
MONDAY_ACCOUNT_ID=your_monday_account_id
MONDAY_WORKSPACE_ID=your_monday_workspace_id
```

---

## 💬 Communication Platforms

### **Microsoft Teams Integration Pattern**

#### **Webhook Configuration**
```python
class TeamsMCP:
    def __init__(self):
        self.webhook_url = os.getenv("TEAMS_WEBHOOK_URL")
        
    async def send_adaptive_card(self, title, message, facts=None, actions=None):
        """Send rich adaptive card to Teams channel"""
        card = {
            "type": "message",
            "attachments": [{
                "contentType": "application/vnd.microsoft.card.adaptive",
                "content": {
                    "type": "AdaptiveCard",
                    "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                    "version": "1.2",
                    "body": [
                        {
                            "type": "TextBlock",
                            "text": title,
                            "weight": "Bolder",
                            "size": "Medium"
                        },
                        {
                            "type": "TextBlock",
                            "text": message,
                            "wrap": True
                        }
                    ]
                }
            }]
        }
        
        if facts:
            fact_set = {
                "type": "FactSet",
                "facts": facts
            }
            card["attachments"][0]["content"]["body"].append(fact_set)
            
        await self.http_client.post(self.webhook_url, json=card)
```

#### **Usage Example**
```python
# Send project update to Teams
await teams_mcp.send_adaptive_card(
    title="Project Milestone Completed",
    message="The Q4 Marketing Campaign project has reached its next milestone.",
    facts=[
        {"title": "Project", "value": "Q4 Marketing Campaign"},
        {"title": "Completion", "value": "75%"},
        {"title": "Next Deadline", "value": "Dec 15, 2024"}
    ]
)
```

---

### **Discord Integration Pattern**

#### **Bot Configuration**
```python
class DiscordMCP:
    def __init__(self):
        self.bot_token = os.getenv("DISCORD_BOT_TOKEN")
        self.guild_id = os.getenv("DISCORD_GUILD_ID")
        
    async def send_embed_message(self, channel_id, title, description, fields=None):
        """Send rich embed message to Discord channel"""
        embed = {
            "title": title,
            "description": description,
            "color": 0x00ff00,  # Green color
            "timestamp": datetime.utcnow().isoformat()
        }
        
        if fields:
            embed["fields"] = fields
            
        await self.send_message(channel_id, {"embeds": [embed]})
```

---

## 💰 Financial & Accounting

### **QuickBooks Integration Pattern**

#### **OAuth Configuration**
```python
class QuickBooksMCP:
    def __init__(self):
        self.client_id = os.getenv("QUICKBOOKS_CLIENT_ID")
        self.client_secret = os.getenv("QUICKBOOKS_CLIENT_SECRET")
        self.redirect_uri = os.getenv("QUICKBOOKS_REDIRECT_URI")
        self.base_url = "https://sandbox-quickbooks.api.intuit.com"  # Use production URL for live
        
    async def create_invoice(self, customer_data, line_items):
        """Create invoice in QuickBooks"""
        invoice_data = {
            "Line": line_items,
            "CustomerRef": {
                "value": customer_data["id"]
            },
            "DueDate": (datetime.now() + timedelta(days=30)).strftime("%Y-%m-%d")
        }
        
        response = await self.qb_api_call("POST", "/v3/company/{}/invoice", invoice_data)
        return response["QueryResponse"]["Invoice"][0]
```

#### **Automated Invoicing Workflow**
```json
{
  "name": "Automated Invoice Generation",
  "trigger": "linear_project_milestone_completed",
  "conditions": {
    "milestone_has_payment": true,
    "client_billing_enabled": true
  },
  "steps": [
    {
      "action": "calculate_invoice_amount",
      "based_on": ["time_tracked", "milestone_value", "expenses"]
    },
    {
      "action": "create_quickbooks_invoice",
      "payment_terms": "net_30",
      "auto_send": true
    },
    {
      "action": "notify_client",
      "template": "invoice_sent_notification",
      "include_payment_link": true
    },
    {
      "action": "update_linear_project",
      "add_comment": "Invoice #{invoice_number} sent for ${amount}"
    }
  ]
}
```

---

### **Stripe Integration Pattern**

#### **Subscription Management**
```python
class StripeMCP:
    def __init__(self):
        self.api_key = os.getenv("STRIPE_API_KEY")
        stripe.api_key = self.api_key
        
    async def handle_subscription_event(self, event_type, event_data):
        """Handle Stripe subscription webhooks"""
        subscription = event_data["object"]
        
        handlers = {
            "customer.subscription.created": self.handle_new_subscription,
            "customer.subscription.updated": self.handle_subscription_update,
            "customer.subscription.deleted": self.handle_subscription_cancelled,
            "invoice.payment_failed": self.handle_payment_failure
        }
        
        if event_type in handlers:
            await handlers[event_type](subscription)
            
    async def handle_new_subscription(self, subscription):
        """Process new subscription signup"""
        # Create Linear project for new customer
        await self.create_linear_project({
            "name": f"Customer: {subscription['customer']}",
            "description": f"Subscription: {subscription['id']}",
            "teamId": "customer-success-team"
        })
        
        # Send welcome email
        await self.send_welcome_email(subscription["customer"])
```

---

## 📊 Marketing & Analytics

### **Google Analytics Integration Pattern**

#### **Configuration**
```python
class GoogleAnalyticsMCP:
    def __init__(self):
        self.credentials = service_account.Credentials.from_service_account_file(
            "path/to/service-account-key.json"
        )
        self.analytics = build("analyticsreporting", "v4", credentials=self.credentials)
        
    async def get_website_metrics(self, view_id, start_date, end_date):
        """Fetch website performance metrics"""
        request = {
            "reportRequests": [{
                "viewId": view_id,
                "dateRanges": [{"startDate": start_date, "endDate": end_date}],
                "metrics": [
                    {"expression": "ga:sessions"},
                    {"expression": "ga:users"},
                    {"expression": "ga:pageviews"},
                    {"expression": "ga:bounceRate"}
                ],
                "dimensions": [{"name": "ga:date"}]
            }]
        }
        
        response = self.analytics.reports().batchGet(body=request).execute()
        return self.parse_analytics_response(response)
```

#### **Automated Reporting Workflow**
```json
{
  "name": "Weekly Analytics Report",
  "trigger": "cron_monday_9am",
  "steps": [
    {
      "action": "fetch_google_analytics_data",
      "metrics": ["sessions", "users", "conversion_rate", "revenue"],
      "date_range": "last_7_days"
    },
    {
      "action": "fetch_social_media_metrics",
      "platforms": ["linkedin", "twitter", "facebook"]
    },
    {
      "action": "generate_insights_report",
      "template": "weekly_marketing_summary",
      "include_recommendations": true
    },
    {
      "action": "distribute_report",
      "recipients": ["marketing_team", "management"],
      "formats": ["email", "slack_summary"]
    }
  ]
}
```

---

### **Mailchimp Integration Pattern**

#### **Email Campaign Automation**
```python
class MailchimpMCP:
    def __init__(self):
        self.api_key = os.getenv("MAILCHIMP_API_KEY")
        self.server = self.api_key.split("-")[1]
        self.base_url = f"https://{self.server}.api.mailchimp.com/3.0"
        
    async def create_automated_campaign(self, list_id, template_id, trigger_event):
        """Create automated email campaign"""
        automation_data = {
            "recipients": {"list_id": list_id},
            "settings": {
                "title": f"Automated Campaign - {trigger_event}",
                "from_name": "Your Company",
                "reply_to": "noreply@yourcompany.com"
            },
            "trigger_settings": {
                "workflow_type": "emailSeries",
                "trigger_on_import": True
            }
        }
        
        response = await self.api_call("POST", "/automations", automation_data)
        return response["id"]
```

---

## 🛠️ Development Tools

### **GitHub Integration Pattern**

#### **Repository Management**
```python
class GitHubMCP:
    def __init__(self):
        self.token = os.getenv("GITHUB_TOKEN")
        self.headers = {
            "Authorization": f"token {self.token}",
            "Accept": "application/vnd.github.v3+json"
        }
        
    async def create_issue_from_linear(self, linear_issue):
        """Create GitHub issue from Linear issue"""
        issue_data = {
            "title": linear_issue["title"],
            "body": linear_issue["description"],
            "labels": self.map_linear_labels_to_github(linear_issue["labels"]),
            "assignees": [await self.map_linear_user_to_github(linear_issue["assignee"])]
        }
        
        response = await self.api_call(
            "POST", 
            f"/repos/{self.owner}/{self.repo}/issues", 
            issue_data
        )
        
        # Update Linear issue with GitHub issue URL
        await self.update_linear_issue(linear_issue["id"], {
            "description": f"{linear_issue['description']}\n\nGitHub Issue: {response['html_url']}"
        })
        
        return response
```

#### **CI/CD Integration Workflow**
```json
{
  "name": "Code Deployment Automation",
  "trigger": "github_push_to_main",
  "steps": [
    {
      "action": "run_automated_tests",
      "test_suites": ["unit", "integration", "e2e"]
    },
    {
      "action": "deploy_to_staging",
      "if": "all_tests_pass"
    },
    {
      "action": "notify_qa_team",
      "platform": "slack",
      "message": "New build ready for testing: {{build_url}}"
    },
    {
      "action": "create_linear_task",
      "title": "QA Testing - Build {{build_number}}",
      "assignee": "qa_lead",
      "due_date": "2_days_from_now"
    },
    {
      "action": "update_client_dashboard",
      "status": "new_features_in_testing"
    }
  ]
}
```

---

## 🛒 E-commerce Platforms

### **Shopify Integration Pattern**

#### **Order Processing Automation**
```python
class ShopifyMCP:
    def __init__(self):
        self.shop_name = os.getenv("SHOPIFY_SHOP_NAME")
        self.access_token = os.getenv("SHOPIFY_ACCESS_TOKEN")
        self.base_url = f"https://{self.shop_name}.myshopify.com/admin/api/2023-10"
        
    async def process_new_order(self, order_data):
        """Process new Shopify order"""
        # Create Linear task for order fulfillment
        await self.create_linear_task({
            "title": f"Order Fulfillment - #{order_data['order_number']}",
            "description": f"Customer: {order_data['customer']['name']}\nTotal: ${order_data['total_price']}",
            "teamId": "fulfillment-team",
            "priority": "medium"
        })
        
        # Check inventory levels
        await self.check_inventory_levels(order_data["line_items"])
        
        # Send order confirmation
        await self.send_order_confirmation(order_data)
```

#### **Inventory Management Workflow**
```json
{
  "name": "Inventory Reorder Automation",
  "trigger": "daily_inventory_check",
  "steps": [
    {
      "action": "check_inventory_levels",
      "threshold": "reorder_point"
    },
    {
      "action": "identify_low_stock_items",
      "criteria": "quantity < reorder_point"
    },
    {
      "action": "calculate_reorder_quantities",
      "based_on": ["sales_velocity", "lead_time", "safety_stock"]
    },
    {
      "action": "create_purchase_orders",
      "auto_send_to_suppliers": true
    },
    {
      "action": "update_linear_project",
      "project": "inventory_management",
      "add_tasks": "purchase_order_tracking"
    }
  ]
}
```

---

## ☁️ Cloud Storage & Documents

### **Google Workspace Integration Pattern**

#### **Document Automation**
```python
class GoogleWorkspaceMCP:
    def __init__(self):
        self.credentials = service_account.Credentials.from_service_account_file(
            "path/to/service-account-key.json",
            scopes=[
                "https://www.googleapis.com/auth/drive",
                "https://www.googleapis.com/auth/documents",
                "https://www.googleapis.com/auth/spreadsheets"
            ]
        )
        
    async def create_project_folder(self, project_name, client_name):
        """Create organized folder structure for new project"""
        drive_service = build("drive", "v3", credentials=self.credentials)
        
        # Create main project folder
        main_folder = await self.create_folder(f"{client_name} - {project_name}")
        
        # Create subfolders
        subfolders = ["Documents", "Designs", "Development", "Communication"]
        for subfolder in subfolders:
            await self.create_folder(subfolder, parent=main_folder["id"])
            
        return main_folder
```

#### **Document Generation Workflow**
```json
{
  "name": "Project Documentation Generator",
  "trigger": "linear_project_created",
  "steps": [
    {
      "action": "create_google_drive_folder",
      "structure": ["documents", "assets", "deliverables", "communication"]
    },
    {
      "action": "generate_project_documents",
      "templates": [
        "project_charter",
        "requirements_document", 
        "timeline_document",
        "communication_plan"
      ]
    },
    {
      "action": "create_shared_calendar",
      "include_milestones": true,
      "share_with": ["client_contact", "project_team"]
    },
    {
      "action": "send_project_welcome_package",
      "include_folder_links": true,
      "include_calendar_invite": true
    }
  ]
}
```

---

## 🔧 Integration Best Practices

### **Security Guidelines**
- Always use environment variables for API keys and secrets
- Implement proper error handling and retry logic
- Use OAuth where available instead of API keys
- Regularly rotate credentials and tokens
- Implement rate limiting to avoid API quota issues

### **Performance Optimization**
- Use webhooks instead of polling where possible
- Implement caching for frequently accessed data
- Use batch operations for bulk data processing
- Implement proper pagination for large datasets
- Monitor API usage and optimize calls

### **Error Handling Patterns**
```python
class IntegrationErrorHandler:
    def __init__(self):
        self.max_retries = 3
        self.retry_delay = 1.0
        
    async def with_retry(self, func, *args, **kwargs):
        """Execute function with exponential backoff retry"""
        for attempt in range(self.max_retries):
            try:
                return await func(*args, **kwargs)
            except (ConnectionError, TimeoutError, HTTPError) as e:
                if attempt == self.max_retries - 1:
                    raise e
                    
                wait_time = self.retry_delay * (2 ** attempt)
                await asyncio.sleep(wait_time)
                
        raise Exception("Max retries exceeded")
```

### **Data Synchronization**
```python
class DataSync:
    def __init__(self):
        self.sync_log = {}
        
    async def bidirectional_sync(self, source_system, target_system, mapping_config):
        """Perform bidirectional data synchronization"""
        # Get last sync timestamp
        last_sync = self.get_last_sync_time(source_system, target_system)
        
        # Sync changes from source to target
        source_changes = await source_system.get_changes_since(last_sync)
        for change in source_changes:
            mapped_data = self.map_data(change, mapping_config)
            await target_system.update_record(mapped_data)
            
        # Sync changes from target to source  
        target_changes = await target_system.get_changes_since(last_sync)
        for change in target_changes:
            mapped_data = self.map_data(change, mapping_config, reverse=True)
            await source_system.update_record(mapped_data)
            
        # Update sync timestamp
        self.update_last_sync_time(source_system, target_system)
```

---

**These integration patterns provide a solid foundation for connecting your Strategy Agents platform with virtually any business tool!** 🚀

---

*Strategy Agents Platform - Seamless integrations for powerful automation.*
