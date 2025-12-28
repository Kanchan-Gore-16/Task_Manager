import { supabase } from "../config/supabase.js";
import { classifyTask } from "../utils/classifier.js";

//Create a task with auto classification
export const createTask = async (reqData) => {
  const { title, description, assigned_to, due_date } = reqData;

  if (!title || !description) {
    throw new Error("Title and description are required");
  }

  const safeAssignedTo = assigned_to || null;

  const safeDueDate = due_date
    ? new Date(due_date).toISOString().split("T")[0]
    : null;

  const classification = classifyTask(title, description);

  const { data, error } = await supabase
    .from("tasks")
    .insert([
      {
        title,
        description,
        assigned_to: safeAssignedTo,
        due_date: safeDueDate,
        category: classification.category,
        priority: classification.priority,
        extracted_entities: classification.extracted_entities || {},
        suggested_actions: classification.suggested_actions || {},
      },
    ])
    .select();

  if (error) {
    console.error("SUPABASE ERROR:", error);
    throw error;
  }

  const task = data?.[0];

  // Store task creation history
  await supabase.from("task_history").insert([
    {
      task_id: task.id,
      action: "created",
      new_value: task,
    },
  ]);

  return task;
};

// Fetch tasks with pagination, filters, search, and status summary
export const getTasks = async ({
  status,
  category,
  priority,
  search,
  limit = 10,
  offset = 0,
}) => {
  const from = Number(offset);
  const to = from + Number(limit) - 1;

  let query = supabase
    .from("tasks")
    .select("*", { count: "exact" })
    .order("created_at", { ascending: false });

  //filters if provided
  if (status) query = query.eq("status", status.toLowerCase());
  if (category) query = query.eq("category", category.toLowerCase());
  if (priority) query = query.eq("priority", priority.toLowerCase());

  //search on title and description
  if (search) {
    query = query.or(`title.ilike.%${search}%,description.ilike.%${search}%`);
  }

  const { data, error, count } = await query.range(from, to);
  if (error) throw error;

  const statuses = ["pending", "in_progress", "completed"];
  const summary = { pending: 0, in_progress: 0, completed: 0 };

  await Promise.all(
    statuses.map(async (s) => {
      let q = supabase
        .from("tasks")
        .select("*", { count: "exact", head: true })
        .eq("status", s);

      if (category) q = q.eq("category", category.toLowerCase());
      if (priority) q = q.eq("priority", priority.toLowerCase());

      if (search) {
        q = q.or(`title.ilike.%${search}%,description.ilike.%${search}%`);
      }

      const { count, error } = await q;
      if (error) throw error;

      summary[s] = count;
    })
  );

  return {
    data,
    meta: {
      total: count,
      limit,
      offset,
      hasMore: from + Number(limit) < count,
    },
    summary,
  };
};

//Fetch single task with history
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

//Update task and record change history
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

//Delete task and its history
export const deleteTask = async (id) => {
  await supabase.from("task_history").delete().eq("task_id", id);

  const { error } = await supabase.from("tasks").delete().eq("id", id);

  if (error) throw error;
};
