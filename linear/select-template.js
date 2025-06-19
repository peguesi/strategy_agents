#!/usr/bin/env node

// Linear Template Selector
// Interactive script to help users choose the right Linear template for their business

const readline = require('readline');
const fs = require('fs');
const path = require('path');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Template configurations
const TEMPLATES = {
  'general-business': {
    name: 'General Business',
    description: 'Flexible template suitable for any business type',
    bestFor: ['New businesses', 'Mixed revenue models', 'Unclear business type'],
    file: 'general-business.js'
  },
  'consulting-agency': {
    name: 'Consulting Agency',
    description: 'Optimized for client service businesses',
    bestFor: ['Professional services', 'Project-based work', 'Client deliverables'],
    file: 'consulting-agency.js'
  },
  'saas-business': {
    name: 'SaaS Business',
    description: 'Perfect for subscription-based software companies',
    bestFor: ['Software products', 'Subscription revenue', 'User onboarding'],
    file: 'saas-business.js'
  },
  'freelancer-solo': {
    name: 'Freelancer/Solo',
    description: 'Individual contributor optimization',
    bestFor: ['Solo workers', 'Hourly billing', 'Personal productivity'],
    file: 'freelancer-solo.js'
  }
};

// Questions to determine best template
const QUESTIONS = [
  {
    key: 'businessType',
    question: 'What type of business are you running?',
    options: {
      '1': { answer: 'Consulting/Professional Services', points: { 'consulting-agency': 3 }},
      '2': { answer: 'Software/SaaS Product', points: { 'saas-business': 3 }},
      '3': { answer: 'Freelancer/Solo Practice', points: { 'freelancer-solo': 3 }},
      '4': { answer: 'E-commerce/Retail', points: { 'general-business': 2 }},
      '5': { answer: 'Other/Mixed', points: { 'general-business': 3 }}
    }
  },
  {
    key: 'revenueModel',
    question: 'What is your primary revenue model?',
    options: {
      '1': { answer: 'Project-based contracts', points: { 'consulting-agency': 2, 'general-business': 1 }},
      '2': { answer: 'Monthly subscriptions', points: { 'saas-business': 2 }},
      '3': { answer: 'Hourly billing', points: { 'freelancer-solo': 2, 'consulting-agency': 1 }},
      '4': { answer: 'Product sales', points: { 'general-business': 2 }},
      '5': { answer: 'Mixed revenue sources', points: { 'general-business': 2 }}
    }
  },
  {
    key: 'teamSize',
    question: 'How many people are on your team?',
    options: {
      '1': { answer: 'Just me (solo)', points: { 'freelancer-solo': 2 }},
      '2': { answer: '2-5 people', points: { 'consulting-agency': 2, 'saas-business': 1, 'general-business': 1 }},
      '3': { answer: '6-15 people', points: { 'saas-business': 2, 'consulting-agency': 1 }},
      '4': { answer: '15+ people', points: { 'saas-business': 2, 'general-business': 1 }}
    }
  },
  {
    key: 'primaryFocus',
    question: 'What is your primary business focus?',
    options: {
      '1': { answer: 'Client satisfaction and delivery', points: { 'consulting-agency': 2 }},
      '2': { answer: 'Product development and features', points: { 'saas-business': 2 }},
      '3': { answer: 'Personal productivity and efficiency', points: { 'freelancer-solo': 2 }},
      '4': { answer: 'Sales and marketing growth', points: { 'general-business': 2 }},
      '5': { answer: 'Operations optimization', points: { 'general-business': 1, 'saas-business': 1 }}
    }
  }
];

// Helper functions
function askQuestion(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer.trim());
    });
  });
}

function displayQuestion(questionObj) {
  console.log(`\\n📋 ${questionObj.question}`);
  Object.entries(questionObj.options).forEach(([key, option]) => {
    console.log(`   ${key}. ${option.answer}`);
  });
}

function calculateScores(answers) {
  const scores = {};
  
  // Initialize scores
  Object.keys(TEMPLATES).forEach(template => {
    scores[template] = 0;
  });
  
  // Calculate points from answers
  QUESTIONS.forEach(question => {
    const answer = answers[question.key];
    if (answer && question.options[answer]) {
      const points = question.options[answer].points || {};
      Object.entries(points).forEach(([template, point]) => {
        scores[template] += point;
      });
    }
  });
  
  return scores;
}

