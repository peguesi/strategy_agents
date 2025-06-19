# Strategy Agents Linear Templates 📋

> **Generalized Linear workspace templates for different business types and strategic frameworks.**

This directory contains templates and examples for setting up Linear workspaces that align with the Strategy Agents platform. Each template is designed to be customized for specific business needs.

## 📁 Directory Structure

```
linear/
├── templates/                    # Reusable Linear setup templates
│   ├── consulting-agency.js      # Client service business template
│   ├── saas-business.js          # Product development template  
│   ├── freelancer-solo.js        # Individual contributor template
│   └── general-business.js       # Generic business template
├── examples/                     # Real-world implementation examples
│   ├── revenue-tracking/         # Revenue-focused project structures
│   ├── client-delivery/          # Client work organization
│   └── product-development/      # Product-focused workflows
└── scripts/                      # Utility scripts
    ├── setup-workspace.js        # Automated workspace setup
    └── migrate-labels.js          # Label system migration
```

## 🎯 Strategic Framework Components

### **Revenue Priority Labels**
All templates include the core revenue prioritization system:
- **High Revenue**: Direct revenue-generating work
- **Medium Revenue**: Framework and efficiency improvements  
- **Low Revenue**: Research, maintenance, documentation

### **Work Type Classifications**
- **Client Work**: Direct client deliverables
- **Strategy**: Planning and framework development
- **Implementation**: Building and deployment
- **Research**: Investigation and learning

### **Effort Estimation**
- **XS** (1-2 hours): Quick wins and small tasks
- **S** (3-8 hours): Short-term focused work
- **M** (1-3 days): Medium complexity projects
- **L** (1-2 weeks): Large implementations
- **XL** (3+ weeks): Major initiatives

## 🏗️ Template Usage

### **Step 1: Choose Your Template**
Select the template that best matches your business type:
- `consulting-agency.js` - Client service businesses
- `saas-business.js` - Product development companies
- `freelancer-solo.js` - Individual contributors
- `general-business.js` - Flexible starting point

### **Step 2: Customize Configuration**
Edit the template variables at the top:
```javascript
// Business Configuration
const BUSINESS_CONFIG = {
  name: "Your Business Name",
  revenueTarget: 100000,  // Annual revenue goal
  currency: "USD",        // USD, EUR, GBP, etc.
  teamSize: 5,           // Number of team members
  clientType: "B2B"     // B2B, B2C, Mixed
};
```

### **Step 3: Run Setup Script**
```bash
# Set your Linear API key
export LINEAR_API_KEY="your_linear_api_key"

# Run the template setup
node linear/templates/consulting-agency.js
```

### **Step 4: Validate Setup**
The script will create:
- Strategic initiative aligned with your revenue goal
- Project structure for your business type
- Comprehensive label system
- Sample issues with proper categorization

## 📋 Core Templates

### **Consulting Agency Template**
Perfect for client service businesses:
- **Client Acquisition Project**: Proposal and contract management
- **Service Delivery Project**: Client work execution
- **Framework Development Project**: Reusable methodologies
- **Business Development Project**: Growth and optimization

### **SaaS Business Template**
Designed for product companies:
- **Product Development Project**: Feature development and releases
- **Customer Success Project**: User onboarding and retention
- **Marketing & Growth Project**: Acquisition and conversion
- **Operations Project**: Infrastructure and optimization

### **Freelancer Template**
Optimized for individual contributors:
- **Client Projects**: Individual client deliverables
- **Business Development**: Lead generation and proposals
- **Skill Development**: Learning and capability building
- **Operations**: Administrative and business tasks

## 🎯 Strategic Implementation

### **Revenue Tracking Integration**
Each template includes:
- Revenue impact labeling for all work
- Progress tracking toward annual goals
- Client lifetime value monitoring
- Profitability analysis by project type

### **Productivity Optimization**
Templates support:
- Time estimation accuracy improvement
- Work pattern analysis through labeling
- Bottleneck identification and resolution
- Capacity planning and resource allocation

### **Business Growth Patterns**
Built-in scaling considerations:
- Team growth from solo to small team to enterprise
- Revenue tier progression (startup → growth → scale)
- Client complexity evolution (simple → complex projects)
- Service offering expansion (core → premium → enterprise)

## 🔧 Customization Guidelines

### **Adding Industry-Specific Elements**
```javascript
// Example: Legal Services Customization
const LEGAL_SPECIFIC_LABELS = [
  "Case Management",
  "Client Communication", 
  "Legal Research",
  "Court Filings",
  "Billing & Time Tracking"
];

// Example: E-commerce Customization  
const ECOMMERCE_SPECIFIC_PROJECTS = [
  "Inventory Management",
  "Customer Service",
  "Marketing Campaigns", 
  "Platform Development"
];
```

### **Regional/Currency Adaptations**
```javascript
// European Business Configuration
const EU_CONFIG = {
  currency: "EUR",
  vatRate: 0.21,
  workingHours: 37.5,  // per week
  holidayDays: 25      // annual
};

// US Business Configuration
const US_CONFIG = {
  currency: "USD", 
  salesTaxRate: 0.08,
  workingHours: 40,
  holidayDays: 15
};
```

## 🚀 Advanced Features

### **Automated Reporting**
Templates include setup for:
- Weekly progress reports
- Monthly revenue analysis
- Quarterly strategic reviews
- Annual goal assessment

### **Integration Hooks**
Pre-configured for Strategy Agents platform:
- n8n workflow triggers
- Screenpipe behavioral analysis
- Claude Desktop MCP integration
- External tool synchronization

### **Performance Monitoring**
Built-in metrics tracking:
- Issue completion velocity
- Revenue per hour calculations
- Client satisfaction indicators
- Team productivity measurements

## 📚 Usage Examples

### **Quick Start Example**
```bash
# 1. Clone template
cp linear/templates/general-business.js my-business-setup.js

# 2. Edit configuration
vim my-business-setup.js  # Update BUSINESS_CONFIG

# 3. Run setup
node my-business-setup.js

# 4. Verify in Linear
# Check your Linear workspace for new projects and labels
```

### **Custom Business Type**
```javascript
// Create custom template for your specific needs
const CUSTOM_BUSINESS_CONFIG = {
  name: "Digital Marketing Agency",
  projects: [
    "Client Campaign Management",
    "Content Creation Pipeline", 
    "Analytics & Reporting",
    "Business Development"
  ],
  labels: [
    "Campaign Work", "Content Creation", 
    "Client Communication", "Strategy Development"
  ],
  revenueModel: "project_based",
  averageProjectValue: 15000
};
```

## 🔗 Integration with Strategy Agents

These Linear templates are designed to work seamlessly with:
- **n8n workflows** for automation
- **Screenpipe analysis** for productivity insights
- **Claude Desktop** for strategic guidance
- **Revenue tracking** for business growth

Each template creates the foundation for a complete strategic automation platform tailored to your specific business needs.

---

*Linear Templates - Strategic project management for any business type.*
