const CATEGORY_KEYWORD = {
  scheduling: ["meeting", "schedule", "call", "appointment", "deadline"],
  finaance: ["payment", "invoice", "bill", "budget", "cost", "expense"],
  technical: ["bug", "fix", "error", "install", "repair", "maintain"],
  safety: ["safety", "hazard", "inspection", "compliance", "ppe"],
};

const PRIORITY_KEYWORDS = {
  high: ["urgent", "asap", "immediately", "today", "critical", "emergency"],
  mediun: ["soon", "this week", "important"],
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

const normalizeText = (text = "") => text.toLocaleLowerCase();

export function detectCategory(text) {
  const normalized = normalizeText(text);

  for (const category in CATEGORY_KEYWORD) {
    if (CATEGORY_KEYWORD[category].some((k) => normalized.includes(k))) {
      return category;
    }
  }
  return "general";
}

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

export function extractEntities(text = "") {
  const entities = {};

  if (text.match(/\btoday\b/i)) entities.date = "today";
  if (text.match(/\btomorrow\b/i)) entities.date = "tomorrow";

  const personMatch = text.match(/\b(with|by|assign to)\s+([A-Za-z]+)/i);
  if (personMatch) entities.person = personMatch[2];

  const locationMatch = text.match(/\b(at|in)\s+([A-Za-z]+)/i);
  if (locationMatch) entities.location = locationMatch[2];

  return entities;
}

export function suggestActions(category) {
  return ACTIONS_BY_CATEGORY[category] || [];
}

export function classifyTask(title = "", description = "") {
  const combinedText = `${title} ${description}`;

  const category = detectCategory(combinedText);
  const priority = detectPriority(combinedText);
  const extracted_entities = extractEntities(combinedText);
  const suggested_actions = suggestActions(category);

  return {
    category,
    priority,
    extracted_entities,
    suggested_actions,
  };
}
