import { supabase } from "../config/supabase.js";
import { classifyTask } from "../utils/classifier.js";

export const createTask = async (data) => {
  const { title, description, assigned_to, due_date } = data;

  if (!title || !description) {
    throw new Error("Title and description are required");
  }

  const safeAssignedTo = assigned_to || null;

  const safeDueDate = due_date
    ? new Date(due_date).toISOString().split("T")[0]
    : null;
  const classification = classifyTask(title, description);

  const { data: error } = await supabase.from("tasks").insert([
    {
      title,
      description,
      assigned_to: safeAssignedTo,
      due_date: safeDueDate,
      category: classification.category,
      priority: classification.priority,
      extracted_entities: classification.extracted_entities || [],
      suggested_actions: classification.suggested_actions || {},
    },
  ]);
  if (error) {
    console.error("SUPABASE ERROR:", error);
    throw error;
  }

  const task = data?.[0];

  await supabase.from("task_history").insert([
    {
      task_id: task.id,
      action: "created",
      new_value: task,
    },
  ]);

  return task;
};

export const getTasks = async ({
  status,
  category,
  priority,
  limit = 10,
  offset = 0,
}) => {
  let query = supabase.from("tasks").select("*");

  if (status) query = query.eq("status", status);
  if (category) query = query.eq("category", category);
  if (priority) query = query.eq("priority", priority);

  const { data, error } = await query
    .range(Number(offset), Number(offset) + Number(limit) - 1)
    .order("created_at", { ascending: false });

  if (error) throw error;

  return data;
};

export const getTaskById = async (id) => {
  const { data: task, error } = await supabase
    .from("tasks")
    .select("*")
    .eq("id", id)
    .single();

  if (error) throw error;

  const { data: history } = await supabase
    .from("task_history")
    .select("*")
    .eq("task_id", id)
    .order("changed_at", { ascending: false });

  return { ...task, history };
};

export const updateTask = async (id, updates) => {
  const { data: oldTask } = await supabase
    .from("tasks")
    .select("*")
    .eq("id", id)
    .single();

  const { data: updatedTask, error } = await supabase
    .from("tasks")
    .update(updates)
    .eq("id", id)
    .select()
    .single();

  if (error) throw error;

  await supabase.from("task_history").insert([
    {
      task_id: id,
      action: "updated",
      old_value: oldTask,
      new_value: updatedTask,
    },
  ]);

  return updatedTask;
};

export const deleteTask = async (id) => {
  await supabase.from("task_history").delete().eq("task_id", id);

  const { error } = await supabase.from("tasks").delete().eq("id", id);

  if (error) throw error;
};
