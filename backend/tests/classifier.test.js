import {
  detectCategory,
  detectPriority,
  extractEntities,
  classifyTask,
} from "../src/utils/classifier.js";

describe("Task Classification Logic", () => {
  test("should detect scheduling category", () => {
    const text = "Schedule meeting with team";
    const category = detectCategory(text);
    expect(category).toBe("scheduling");
  });

  test("should assign high priority for urgent tasks", () => {
    const text = "Urgent bug fix needed today";
    const priority = detectPriority(text);
    expect(priority).toBe("high");
  });

  test("should extract entities from text", () => {
    const text = "Meeting today with John at office";
    const entities = extractEntities(text);

    expect(entities).toHaveProperty("date", "today");
    expect(entities).toHaveProperty("person", "John");
    expect(entities).toHaveProperty("location", "office");
  });

  test("should classify task completely", () => {
    const result = classifyTask(
      "Urgent meeting today",
      "Schedule meeting with team about budget"
    );

    expect(result.category).toBe("scheduling");
    expect(result.priority).toBe("high");
    expect(result.suggested_actions.length).toBeGreaterThan(0);
  });
});
