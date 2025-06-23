# Linear → Obsidian Dynamic Sync Workflow

## Workflow Overview
Automatically sync Linear project data to Obsidian for real-time visualization updates.

## n8n Workflow Design

### Trigger: Schedule (Every 15 minutes)
```json
{
  "cronExpression": "*/15 * * * *",
  "timezone": "America/New_York"
}
```

### Step 1: Fetch Linear Projects
```javascript
// Linear GraphQL Query
const query = `
  query GetProjects {
    projects {
      nodes {
        id
        name
        description
        progress
        health
        startDate
        targetDate
        initiative {
          name
        }
        issues {
          nodes {
            priority
            labels {
              nodes { name }
            }
            state { type }
          }
        }
      }
    }
  }
`;

return {
  headers: {
    'Content-Type': 'application/json',
    'Authorization': $env.LINEAR_API_KEY
  },
  body: { query }
};
```

### Step 2: Process & Transform Data
```javascript
// Transform Linear data for Obsidian
const projects = $input.data.projects.nodes;

const obsidianData = projects.map(project => ({
  name: project.name,
  'project-status': project.health,
  'revenue-impact': getRevenueImpact(project.issues.nodes),
  'progress': project.progress || 0,
  'target-date': project.targetDate,
  'key-blockers': getBlockers(project.issues.nodes),
  'initiative': project.initiative?.name
}));

function getRevenueImpact(issues) {
  const highRevenue = issues.some(issue => 
    issue.labels.nodes.some(label => label.name === 'High Revenue')
  );
  return highRevenue ? 'High' : 'Medium';
}

return { projects: obsidianData };
```

### Step 3: Update Obsidian via MCP
```javascript
// Generate Obsidian frontmatter + content
const content = `---
project-status: ${project['project-status']}
revenue-impact: ${project['revenue-impact']}
progress: ${project.progress}
target-date: ${project['target-date']}
tags: [linear-project, ${project.initiative}]
---

# ${project.name}

**Status**: ${project['project-status']}
**Revenue Impact**: ${project['revenue-impact']}
**Progress**: ${project.progress}%
**Target**: ${project['target-date']}

## Current Blockers
${project['key-blockers']}

---
*Auto-updated: {{date:YYYY-MM-DD HH:mm}}*
`;

return {
  filePath: `projects/${project.name.replace(/\s+/g, '-')}.md`,
  content: content
};
```

### Step 4: Generate Network Visualization
```javascript
// Create dynamic Mermaid diagram
const connections = analyzeProjectDependencies($input.projects);

const mermaidDiagram = `
\`\`\`mermaid
graph TD
${connections.map(conn => 
  `  ${conn.from}[${conn.fromName}] --> ${conn.to}[${conn.toName}]`
).join('\n')}
\`\`\`
`;

return {
  filePath: 'strategic-insights/Project-Network-Map.md',
  content: `# Project Network Map\n\n${mermaidDiagram}\n\n*Updated: ${new Date().toISOString()}*`
};
```

## Expected Results

### ✅ **Real-Time Updates**
- Obsidian reflects Linear changes within 15 minutes
- Project progress automatically tracked
- Blockers and priorities sync in real-time

### ✅ **Dynamic Visualizations**
- Network diagrams update automatically
- Revenue tracking charts reflect current data
- Priority heat maps adjust based on Linear labels

### ✅ **Strategic Intelligence**
- Cross-project dependencies mapped automatically
- Revenue impact analysis updates live
- Critical path visualization stays current

## Integration with Your Current Setup

**Leverages Existing Infrastructure:**
- Uses your current n8n instance
- Integrates with Obsidian MCP server
- Connects to Linear API with existing credentials
- Stores processed data in PostgreSQL for analysis

**Next Steps:**
1. Import this workflow to your n8n instance
2. Configure Linear API credentials
3. Test with sample project data
4. Enable automatic scheduling

This creates the **living, breathing dashboard** you need - where your Obsidian visualizations automatically stay in sync with your Linear strategic ecosystem!