function getRecommendation(scores) {
  let maxScore = 0;
  let recommended = 'general-business';
  
  Object.entries(scores).forEach(([template, score]) => {
    if (score > maxScore) {
      maxScore = score;
      recommended = template;
    }
  });
  
  return recommended;
}

function displayResults(scores, recommended) {
  console.log('\\n🎯 RECOMMENDATION RESULTS');
  console.log('=' .repeat(50));
  
  // Sort templates by score
  const sortedTemplates = Object.entries(scores)
    .sort(([,a], [,b]) => b - a)
    .map(([template, score]) => ({ template, score }));
  
  console.log('\\n📊 Template Scores:');
  sortedTemplates.forEach(({ template, score }, index) => {
    const templateInfo = TEMPLATES[template];
    const indicator = template === recommended ? '👑 RECOMMENDED' : '  ';
    console.log(`${indicator} ${templateInfo.name}: ${score} points`);
  });
  
  const recommendedTemplate = TEMPLATES[recommended];
  console.log('\\n🚀 BEST MATCH:');
  console.log(`   Template: ${recommendedTemplate.name}`);
  console.log(`   Description: ${recommendedTemplate.description}`);
  console.log(`   Best for: ${recommendedTemplate.bestFor.join(', ')}`);
  console.log(`   File: linear/templates/${recommendedTemplate.file}`);
}

async function generateCustomConfig(answers, recommended) {
  const config = {
    template: recommended,
    businessType: '',
    revenueModel: '',
    teamSize: 1,
    answers: answers
  };
  
  // Extract business details from answers
  const businessTypes = {
    '1': 'Professional Services',
    '2': 'Software/SaaS',
    '3': 'Freelancer',
    '4': 'E-commerce',
    '5': 'Other'
  };
  
  const revenueModels = {
    '1': 'project_based',
    '2': 'subscription',
    '3': 'hourly',
    '4': 'product_sales',
    '5': 'mixed'
  };
  
  config.businessType = businessTypes[answers.businessType] || 'General Business';
  config.revenueModel = revenueModels[answers.revenueModel] || 'mixed';
  
  if (answers.teamSize) {
    const teamSizes = { '1': 1, '2': 3, '3': 10, '4': 20 };
    config.teamSize = teamSizes[answers.teamSize] || 1;
  }
  
  // Save configuration
  const configPath = path.join(__dirname, 'selected-template-config.json');
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  
  console.log(`\\n💾 Configuration saved to: ${configPath}`);
  console.log('\\n📋 Next Steps:');
  console.log(`1. Edit linear/templates/${TEMPLATES[recommended].file} with your business details`);
  console.log('2. Set your LINEAR_API_KEY environment variable');
  console.log(`3. Run: node linear/templates/${TEMPLATES[recommended].file}`);
  console.log('4. Review your new Linear workspace');
  
  return config;
}

// Main interactive flow
async function selectTemplate() {
  console.log('🎯 LINEAR TEMPLATE SELECTOR');
  console.log('=' .repeat(40));
  console.log('\\nThis tool will help you choose the best Linear template for your business.');
  console.log('Answer a few questions to get a personalized recommendation.\\n');
  
  const answers = {};
  
  // Ask all questions
  for (const question of QUESTIONS) {
    displayQuestion(question);
    let answer;
    do {
      answer = await askQuestion('\\nYour choice (1-5): ');
      if (!question.options[answer]) {
        console.log('❌ Please enter a valid option (1-5)');
      }
    } while (!question.options[answer]);
    
    answers[question.key] = answer;
  }
  
  // Calculate recommendation
  const scores = calculateScores(answers);
  const recommended = getRecommendation(scores);
  
  // Display results
  displayResults(scores, recommended);
  
  // Ask if user wants to proceed
  const proceed = await askQuestion('\\n❓ Would you like to save this configuration? (y/N): ');
  
  if (proceed.toLowerCase() === 'y' || proceed.toLowerCase() === 'yes') {
    await generateCustomConfig(answers, recommended);
    console.log('\\n✅ Template selection complete! Happy automating! 🚀');
  } else {
    console.log('\\n👋 No problem! Run this script again anytime to select a template.');
  }
  
  rl.close();
}

// Handle script execution
if (require.main === module) {
  selectTemplate().catch(error => {
    console.error('❌ Template selection failed:', error);
    rl.close();
    process.exit(1);
  });
}

module.exports = {
  selectTemplate,
  TEMPLATES,
  QUESTIONS
};
