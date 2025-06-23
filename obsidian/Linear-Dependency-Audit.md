# Linear Dependency & Label Audit Script

## GraphQL Query to Check Dependencies & Labels

```graphql
query GetIssueRelationsAndLabels($teamId: String!) {
  team(id: $teamId) {
    issues(first: 100) {
      nodes {
        id
        identifier  
        title
        description
        priority
        state { name type }
        
        # LABELS - Check for missing required labels
        labels {
          nodes { 
            id 
            name 
            color 
          }
        }
        
        # RELATIONS - The dependency system
        relations {
          nodes {
            type          # "blocks", "blocked_by", "relates_to", "duplicate"
            relatedIssue {
              id
              identifier
              title
              state { name }
              project { 
                id 
                name 
                initiative { name }
              }
            }
          }
        }
        
        # PROJECT CONTEXT
        project {
          id 
          name
          health
          initiative { 
            id 
            name 
            targetDate
          }
        }
        
        assignee { name }
        createdAt
        updatedAt
      }
    }
  }
}
```

## Dependency Analysis Logic

```javascript
// Process the Linear response to find dependency issues
function analyzeDependencies(issues) {
  const dependencyProblems = [];
  const labelProblems = [];
  
  // Required label categories from your strategic system
  const requiredLabels = {
    size: ['XS', 'S', 'M', 'L', 'XL'],
    revenue: ['High Revenue', 'Medium Revenue', 'Low Revenue'],
    workType: ['Client Work', 'Implementation', 'Strategy', 'Research'],
    focus: ['Deep-Work', 'Quick-Win']  // Optional but recommended
  };
  
  issues.forEach(issue => {
    const labels = issue.labels.nodes.map(l => l.name);
    
    // 1. CHECK MISSING LABELS
    const missingCategories = [];
    
    // Check size labels
    if (!requiredLabels.size.some(size => labels.includes(size))) {
      missingCategories.push('Size Estimation');
    }
    
    // Check revenue labels  
    if (!requiredLabels.revenue.some(rev => labels.includes(rev))) {
      missingCategories.push('Revenue Impact');
    }
    
    // Check work type labels
    if (!requiredLabels.workType.some(type => labels.includes(type))) {
      missingCategories.push('Work Type');
    }
    
    if (missingCategories.length > 0) {
      labelProblems.push({
        issue: issue.identifier,
        title: issue.title,
        project: issue.project?.name,
        missing: missingCategories,
        currentLabels: labels
      });
    }
    
    // 2. CHECK DEPENDENCY LOGIC
    issue.relations.nodes.forEach(relation => {
      const relatedIssue = relation.relatedIssue;
      
      // Check for cross-project dependencies that should be labeled
      if (issue.project?.id !== relatedIssue.project?.id) {
        const hasUnlocksLabel = labels.some(label => 
          label.includes('Unlocks') || label.includes('Related')
        );
        
        if (!hasUnlocksLabel && relation.type === 'blocks') {
          dependencyProblems.push({
            issue: issue.identifier,
            title: issue.title,
            project: issue.project?.name,
            blocks: relatedIssue.identifier,
            blockedProject: relatedIssue.project?.name,
            problem: 'Cross-project dependency missing strategic label',
            suggestion: 'Add "Unlocks VibeCoding" or "Related Automation" label'
          });
        }
      }
      
      // Check for High Revenue issues blocked by non-High Revenue
      if (labels.includes('High Revenue') && relation.type === 'blocked_by') {
        // Would need to fetch the blocking issue's labels to check this
        dependencyProblems.push({
          issue: issue.identifier,
          title: issue.title,
          problem: 'High Revenue issue has blocker - verify blocker priority',
          blockedBy: relatedIssue.identifier,
          suggestion: 'Ensure blocking issue is properly prioritized'
        });
      }
    });
  });
  
  return { labelProblems, dependencyProblems };
}
```

## Strategic Dependency Patterns to Check

```javascript
// Patterns that should exist based on your strategic framework
const expectedDependencies = {
  // Client framework chain
  'client-acquisition': { blocks: ['client-discovery'] },
  'client-discovery': { 
    blocks: ['client-implementation'],
    enables: ['automatebau-validation']  // Should have "Unlocks" label
  },
  'client-implementation': { 
    enables: ['automatebau-validation']
  },
  
  // Infrastructure dependencies  
  'strategic-ops': { 
    enables: ['obsidian-knowledge', 'screenpipe-gui']
  },
  'obsidian-knowledge': {
    enables: ['automatebau-validation']
  },
  
  // AutomateBau critical path
  'automatebau-validation': {
    blockedBy: ['client-discovery', 'client-implementation', 'obsidian-knowledge']
  }
};

function validateStrategicDependencies(issues, expectedDeps) {
  const missingDependencies = [];
  
  // Check if expected dependencies are actually set up in Linear
  Object.entries(expectedDeps).forEach(([projectKey, deps]) => {
    const projectIssues = issues.filter(issue => 
      issue.project?.name.toLowerCase().includes(projectKey.replace('-', ' '))
    );
    
    projectIssues.forEach(issue => {
      // Check if this issue has the expected blocking/enabling relationships
      const relations = issue.relations.nodes;
      
      if (deps.blocks) {
        deps.blocks.forEach(expectedBlocked => {
          const hasBlockingRelation = relations.some(rel => 
            rel.type === 'blocks' && 
            rel.relatedIssue.project?.name.toLowerCase().includes(expectedBlocked.replace('-', ' '))
          );
          
          if (!hasBlockingRelation) {
            missingDependencies.push({
              issue: issue.identifier,
              title: issue.title,
              missing: `Should block issues in ${expectedBlocked} project`,
              action: 'Add "blocks" relationship'
            });
          }
        });
      }
      
      if (deps.enables) {
        // Check if issue has appropriate strategic labels for enablement
        const labels = issue.labels.nodes.map(l => l.name);
        const hasStrategicLabel = labels.some(label => 
          label.includes('Unlocks') || label.includes('Related')
        );
        
        if (!hasStrategicLabel) {
          missingDependencies.push({
            issue: issue.identifier,
            title: issue.title,
            missing: `Missing strategic connection label for enabling ${deps.enables.join(', ')}`,
            action: 'Add appropriate "Unlocks" or "Related" label'
          });
        }
      }
    });
  });
  
  return missingDependencies;
}
```

## Action Plan

### Step 1: Run Dependency Audit
Query Linear with the GraphQL above to get current state

### Step 2: Fix Missing Labels  
Focus on issues missing:
- Size estimation (XS, S, M, L, XL)
- Revenue impact (High/Medium/Low Revenue)
- Work type (Client Work, Implementation, Strategy, Research)

### Step 3: Set Up Missing Dependencies
Based on your strategic framework:
- Client Acquisition → blocks → Client Discovery
- Client Discovery → blocks → Client Implementation  
- Client Discovery → enables → AutomateBau (needs "Unlocks" label)

### Step 4: Validate Cross-Project Dependencies
Ensure issues that enable other projects have proper strategic labels

Want me to run this audit on your actual Linear data to see what's missing?