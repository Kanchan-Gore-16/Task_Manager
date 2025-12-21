import * as taskService from "../services/task.service.js";

export const createTask = async (req, res, next) => {
  try {
    const task = await taskService.createTask(req.body);
    res.status(201).json(task);
  } catch (error) {
    next(error);
  }
};

export const getTask = async (req, res, next) => {
  try {
    const task = await taskService.getTask(req.body);
    res.status(200).json(task);
  } catch (error) {
    next(error);
  }
};

export const getTaskById = async (req, res, next) => {
  try {
    const task = await taskService.getTaskById(req.body);
    res.status(200).json(task);
  } catch (error) {
    next(error);
  }
};

export const updateTask = async (req, res, next) => {
  try {
    const task = await taskService.updateTask(req.params.id, req.body);
    res.status(200).json(task);
  } catch (error) {
    next(error);
  }
};

export const deleteTask = async (req, res, next) => {
  try {
    const task = await taskService.deleteTask(req.params.id);
    res.status(201).json(task);
  } catch (error) {
    next(error);
  }
};
