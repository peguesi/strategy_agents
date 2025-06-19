// Generalized Linear Business Setup Template
// Adaptable framework for any business type with strategic revenue focus

// Load environment variables
require('dotenv').config({ path: '../../.env' });

const LINEAR_API_KEY = process.env.LINEAR_API_KEY;
const LINEAR_API_URL = process.env.LINEAR_API_URL || "https://api.linear.app/graphql";

if (!LINEAR_API_KEY) {
  console.error('❌ Error: LINEAR_API_KEY environment variable is required');
  console.error('Please set it in your .env file or export it:');
  console.error('export LINEAR_API_KEY="your_api_key_here"');
  process.exit(1);
}

// ========================================
// BUSINESS CONFIGURATION
// ========================================
// Customize these values for your specific business

const BUSINESS_CONFIG = {
  // Core Business Information
  name: "Your Business Name",
  industry: "Professional Services",  // Consulting, SaaS, E-commerce, etc.
  
  // Financial Goals
  annualRevenueTarget: 150000,  // Your revenue goal
  currency: "USD",              // USD, EUR, GBP, etc.
  
  // Team Structure
  teamSize: 1,                  // Current team size
  growthStage: "startup",       // startup, growth, scale, enterprise
  
  // Revenue Model
  revenueModel: "project_based", // subscription, project_based, hourly, mixed
  averageProjectValue: 15000,    // Average project/contract value
  
  // Strategic Focus
  primaryObjective: "revenue_growth",  // revenue_growth, market_expansion, efficiency
  timeframe: "quarterly"               // monthly, quarterly, annual
};

// ========================================
// STRATEGIC FRAMEWORK CONFIGURATION
// ========================================

const STRATEGIC_FRAMEWORK = {
  // Core Initiative
  initiative: {
    name: `${BUSINESS_CONFIG.name} Growth Initiative`,
    description: `Strategic ${BUSINESS_CONFIG.currency} ${BUSINESS_CONFIG.annualRevenueTarget.toLocaleString()} revenue target through systematic business automation and optimization. Focus on ${BUSINESS_CONFIG.revenueModel} model with ${BUSINESS_CONFIG.teamSize} person team.`,
    targetDate: "2025-12-31"
  },
  
  // Core Projects (Adaptable to any business)
  projects: [
    {
      name: "Revenue Generation",
      description: "Direct revenue-generating activities including client acquisition, sales, and core service delivery.",
      focus: "high_revenue"
    },
    {
      name: "Business Development", 
      description: "Strategic growth activities including process improvement, tool optimization, and capability building.",
      focus: "medium_revenue"
    },
    {
      name: "Operations & Infrastructure",
      description: "Foundation building including systems setup, documentation, and administrative optimization.",
      focus: "low_revenue"
    },
    {
      name: "Strategic Planning",
      description: "Long-term planning, market analysis, and strategic decision-making activities.",
      focus: "medium_revenue"
    }
  ],
  
  // Universal Label System
  labels: {
    // Revenue Impact Labels
    revenue: [
      { name: "High Revenue", color: "#22c55e", description: "Direct revenue-generating work" },
      { name: "Medium Revenue", color: "#eab308", description: "Efficiency and framework improvements" },
      { name: "Low Revenue", color: "#64748b", description: "Foundation and maintenance work" }
    ],
    
    // Work Type Labels
    workType: [
      { name: "Client Work", color: "#3b82f6", description: "Direct client deliverables" },
      { name: "Strategy", color: "#8b5cf6", description: "Planning and framework development" },
      { name: "Implementation", color: "#06b6d4", description: "Building and deployment" },
      { name: "Research", color: "#f59e0b", description: "Investigation and learning" }
    ],
    
    // Effort Estimation Labels
    effort: [
      { name: "XS", color: "#10b981", description: "1-2 hours: Quick wins" },
      { name: "S", color: "#059669", description: "3-8 hours: Short-term work" },
      { name: "M", color: "#0891b2", description: "1-3 days: Medium complexity" },
      { name: "L", color: "#0369a1", description: "1-2 weeks: Large projects" },
      { name: "XL", color: "#1e40af", description: "3+ weeks: Major initiatives" }
    ],
    
    // Priority Labels
    priority: [
      { name: "Urgent", color: "#dc2626", description: "Immediate attention required" },
      { name: "High Priority", color: "#ea580c", description: "Important, schedule soon" },
      { name: "Medium Priority", color: "#ca8a04", description: "Normal scheduling" },
      { name: "Low Priority", color: "#65a30d", description: "Can be delayed" }
    ],
    
    // Business Context Labels (Customizable)
    context: [
      { name: "Quick-Win", color: "#16a34a", description: "Easy implementation, high impact" },
      { name: "Deep-Work", color: "#9333ea", description: "Requires focused concentration" },
      { name: "Collaboration", color: "#0284c7", description: "Involves team coordination" },
      { name: "Learning", color: "#7c3aed", description: "Skill development component" }
    ]
  }
};

