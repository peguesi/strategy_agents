// Linear Simply BAU Structure Setup Script - CORRECTED
// Based on actual Linear GraphQL schema from their official docs

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

// Get all issue labels for a team
async function getIssueLabels(teamId) {
  const query = `
    query GetIssueLabels($teamId: String!) {
      team(id: $teamId) {
        labels {
          nodes {
            id
            name
            color
          }
        }
      }
    }
  `;
  
  const result = await makeLinearRequest(query, { teamId });
  return result.team.labels.nodes;
}

// Get all projects for a team
async function getProjects(teamId) {
  const query = `
    query GetProjects($teamId: String!) {
      team(id: $teamId) {
        projects {
          nodes {
            id
            name
            description
            labels {
              nodes {
                name
              }
            }
          }
        }
      }
    }
  `;
  
  const result = await makeLinearRequest(query, { teamId });
  return result.team.projects.nodes;
}

// Get all issues for Simply BAU projects
async function getSimplyBAUIssues(projectIds) {
  const query = `
    query GetIssues($filter: IssueFilter!) {
      issues(filter: $filter) {
        nodes {
          id
          title
          description
          project {
            id
            name
          }
          labels {
            nodes {
              name
            }
          }
        }
      }
    }
  `;
  
  const variables = {
    filter: {
      project: {
        id: { in: projectIds }
      }
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.issues.nodes;
}

// Update project with labels
async function updateProjectWithLabels(projectId, labelIds) {
  const query = `
    mutation ProjectUpdate($id: String!, $input: ProjectUpdateInput!) {
      projectUpdate(id: $id, input: $input) {
        success
        project {
          id
          name
          labels {
            nodes {
              name
            }
          }
        }
      }
    }
  `;
  
  const variables = {
    id: projectId,
    input: {
      labelIds: labelIds
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.projectUpdate.project;
}

// Update issue with labels
async function updateIssueWithLabels(issueId, labelIds) {
  const query = `
    mutation IssueUpdate($id: String!, $input: IssueUpdateInput!) {
      issueUpdate(id: $id, input: $input) {
        success
        issue {
          id
          title
          labels {
            nodes {
              name
            }
          }
        }
      }
    }
  `;
  
  const variables = {
    id: issueId,
    input: {
      labelIds: labelIds
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.issueUpdate.issue;
}

// Assign projects to initiatives
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
  return result.initiativeToProjectCreate.initiativeToProject;
}

// Create project update with health status and resources
async function createProjectUpdateWithResources(projectId, body, health, resources = []) {
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
  
  // Add resources as links in the body if provided
  let bodyWithResources = body;
  if (resources.length > 0) {
    bodyWithResources += "\n\n**Resources:**\n";
    resources.forEach(resource => {
      bodyWithResources += `- [${resource.title}](${resource.url})\n`;
    });
  }
  
  const variables = {
    input: {
      projectId: projectId,
      body: bodyWithResources,
      health: health // "onTrack", "atRisk", "offTrack"
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.projectUpdateCreate.projectUpdate;
}

// Update initiative with description and resources
async function updateInitiativeWithResources(initiativeId, description, resources = []) {
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
  
  // Add resources as links in description
  let descriptionWithResources = description;
  if (resources.length > 0) {
    descriptionWithResources += "\n\n**Key Resources:**\n";
    resources.forEach(resource => {
      descriptionWithResources += `- [${resource.title}](${resource.url})\n`;
    });
  }
  
  const variables = {
    id: initiativeId,
    input: {
      description: descriptionWithResources
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.initiativeUpdate.initiative;
}

// Create issue with labels
async function createIssue(title, description, teamId, projectId, estimate, priority, labelIds = []) {
  const query = `
    mutation IssueCreate($input: IssueCreateInput!) {
      issueCreate(input: $input) {
        success
        issue {
          id
          title
          description
          labels {
            nodes {
              name
            }
          }
        }
      }
    }
  `;
  
  const variables = {
    input: {
      title: title,
      description: description,
      teamId: teamId,
      projectId: projectId,
      estimate: estimate,
      priority: priority,
      labelIds: labelIds
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.issueCreate.issue;
}

// Get team information
async function getTeamInfo() {
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
  return result.teams.nodes;
}

// Main update function
async function updateSimplyBAUComplete() {
  try {
    console.log("🔍 Getting team information...");
    
    // Get team
    const teams = await getTeamInfo();
    const team = teams[0]; // Use first team
    const TEAM_ID = team.id;
    
    console.log(`✅ Using team: ${team.name} (${TEAM_ID})`);
    
    // Get all issue labels 
    console.log("🏷️ Getting all issue labels...");
    const issueLabels = await getIssueLabels(TEAM_ID);
    
    // Create issue label map for easy lookup
    const issueLabelMap = {};
    issueLabels.forEach(label => {
      issueLabelMap[label.name] = label.id;
    });
    
    console.log(`📊 Found ${issueLabels.length} issue labels:`, Object.keys(issueLabelMap));
    
    // Get projects
    console.log("📁 Getting projects...");
    const projects = await getProjects(TEAM_ID);
    
    // Define project label assignments
    const projectLabelAssignments = [
      {
        nameContains: "Client Acquisition",
        labels: ["Client Delivery", "Discovery", "High Priority"]
      },
      {
        nameContains: "Discovery Framework", 
        labels: ["Client Delivery", "Discovery", "High Priority"]
      },
      {
        nameContains: "Implementation Template",
        labels: ["Client Delivery", "Implementation", "High Priority"]
      },
      {
        nameContains: "AutomateBau Framework",
        labels: ["Platform Development", "Implementation", "Medium Priority"]
      },
      {
        nameContains: "Data Collection",
        labels: ["Platform Development", "Implementation", "Medium Priority"]
      }
    ];
    
// Assign projects to initiatives
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
  return result.initiativeToProjectCreate.initiativeToProject;
}

// Create project update with health status and resources
async function createProjectUpdateWithResources(projectId, body, health, resources = []) {
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
  
  // Add resources as links in the body if provided
  let bodyWithResources = body;
  if (resources.length > 0) {
    bodyWithResources += "\n\n**Resources:**\n";
    resources.forEach(resource => {
      bodyWithResources += `- [${resource.title}](${resource.url})\n`;
    });
  }
  
  const variables = {
    input: {
      projectId: projectId,
      body: bodyWithResources,
      health: health // "onTrack", "atRisk", "offTrack"
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.projectUpdateCreate.projectUpdate;
}

// Update initiative with description and resources
async function updateInitiativeWithResources(initiativeId, description, resources = []) {
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
  
  // Add resources as links in description
  let descriptionWithResources = description;
  if (resources.length > 0) {
    descriptionWithResources += "\n\n**Key Resources:**\n";
    resources.forEach(resource => {
      descriptionWithResources += `- [${resource.title}](${resource.url})\n`;
    });
  }
  
  const variables = {
    id: initiativeId,
    input: {
      description: descriptionWithResources
    }
  };
  
  const result = await makeLinearRequest(query, variables);
  return result.initiativeUpdate.initiative;
}
    
    // Get all issues for Simply BAU projects
    const projectIds = projects.map(p => p.id);
    console.log("📋 Getting issues...");
    const issues = await getSimplyBAUIssues(projectIds);
    console.log(`Found ${issues.length} existing issues`);
    
    // Define issue label assignments
    const issueLabelAssignments = [
      {
        titleContains: "Draft flexible service contract",
        labels: ["M", "High Revenue", "Client Work", "Deep-Work", "feature"]
      },
      {
        titleContains: "Prepare client materials for tomorrow",
        labels: ["S", "High Revenue", "Client Work", "Quick-Win", "feature"]
      },
      {
        titleContains: "Design discovery session methodology",
        labels: ["L", "High Revenue", "Strategy", "Related Automation", "feature"]
      },
      {
        titleContains: "Implement e-signature",
        labels: ["L", "Medium Revenue", "Implementation", "feature"]
      },
      {
        titleContains: "modular deliverable system",
        labels: ["M", "Medium Revenue", "Strategy", "Unlocks VibeCoding", "feature"]
      },
      {
        titleContains: "Discovery session execution", 
        labels: ["XL", "High Revenue", "Client Work", "Deep-Work", "feature"]
      },
      {
        titleContains: "Current state analysis",
        labels: ["L", "High Revenue", "Client Work", "feature"]
      }
    ];
    
    // Update existing issues with labels
    for (const issue of issues) {
      console.log(`🔄 Processing issue: ${issue.title}...`);
      
      // Find matching label assignment
      const assignment = issueLabelAssignments.find(a => 
        issue.title.toLowerCase().includes(a.titleContains.toLowerCase())
      );
      
      if (assignment) {
        // Get label IDs (only for labels that exist)
        const labelIds = assignment.labels
          .map(labelName => issueLabelMap[labelName])
          .filter(Boolean);
        
        if (labelIds.length > 0) {
          console.log(`  📎 Adding labels: ${assignment.labels.filter(l => issueLabelMap[l]).join(', ')}`);
          await updateIssueWithLabels(issue.id, labelIds);
          console.log(`  ✅ Labels added successfully`);
        } else {
          console.log(`  ⚠️  No matching labels found for: ${assignment.labels.join(', ')}`);
        }
      } else {
        console.log(`  ⚠️  No label assignment found for this issue`);
      }
    }
    
    // Create additional comprehensive issues
    console.log("➕ Creating additional comprehensive issues...");
    
    const additionalIssues = [
      // Client Acquisition & Contracts
      {
        title: "Implement e-signature system integration",
        description: "Integrate DocuSign or HelloSign into proposal site with download functionality",
        projectName: "Client Acquisition",
        estimate: 5,
        priority: 2,
        labels: ["L", "Medium Revenue", "Implementation", "feature"]
      },
      {
        title: "Create flexible contract pricing tiers",
        description: "Operations/Growth/Accelerated pricing structure with scope flexibility",
        projectName: "Client Acquisition", 
        estimate: 2,
        priority: 1,
        labels: ["S", "High Revenue", "Client Work", "Quick-Win", "feature"]
      },
      
      // Discovery Framework
      {
        title: "Research discovery frameworks (BMC vs Value Stream)",
        description: "Quick research on best framework for Simply BAU client type",
        projectName: "Discovery Framework",
        estimate: 1,
        priority: 2,
        labels: ["XS", "Medium Revenue", "Research", "Quick-Win", "feature"]
      },
      {
        title: "Create standardized tool inventory questionnaire", 
        description: "Template to capture every app, tool, integration client uses",
        projectName: "Discovery Framework",
        estimate: 2,
        priority: 2,
        labels: ["S", "Medium Revenue", "Strategy", "Related Automation", "feature"]
      },
      {
        title: "Design adaptive deliverable templates",
        description: "Modular templates that scale based on discovery findings",
        projectName: "Discovery Framework",
        estimate: 3,
        priority: 2,
        labels: ["M", "Medium Revenue", "Strategy", "Unlocks VibeCoding", "feature"]
      },
      
      // Implementation Template  
      {
        title: "Solution design & client presentation",
        description: "Create automation solution design and present to Simply BAU",
        projectName: "Implementation Template",
        estimate: 8,
        priority: 2,
        labels: ["XL", "High Revenue", "Client Work", "Deep-Work", "feature"]
      },
      {
        title: "Implementation planning & delivery execution",
        description: "Detailed roadmap and actual implementation for Simply BAU",
        projectName: "Implementation Template", 
        estimate: 13,
        priority: 3,
        labels: ["XL", "High Revenue", "Client Work", "Related Client-Growth", "feature"]
      }
    ];

    // Create the additional issues
    for (const issueConfig of additionalIssues) {
      // Find the project
      const project = projects.find(p => 
        p.name.toLowerCase().includes(issueConfig.projectName.toLowerCase())
      );
      
      if (!project) {
        console.log(`⚠️  Project not found for: ${issueConfig.projectName}`);
        continue;
      }

      // Get label IDs
      const labelIds = issueConfig.labels
        .map(labelName => issueLabelMap[labelName])
        .filter(Boolean);

      console.log(`📝 Creating issue: ${issueConfig.title}...`);
      
      try {
        const issue = await createIssue(
          issueConfig.title,
          issueConfig.description,
          TEAM_ID,
          project.id,
          issueConfig.estimate,
          issueConfig.priority,
          labelIds
        );
        console.log(`✅ Issue created: ${issue.title}`);
        console.log(`   📎 Labels: ${issue.labels.nodes.map(l => l.name).join(', ')}`);
      } catch (error) {
        console.log(`❌ Failed to create issue: ${error.message}`);
      }
    }
    
    console.log("🎉 Simply BAU complete update finished!");
    console.log("");
    console.log("📊 Summary:");
    console.log(`- Team: ${team.name}`);
    console.log(`- Projects: ${projects.length}`);
    console.log(`- Issue labels available: ${issueLabels.length}`);
    console.log(`- Issues processed: ${issues.length}`);
    console.log("");
    console.log("📋 Next Steps:");
    console.log("1. ✅ Review issue labels and assignments in Linear");
    console.log("2. ⚠️  Manually assign project labels to projects in Linear UI");
    console.log("3. 🔗 Add issue dependencies as needed (blocks/relates to)");
    console.log("4. 📅 Set due dates for tomorrow's meeting materials");
    
  } catch (error) {
    console.error("❌ Update failed:", error.message);
    throw error;
  }
}

// Export functions
module.exports = {
  updateSimplyBAUComplete,
  makeLinearRequest,
  getIssueLabels,
  updateIssueWithLabels,
  createIssue,
  assignProjectToInitiative,
  createProjectUpdateWithResources,
  updateInitiativeWithResources
};

// For standalone execution
if (require.main === module) {
  updateSimplyBAUComplete()
    .then(() => console.log("Complete update finished successfully!"))
    .catch(error => console.error("Update failed:", error));
}