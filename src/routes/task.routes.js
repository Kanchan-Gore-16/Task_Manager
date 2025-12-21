import express from "express";

import {
  createTask,
  getTask,
  getTaskById,
  updateTask,
  deleteTask,
} from "../controllers/task.controller.js";

import validate from "../middlewares/validate.middleware.js";

import {
  createTaskSchema,
  updateTaskSchema,
} from "../validations/task.validation.js";

const router = express.Router();

router.post("/", validate(createTaskSchema), createTask);
router.get("/", getTask);
router.get("/:id", getTaskById);
router.patch("/:id", validate(updateTaskSchema), updateTask);
router.delete("/:id", deleteTask);

export default router;
