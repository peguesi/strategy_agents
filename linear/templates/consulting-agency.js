// Consulting Agency Linear Setup Template
// Optimized for client service businesses with project-based revenue

const { 
  setupLinearWorkspace, 
  BUSINESS_CONFIG, 
  STRATEGIC_FRAMEWORK,
  makeLinearRequest 
} = require('./general-business');

// ========================================
// CONSULTING AGENCY CONFIGURATION
// ========================================

// Override general configuration for consulting business
Object.assign(BUSINESS_CONFIG, {
  name: "Your Consulting Agency",
  industry: "Professional Services",
  revenueModel: "project_based",
  averageProjectValue: 25000,
  teamSize: 5,
  primaryObjective: "client_satisfaction_and_growth"
});

// Consulting-specific projects
STRATEGIC_FRAMEWORK.projects = [
  {
    name: "Client Acquisition & Proposals",
    description: "Lead generation, proposal development, contract negotiation, and new client onboarding processes.",
    focus: "high_revenue"
  },
  {
    name: "Client Delivery & Execution", 
    description: "Active client project execution, deliverable creation, and ongoing client work management.",
    focus: "high_revenue"
  },
  {
    name: "Methodology & Framework Development",
    description: "Reusable consulting methodologies, templates, and delivery frameworks for scalable client work.",
    focus: "medium_revenue"
  },
  {
    name: "Business Operations & Growth",
    description: "Internal process optimization, team management, and strategic business development.",
    focus: "medium_revenue"
  }
];

// Consulting-specific labels
STRATEGIC_FRAMEWORK.labels.consulting = [
  { name: "Client Discovery", color: "#3b82f6", description: "Client needs assessment and analysis" },
  { name: "Proposal Development", color: "#8b5cf6", description: "Proposal writing and presentation" },
  { name: "Client Delivery", color: "#06b6d4", description: "Direct client work and deliverables" },
  { name: "Client Communication", color: "#10b981", description: "Client meetings and updates" },
  { name: "Template Development", color: "#f59e0b", description: "Reusable methodology creation" },
  { name: "Team Collaboration", color: "#ef4444", description: "Internal team coordination" }
];

// Consulting-specific sample issues
async function createConsultingSampleIssues(teamId, projects, labels) {
  // Create label lookup map
  const labelMap = {};
  Object.values(labels).flat().forEach(label => {
    labelMap[label.name] = label.id;
  });

  const consultingIssues = [
    {
      title: "Develop standardized discovery framework",
      description: "Create reusable client discovery methodology with templates and questionnaires",
      project: "Methodology & Framework Development",
      labels: ["Medium Revenue", "Strategy", "Template Development", "L", "High Priority"],
      priority: 1
    },
    {
      title: "Client proposal - Digital Transformation Project",
      description: "Develop comprehensive proposal for client digital transformation initiative",
      project: "Client Acquisition & Proposals", 
      labels: ["High Revenue", "Client Work", "Proposal Development", "M", "Urgent"],
      priority: 1
    },
    {
      title: "Execute Q4 strategic review for enterprise client",
      description: "Conduct quarterly business review and strategic planning session",
      project: "Client Delivery & Execution",
      labels: ["High Revenue", "Client Delivery", "Client Communication", "L", "High Priority"],
      priority: 1
    },
    {
      title: "Implement project management automation",
      description: "Set up automated project tracking and client reporting system",
      project: "Business Operations & Growth",
      labels: ["Medium Revenue", "Implementation", "Quick-Win", "M", "Medium Priority"],
      priority: 2
    },
    {
      title: "Create client onboarding checklist",
      description: "Standardized checklist and process for new client onboarding",
      project: "Methodology & Framework Development",
      labels: ["Medium Revenue", "Strategy", "Template Development", "S", "High Priority"],
      priority: 2
    },
    {
      title: "Monthly client satisfaction survey",
      description: "Implement automated client satisfaction tracking and feedback collection",
      project: "Client Delivery & Execution",
      labels: ["High Revenue", "Client Communication", "Implementation", "S", "Medium Priority"],
      priority: 3
    }
  ];

  for (const issueConfig of consultingIssues) {
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
      await makeLinearRequest(query, variables);
      console.log(`✅ Created consulting issue: ${issueConfig.title}`);
    } catch (error) {
      console.log(`❌ Failed to create issue: ${error.message}`);
    }
  }
}

// Enhanced setup function for consulting agencies
async function setupConsultingWorkspace() {
  console.log("🏢 Setting up Consulting Agency Workspace...");
  
  // Run base setup
  const result = await setupLinearWorkspace();
  
  // Add consulting-specific issues
  console.log("📋 Creating consulting-specific issues...");
  await createConsultingSampleIssues(result.team.id, result.projects, result.labels);
  
  console.log("");
  console.log("🎯 Consulting Agency Specific Features:");
  console.log("✅ Client-focused project structure");
  console.log("✅ Proposal and delivery workflow"); 
  console.log("✅ Methodology development framework");
  console.log("✅ Client satisfaction tracking");
  console.log("");
  console.log("📈 Revenue Optimization Ready:");
  console.log("- Project-based revenue tracking");
  console.log("- Client lifetime value monitoring");
  console.log("- Proposal win rate analysis");
  console.log("- Team utilization optimization");
  
  return result;
}

// Export specialized setup
module.exports = {
  setupConsultingWorkspace,
  BUSINESS_CONFIG,
  STRATEGIC_FRAMEWORK
};

// Standalone execution
if (require.main === module) {
  setupConsultingWorkspace()
    .then(() => {
      console.log("✅ Consulting Agency workspace setup completed!");
      console.log("🚀 Ready to scale your consulting business with strategic automation!");
    })
    .catch(error => {
      console.error("❌ Consulting setup failed:", error);
      process.exit(1);
    });
}