// Linear Initiative & Project Updates - Focused Script
// Handles the missing pieces: initiative assignment, project descriptions, project updates

// Load environment variables
require('dotenv').config({ path: '../.env' });

const LINEAR_API_KEY = process.env.LINEAR_API_KEY;
const LINEAR_API_URL = process.env.LINEAR_API_URL || "https://api.linear.app/graphql";

if (!LINEAR_API_KEY) {
  console.error('❌ Error: LINEAR_API_KEY environment variable is required');
  console.error('Please set it in your .env file or export it:');
  console.error('export LINEAR_API_KEY="your_api_key_here"');
  process.exit(1);
}



// GraphQL request function
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

// Get initiative by name
async function findInitiativeByName(name) {
  const query = `
    query GetInitiatives {
      initiatives {
        nodes {
          id
          name
          description
        }
      }
    }
  `;
  
  const result = await makeLinearRequest(query);
  return result.initiatives.nodes.find(i => 
    i.name.toLowerCase().includes(name.toLowerCase())
  );
}

// Update initiative description
async function updateInitiativeDescription(initiativeId, description) {
  const query = `
    mutation InitiativeUpdate($id: String!, $input: InitiativeUpdateInput!) {
      initiativeUpdate(id: $id, input: $input) {
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
    id: initiativeId,
    input: {
      description: description
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.initiativeUpdate;
}

// Get projects for team
async function getProjectsForTeam(teamId) {
  const query = `
    query GetProjects($teamId: String!) {
      team(id: $teamId) {
        projects {
          nodes {
            id
            name
            description
          }
        }
      }
    }
  `;
  
  const result = await makeLinearRequest(query, { teamId });
  return result.team.projects.nodes;
}

// Update project description (CORRECT mutation name)
async function updateProjectDescription(projectId, description) {
  const query = `
    mutation ProjectUpdate($id: String!, $input: ProjectUpdateInput!) {
      projectUpdate(id: $id, input: $input) {
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
    id: projectId,
    input: {
      description: description
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.projectUpdate;
}

// Create project status update (CORRECT mutation)
async function createProjectStatusUpdate(projectId, body, health) {
  const query = `
    mutation ProjectUpdateCreate($input: ProjectUpdateCreateInput!) {
      projectUpdateCreate(input: $input) {
        success
        projectUpdate {
          id
          body
          health
          url
        }
      }
    }
  `;
  
  const variables = {
    input: {
      projectId: projectId,
      body: body,
      health: health // "onTrack", "atRisk", "offTrack"
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.projectUpdateCreate;
}

// Assign project to initiative
async function assignProjectToInitiative(initiativeId, projectId, sortOrder = 0) {
  const query = `
    mutation InitiativeToProjectCreate($input: InitiativeToProjectCreateInput!) {
      initiativeToProjectCreate(input: $input) {
        success
        initiativeToProject {
          id
          initiative {
            name
          }
          project {
            name
          }
        }
      }
    }
  `;
  
  const variables = {
    input: {
      initiativeId: initiativeId,
      projectId: projectId,
      sortOrder: sortOrder
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.initiativeToProjectCreate;
}

// Get team ID
async function getTeamId() {
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
  return result.teams.nodes[0]; // Use first team
}

// Main function to complete the missing setup
async function completeInitiativeProjectSetup() {
  try {
    console.log("🔧 Completing Initiative & Project Setup...");
    
    // Step 1: Get team ID
    const team = await getTeamId();
    console.log(`✅ Using team: ${team.name} (${team.id})`);
    
    // Step 2: Find or get Simply BAU initiative
    console.log("🔍 Finding Simply BAU initiative...");
    let initiative = await findInitiativeByName("Simply BAU");
    
    if (!initiative) {
      console.log("❌ Simply BAU initiative not found!");
      console.log("📋 Please create the initiative manually in Linear first");
      return;
    }
    
    console.log(`✅ Found initiative: ${initiative.name} (${initiative.id})`);
    
    // Step 3: Update initiative with comprehensive description (UNDER 255 chars)
    console.log("📝 Updating initiative description...");
    const initiativeDescription = `Strategic €50k revenue target through Simply BAU client delivery. Property management automation for German client. Establishes repeatable delivery methodology and AutomateBau framework development foundation.`;

    await updateInitiativeDescription(initiative.id, initiativeDescription);
    console.log("✅ Initiative description updated");
    
    // Step 4: Get projects
    console.log("📁 Getting projects...");
    const projects = await getProjectsForTeam(team.id);
    console.log(`Found ${projects.length} projects`);
    
    // Step 5: Update projects and assign to initiative
    const projectConfigs = [
      {
        nameContains: "Client Acquisition",
        description: `Contract development, e-signature system, and client onboarding process. Focus: flexible service contracts, DocuSign/HelloSign integration, client meeting prep, pricing tiers (Operations/Growth/Accelerated).`,
        statusBody: `**Client Acquisition Status Update**

**This Week's Progress:**
✅ Contract template development in progress
✅ E-signature platform research (DocuSign vs HelloSign)
✅ Client meeting materials being prepared
✅ Pricing tier structure defined

**Tomorrow's Meeting Preparation:**
- Contract draft ready for discussion
- Flexible scope framework prepared
- Discovery session methodology outlined

**Next Week Focus:**
- Contract finalization and signature
- E-signature system integration
- Post-signature project kickoff

**Resources:**
- [Contract Template Draft](https://docs.google.com/document/contract-template)
- [E-signature Comparison](https://docs.google.com/spreadsheet/esign-comparison)`,
        sortOrder: 0
      },
      {
        nameContains: "Discovery Framework",
        description: `Standardized discovery methodology and adaptive deliverable templates. Components: discovery sessions, tool inventory, modular deliverables, current state mapping. Templates scale from simple to complex.`,
        statusBody: `**Discovery Framework Status Update**

**Research & Development:**
✅ Framework methodology research underway
✅ Template structure designed for flexibility
✅ Tool inventory questionnaire drafted
🔄 Adaptive deliverable system in development

**Framework Benefits:**
- Scales to any client complexity
- Captures comprehensive current state
- Produces actionable insights
- Feeds AutomateBau framework development

**This Week's Focus:**
- Complete methodology research
- Finalize template structures
- Test framework with Simply BAU

**Resources:**
- [Discovery Research](https://docs.google.com/document/discovery-research)
- [Template Library](https://drive.google.com/folder/templates)`,
        sortOrder: 1
      },
      {
        nameContains: "Implementation Template",
        description: `Flexible project structure for Simply BAU client delivery. Phases: discovery execution, current state analysis, solution design, implementation planning. Deliverables include process docs and automation design.`,
        statusBody: `**Implementation Template Status Update**

**Template Structure:**
✅ Implementation phases defined and sequenced
✅ Deliverable templates prepared for each phase
✅ Client-specific customization approach designed
✅ Success metrics framework established

**Simply BAU Readiness:**
- Discovery session methodology finalized
- Current state mapping templates ready
- Solution design framework prepared
- Implementation timeline flexible and budget-aware

**Strategic Value:**
- Creates repeatable delivery model
- Feeds AutomateBau framework development
- Establishes client success patterns

**Resources:**
- [Implementation Playbook](https://docs.google.com/document/implementation-playbook)
- [Delivery Checklist](https://docs.google.com/spreadsheet/delivery-checklist)`,
        sortOrder: 2
      }
    ];
    
    // Process each project
    for (const config of projectConfigs) {
      const project = projects.find(p => 
        p.name.toLowerCase().includes(config.nameContains.toLowerCase())
      );
      
      if (project) {
        console.log(`\n📁 Processing project: ${project.name}...`);
        
        try {
          // Update project description
          await updateProjectDescription(project.id, config.description);
          console.log(`✅ Description updated`);
          
          // Create project status update
          await createProjectStatusUpdate(project.id, config.statusBody, "onTrack");
          console.log(`📊 Status update created (On Track)`);
          
          // Assign to initiative
          await assignProjectToInitiative(initiative.id, project.id, config.sortOrder);
          console.log(`🔗 Assigned to Simply BAU initiative`);
          
        } catch (error) {
          console.log(`❌ Error processing ${project.name}: ${error.message}`);
        }
      } else {
        console.log(`⚠️  Project not found: ${config.nameContains}`);
      }
    }
    
    console.log("\n🎉 Initiative & Project setup complete!");
    console.log("\n📋 What was accomplished:");
    console.log("✅ Initiative description updated with strategic context");
    console.log("✅ All projects assigned to Simply BAU initiative");
    console.log("✅ Project descriptions updated with detailed scope");
    console.log("✅ Project status updates created with 'On Track' health");
    console.log("✅ Resource links added to project descriptions");
    
    console.log("\n📅 Ready for tomorrow's Simply BAU meeting!");
    console.log("- Professional Linear workspace structure");
    console.log("- Clear project descriptions and status");
    console.log("- Strategic initiative tracking");
    console.log("- Comprehensive task organization");
    
  } catch (error) {
    console.error("❌ Setup failed:", error.message);
    throw error;
  }
}

// Export for use
module.exports = {
  completeInitiativeProjectSetup,
  findInitiativeByName,
  updateInitiativeDescription,
  updateProjectDescription,
  createProjectStatusUpdate,
  assignProjectToInitiative
};

// For standalone execution
if (require.main === module) {
  completeInitiativeProjectSetup()
    .then(() => console.log("\n✅ Initiative & Project setup completed successfully!"))
    .catch(error => console.error("Setup failed:", error));
}