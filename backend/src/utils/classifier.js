const CATEGORY_KEYWORD = {
  scheduling: ["meeting", "schedule", "call", "appointment", "deadline"],
  finance: ["payment", "invoice", "bill", "budget", "cost", "expense"],
  technical: ["bug", "fix", "error", "install", "repair", "maintain"],
  safety: ["safety", "hazard", "inspection", "compliance", "ppe"],
};

const PRIORITY_KEYWORDS = {
  high: ["urgent", "asap", "immediately", "critical", "emergency"],
  medium: ["today", "soon", "this week", "important"],
};

const ACTIONS_BY_CATEGORY = {
  scheduling: [
    "Block calendar",
    "Send invite",
    "Prepare agenda",
    "Set reminder",
  ],
  finance: [
    "Check budget",
    "Get approval",
    "Generate invoice",
    "Update records",
  ],
  technical: [
    "Diagnose issue",
    "Check resources",
    "Assign technician",
    "Document fix",
  ],
  safety: [
    "Conduct inspection",
    "File report",
    "Notify supervisor",
    "Update checklist",
  ],
  general: [],
};

const normalizeText = (text = "") => text.toLowerCase();

//Detect task category based on keyword frequecy
export function detectCategory(text) {
  const normalized = normalizeText(text);
  let bestCategory = "general";
  let maxScore = 0;

  for (const [category, keywords] of Object.entries(CATEGORY_KEYWORD)) {
    const score = keywords.filter((k) => normalized.includes(k)).length;

    if (score > maxScore) {
      maxScore = score;
      bestCategory = category;
    }
  }

  return { category: bestCategory, score: maxScore };
}

//Detect task priority using urgency keywords
export function detectPriority(text) {
  const normalized = normalizeText(text);

  if (PRIORITY_KEYWORDS.high.some((k) => normalized.includes(k))) {
    return "high";
  }

  if (PRIORITY_KEYWORDS.medium.some((k) => normalized.includes(k))) {
    return "medium";
  }
  return "low";
}

// Extract entities like date, person, location and action
export function extractEntities(text = "") {
  const entities = {};

  if (/\btoday\b/i.test(text)) entities.date = "today";
  if (/\btomorrow\b/i.test(text)) entities.date = "tomorrow";
  if (/\bnext week\b/i.test(text)) entities.date = "next week";

  const personMatch = text.match(
    /\b(assign(?:ed)? to|with|by)\s+([A-Za-z]+(?:\s[A-Za-z]+)?)/i
  );
  if (personMatch) entities.person = personMatch[2];

  const locationMatch = text.match(/\b(at|in)\s+([A-Za-z]+(?:\s[A-Za-z]+)?)/i);
  if (locationMatch) entities.location = locationMatch[2];

  const verbs = ["schedule", "fix", "inspect", "pay", "review", "call", "meet"];
  entities.actions = verbs.filter((v) => normalizeText(text).includes(v));

  return entities;
}

export function suggestActions(category) {
  return ACTIONS_BY_CATEGORY[category] || [];
}

// Classify task using title and desciotion
export function classifyTask(title = "", description = "") {
  const combinedText = `${title} ${description}`;

  const categoryResult = detectCategory(combinedText);
  const priority = detectPriority(combinedText);
  const extracted_entities = extractEntities(combinedText);
  const suggested_actions = suggestActions(categoryResult.category);

  return {
    category: categoryResult.category,
    priority,
    extracted_entities,
    suggested_actions,
    metadata: {
      category_score: categoryResult.score,
      priority_reason:
        priority !== "low" ? "Urgency keyword detected" : " No Urgency keyword",
    },
  };
}
