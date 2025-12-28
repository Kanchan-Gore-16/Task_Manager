import * as taskService from "../services/task.service.js";

// Create a new task
export const createTask = async (req, res, next) => {
  try {
    const task = await taskService.createTask(req.body);
    res.status(201).json(task);
  } catch (error) {
    next(error); // Forward error to global error handler
  }
};

// Get tasks with filters, search, and pagination
export const getTask = async (req, res, next) => {
  try {
    const task = await taskService.getTasks({ ...req.body, ...req.query });
    res.status(200).json(task);
  } catch (error) {
    next(error);
  }
};

// Get a single task by ID
export const getTaskById = async (req, res, next) => {
  try {
    const task = await taskService.getTaskById(req.params.id);
    res.status(200).json(task);
  } catch (error) {
    next(error);
  }
};

// Update task details by ID
export const updateTask = async (req, res, next) => {
  try {
    const task = await taskService.updateTask(req.params.id, req.body);
    res.status(200).json(task);
  } catch (error) {
    next(error);
  }
};

// Delete a task by ID
export const deleteTask = async (req, res, next) => {
  try {
    const task = await taskService.deleteTask(req.params.id);
    res.status(201).json(task);
  } catch (error) {
    next(error);
  }
};