// ========================================
// GRAPHQL UTILITIES
// ========================================

async function makeLinearRequest(query, variables = {}) {
  const response = await fetch(LINEAR_API_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': LINEAR_API_KEY
    },
    body: JSON.stringify({ query, variables })
  });
  
  const result = await response.json();
  if (result.errors) {
    throw new Error(`Linear API Error: ${JSON.stringify(result.errors)}`);
  }
  return result.data;
}

// ========================================
// CORE SETUP FUNCTIONS
// ========================================

async function getOrCreateTeam() {
  const query = `
    query GetTeams {
      teams {
        nodes {
          id
          name
        }
      }
    }
  `;
  
  const result = await makeLinearRequest(query);
  return result.teams.nodes[0]; // Use first team or create logic here
}

async function createInitiative(teamId) {
  const query = `
    mutation InitiativeCreate($input: InitiativeCreateInput!) {
      initiativeCreate(input: $input) {
        success
        initiative {
          id
          name
          description
        }
      }
    }
  `;
  
  const variables = {
    input: {
      name: STRATEGIC_FRAMEWORK.initiative.name,
      description: STRATEGIC_FRAMEWORK.initiative.description,
      targetDate: STRATEGIC_FRAMEWORK.initiative.targetDate
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.initiativeCreate.initiative;
}

async function createLabels(teamId) {
  const createdLabels = {};
  
  // Create all label categories
  for (const [category, labels] of Object.entries(STRATEGIC_FRAMEWORK.labels)) {
    createdLabels[category] = [];
    
    for (const label of labels) {
      const query = `
        mutation IssueLabelCreate($input: IssueLabelCreateInput!) {
          issueLabelCreate(input: $input) {
            success
            issueLabel {
              id
              name
              color
            }
          }
        }
      `;
      
      const variables = {
        input: {
          name: label.name,
          color: label.color,
          description: label.description,
          teamId: teamId
        }
      };
      
      try {
        const result = await makeLinearRequest(query, variables);
        createdLabels[category].push(result.issueLabelCreate.issueLabel);
        console.log(`✅ Created label: ${label.name}`);
      } catch (error) {
        console.log(`⚠️  Label may already exist: ${label.name}`);
      }
    }
  }
  
  return createdLabels;
}

async function createProjects(teamId, initiativeId) {
  const createdProjects = [];
  
  for (const projectConfig of STRATEGIC_FRAMEWORK.projects) {
    const query = `
      mutation ProjectCreate($input: ProjectCreateInput!) {
        projectCreate(input: $input) {
          success
          project {
            id
            name
            description
          }
        }
      }
    `;
    
    const variables = {
      input: {
        name: projectConfig.name,
        description: projectConfig.description,
        teamId: teamId
      }
    };
    
    try {
      const result = await makeLinearRequest(query, variables);
      const project = result.projectCreate.project;
      createdProjects.push({ ...project, focus: projectConfig.focus });
      
      // Assign to initiative
      await assignProjectToInitiative(initiativeId, project.id);
      
      console.log(`✅ Created project: ${projectConfig.name}`);
    } catch (error) {
      console.log(`❌ Failed to create project ${projectConfig.name}: ${error.message}`);
    }
  }
  
  return createdProjects;
}

async function assignProjectToInitiative(initiativeId, projectId) {
  const query = `
    mutation InitiativeToProjectCreate($input: InitiativeToProjectCreateInput!) {
      initiativeToProjectCreate(input: $input) {
        success
      }
    }
  `;
  
  const variables = {
    input: {
      initiativeId: initiativeId,
      projectId: projectId
    }
  };
  
  await makeLinearRequest(query, variables);
}

async function createSampleIssues(teamId, projects, labels) {
  const sampleIssues = [
    {
      title: "Set up revenue tracking system",
      description: "Implement comprehensive revenue tracking and goal monitoring system",
      project: "Revenue Generation",
      labels: ["High Revenue", "Implementation", "M", "High Priority"],
      priority: 1
    },
    {
      title: "Develop client onboarding process",
      description: "Create standardized client onboarding workflow and documentation",
      project: "Business Development", 
      labels: ["Medium Revenue", "Strategy", "L", "High Priority"],
      priority: 2
    },
    {
      title: "Optimize daily productivity workflow",
      description: "Analyze and improve daily work patterns for maximum efficiency",
      project: "Operations & Infrastructure",
      labels: ["Low Revenue", "Research", "S", "Medium Priority"],
      priority: 3
    },
    {
      title: "Strategic planning for next quarter",
      description: "Define goals, priorities, and resource allocation for upcoming quarter",
      project: "Strategic Planning",
      labels: ["Medium Revenue", "Strategy", "M", "High Priority"],
      priority: 2
    }
  ];
  
  // Create label lookup map
  const labelMap = {};
  Object.values(labels).flat().forEach(label => {
    labelMap[label.name] = label.id;
  });
  
  for (const issueConfig of sampleIssues) {
    // Find project
    const project = projects.find(p => p.name === issueConfig.project);
    if (!project) continue;
    
    // Get label IDs
    const labelIds = issueConfig.labels
      .map(labelName => labelMap[labelName])
      .filter(Boolean);
    
    const query = `
      mutation IssueCreate($input: IssueCreateInput!) {
        issueCreate(input: $input) {
          success
          issue {
            id
            title
          }
        }
      }
    `;
    
    const variables = {
      input: {
        title: issueConfig.title,
        description: issueConfig.description,
        teamId: teamId,
        projectId: project.id,
        priority: issueConfig.priority,
        labelIds: labelIds
      }
    };
    
    try {
      const result = await makeLinearRequest(query, variables);
      console.log(`✅ Created issue: ${issueConfig.title}`);
    } catch (error) {
      console.log(`❌ Failed to create issue: ${error.message}`);
    }
  }
}

// ========================================
// MAIN SETUP FUNCTION
// ========================================

async function setupLinearWorkspace() {
  try {
    console.log("🚀 Setting up Strategic Linear Workspace...");
    console.log(`📊 Business: ${BUSINESS_CONFIG.name}`);
    console.log(`💰 Target: ${BUSINESS_CONFIG.currency} ${BUSINESS_CONFIG.annualRevenueTarget.toLocaleString()}`);
    console.log(`👥 Team Size: ${BUSINESS_CONFIG.teamSize}`);
    console.log("");
    
    // Step 1: Get team
    console.log("🔍 Getting team information...");
    const team = await getOrCreateTeam();
    console.log(`✅ Using team: ${team.name} (${team.id})`);
    
    // Step 2: Create initiative
    console.log("🎯 Creating strategic initiative...");
    const initiative = await createInitiative(team.id);
    console.log(`✅ Created initiative: ${initiative.name}`);
    
    // Step 3: Create label system
    console.log("🏷️  Creating comprehensive label system...");
    const labels = await createLabels(team.id);
    console.log(`✅ Created ${Object.values(labels).flat().length} labels across ${Object.keys(labels).length} categories`);
    
    // Step 4: Create projects
    console.log("📁 Creating strategic projects...");
    const projects = await createProjects(team.id, initiative.id);
    console.log(`✅ Created ${projects.length} projects`);
    
    // Step 5: Create sample issues
    console.log("📋 Creating sample strategic issues...");
    await createSampleIssues(team.id, projects, labels);
    console.log("✅ Sample issues created");
    
    console.log("");
    console.log("🎉 Linear Workspace Setup Complete!");
    console.log("");
    console.log("📋 What was created:");
    console.log(`✅ Strategic Initiative: ${initiative.name}`);
    console.log(`✅ ${projects.length} Core Projects`);
    console.log(`✅ ${Object.values(labels).flat().length} Strategic Labels`);
    console.log("✅ Sample Issues with proper categorization");
    console.log("");
    console.log("🎯 Next Steps:");
    console.log("1. Review and customize projects in Linear");
    console.log("2. Add team members and assign responsibilities");
    console.log("3. Create specific client/project issues as needed");
    console.log("4. Set up automation workflows with n8n");
    console.log("5. Begin strategic execution!");
    
    return {
      team,
      initiative,
      projects,
      labels
    };
    
  } catch (error) {
    console.error("❌ Setup failed:", error.message);
    throw error;
  }
}

// ========================================
// CUSTOMIZATION HELPERS
// ========================================

// Function to add custom labels for specific industries
function addIndustryLabels(industry) {
  const industryLabels = {
    "Legal": [
      { name: "Case Management", color: "#7c2d12", description: "Legal case work" },
      { name: "Client Communication", color: "#365314", description: "Client meetings and updates" },
      { name: "Legal Research", color: "#1e3a8a", description: "Legal research and analysis" }
    ],
    "Healthcare": [
      { name: "Patient Care", color: "#be123c", description: "Direct patient services" },
      { name: "Compliance", color: "#166534", description: "Healthcare compliance work" },
      { name: "Documentation", color: "#0369a1", description: "Medical documentation" }
    ],
    "E-commerce": [
      { name: "Inventory", color: "#a16207", description: "Inventory management" },
      { name: "Customer Service", color: "#0891b2", description: "Customer support" },
      { name: "Marketing", color: "#c2410c", description: "Marketing and promotion" }
    ]
  };
  
  if (industryLabels[industry]) {
    STRATEGIC_FRAMEWORK.labels.industry = industryLabels[industry];
  }
}

// Function to customize for different revenue models
function customizeForRevenueModel(model) {
  if (model === "subscription") {
    STRATEGIC_FRAMEWORK.projects.push({
      name: "Customer Success",
      description: "Customer retention, expansion, and satisfaction management.",
      focus: "high_revenue"
    });
  } else if (model === "hourly") {
    STRATEGIC_FRAMEWORK.projects.push({
      name: "Time Optimization",
      description: "Maximizing billable hours and hourly rate optimization.",
      focus: "high_revenue"
    });
  }
}

// Apply customizations based on configuration
addIndustryLabels(BUSINESS_CONFIG.industry);
customizeForRevenueModel(BUSINESS_CONFIG.revenueModel);

// ========================================
// EXPORT FOR REUSE
// ========================================

module.exports = {
  setupLinearWorkspace,
  BUSINESS_CONFIG,
  STRATEGIC_FRAMEWORK,
  makeLinearRequest,
  addIndustryLabels,
  customizeForRevenueModel
};

// ========================================
// STANDALONE EXECUTION
// ========================================

if (require.main === module) {
  setupLinearWorkspace()
    .then((result) => {
      console.log("✅ Strategic Linear workspace setup completed successfully!");
      console.log("Your business is now ready for strategic automation! 🚀");
    })
    .catch(error => {
      console.error("❌ Setup failed:", error);
      process.exit(1);
    });
}