# Consulting Agency Configuration Example 💼

> **Complete Strategy Agents setup for a digital marketing consulting agency with 5-person team targeting $500k annual revenue.**

## Business Profile

- **Industry**: Digital Marketing Consulting
- **Team Size**: 5 people (2 consultants, 1 project manager, 1 designer, 1 developer)
- **Current Revenue**: $300k annually
- **Target Revenue**: $500k annually (67% increase)
- **Revenue Model**: Project-based + monthly retainers
- **Average Project Value**: $15k
- **Monthly Retainer Range**: $3k-$8k

## Current Challenges

1. **Project Management Chaos**: Multiple tools, inconsistent processes, missed deadlines
2. **Client Communication Gaps**: Manual updates, delayed responses, unclear expectations
3. **Resource Planning Issues**: Overbooking, underutilization, unclear capacity
4. **Revenue Tracking Problems**: Manual invoicing, delayed billing, cash flow issues

## Tool Stack Integration

### **Primary Tools (Must-Have)**
- **Linear**: Project management and task tracking ✅
- **Slack**: Team communication ✅
- **HubSpot**: CRM and lead management
- **Harvest**: Time tracking and project billing
- **QuickBooks**: Accounting and financial management

### **Secondary Tools (Nice-to-Have)**
- **Google Workspace**: Document collaboration
- **Figma**: Design collaboration and client approval
- **GitHub**: Code repository and version control
- **Calendly**: Meeting scheduling automation

## Environment Configuration

### **Required Environment Variables**
```bash
# Linear Configuration
LINEAR_API_KEY=lin_api_xxxxxxxxxxxxxxxx
LINEAR_TEAM_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# HubSpot Integration  
HUBSPOT_API_KEY=pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
HUBSPOT_PORTAL_ID=xxxxxxxx

# Harvest Time Tracking
HARVEST_ACCOUNT_ID=xxxxxxxx
HARVEST_ACCESS_TOKEN=xxxxxxxx.pt.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# QuickBooks Integration
QUICKBOOKS_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
QUICKBOOKS_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
QUICKBOOKS_REDIRECT_URI=https://yourapp.com/callback

# Slack Integration
SLACK_BOT_TOKEN=xoxb-xxxxxxxxx-xxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@company.com
SMTP_PASSWORD=your-app-password

# Azure OpenAI (for AI analysis)
AZURE_OPENAI_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-4
```

## Workflow Configurations

### **1. New Client Onboarding Workflow**

```json
{
  "name": "Client Onboarding - Digital Agency",
  "trigger": "hubspot_deal_won",
  "steps": [
    {
      "action": "create_linear_project",
      "template": "digital_marketing_campaign",
      "assign_team": "auto_based_on_skills"
    },
    {
      "action": "create_slack_channel",
      "naming": "client-{company_name}",
      "invite": ["project_manager", "assigned_team"]
    },
    {
      "action": "create_harvest_project", 
      "budget": "from_hubspot_deal_amount",
      "hourly_rates": "team_member_rates"
    },
    {
      "action": "send_welcome_package",
      "template": "agency_welcome_email",
      "attachments": ["project_timeline", "team_intro", "communication_guide"]
    },
    {
      "action": "schedule_kickoff_meeting",
      "participants": ["client_contact", "project_manager"],
      "duration": 60,
      "agenda": "project_kickoff_template"
    }
  ]
}
```

### **2. Weekly Project Status Automation**

```json
{
  "name": "Weekly Project Status Reports",
  "trigger": "cron_friday_4pm",
  "steps": [
    {
      "action": "gather_project_data",
      "sources": ["linear_progress", "harvest_time_logs", "slack_activity"]
    },
    {
      "action": "calculate_metrics",
      "formulas": {
        "progress_percentage": "completed_tasks / total_tasks * 100",
        "budget_utilization": "logged_hours * hourly_rate / project_budget * 100",
        "timeline_status": "current_date vs planned_timeline"
      }
    },
    {
      "action": "generate_client_report",
      "template": "weekly_status_template",
      "include": ["progress_summary", "upcoming_milestones", "budget_status", "next_steps"]
    },
    {
      "action": "send_to_client",
      "method": "email",
      "cc": ["project_manager", "account_manager"]
    },
    {
      "action": "post_to_slack",
      "channel": "#{client_channel}",
      "message": "Weekly report sent to client ✅"
    }
  ]
}
```

## Expected ROI

### **Time Savings**
- **Project Management**: 10 hours/week → 3 hours/week (70% reduction)
- **Client Communication**: 8 hours/week → 2 hours/week (75% reduction)
- **Administrative Tasks**: 15 hours/week → 5 hours/week (67% reduction)
- **Reporting & Analytics**: 6 hours/week → 1 hour/week (83% reduction)

**Total Time Savings**: 31 hours/week × $125/hour = $3,875/week = $201,500/year

### **Revenue Impact**
- **Improved Utilization**: 75% → 85% = $40k additional annual revenue
- **Faster Project Delivery**: 20% faster = 20% more capacity = $100k additional
- **Better Client Retention**: 80% → 90% = $50k additional recurring revenue
- **Upsell Automation**: 25% → 40% success rate = $75k additional revenue

**Total Revenue Impact**: $265k additional annual revenue

**Net ROI**: 1,220% ROI

---

*Strategy Agents Platform - Transforming digital agencies through intelligent automation.*
