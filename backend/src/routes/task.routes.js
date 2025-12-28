import express from "express";

import {
  createTask,
  getTask,
  getTaskById,
  updateTask,
  deleteTask,
} from "../controllers/task.controller.js";

//Request validation middleware
import validate from "../middlewares/validate.middleware.js";

//Zod schemas for task validation
import {
  createTaskSchema,
  updateTaskSchema,
} from "../validations/task.validation.js";

const router = express.Router();

/**
 * @swagger
 * /api/tasks:
 *   post:
 *     summary: Create task
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - description
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               assigned_to:
 *                 type: string
 *               due_date:
 *                 type: string
 *     responses:
 *       201:
 *         description: Task created successfully
 */

router.post("/", validate(createTaskSchema), createTask); //Create new task

/**
 * @swagger
 * /api/tasks:
 *   get:
 *     summary: Get tasks
 *     description: Fetch tasks with pagination, filters, search, and summary counts
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           example: 10
 *       - in: query
 *         name: offset
 *         schema:
 *           type: integer
 *           example: 0
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending, in_progress, completed]
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *           enum: [scheduling, finance, technical, safety, general]
 *       - in: query
 *         name: priority
 *         schema:
 *           type: string
 *           enum: [high, medium, low]
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of tasks
 */

router.get("/", getTask); //Fetch all tasks

/**
 * @swagger
 * /api/tasks/{id}:
 *   get:
 *     summary: Get task by ID
 *     description: Fetch a single task using its ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Task ID
 *     responses:
 *       200:
 *         description: Task fetched successfully
 *       404:
 *         description: Task not found
 */
router.get("/:id", getTaskById); //Fetch single task

/**
 * @swagger
 * /api/tasks/{id}:
 *   patch:
 *     summary: Update task
 *     description: Update one or more fields of an existing task
 *     tags:
 *       - Tasks
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Task ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 minLength: 3
 *               description:
 *                 type: string
 *                 minLength: 5
 *               category:
 *                 type: string
 *                 enum: [scheduling, finance, technical, safety, general]
 *               priority:
 *                 type: string
 *                 enum: [high, medium, low]
 *               status:
 *                 type: string
 *                 enum: [pending, in_progress, completed]
 *               assigned_to:
 *                 type: string
 *               due_date:
 *                 type: string
 *                 nullable: true
 *     responses:
 *       200:
 *         description: Task updated successfully
 *       400:
 *         description: Invalid input
 *       404:
 *         description: Task not found
 */
router.patch("/:id", validate(updateTaskSchema), updateTask); //Update task

/**
 * @swagger
 * /api/tasks/{id}:
 *   delete:
 *     summary: Delete task
 *     description: Permanently delete a task by ID
 *     tags:
 *       - Tasks
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Task ID
 *     responses:
 *       200:
 *         description: Task deleted successfully
 *       404:
 *         description: Task not found
 */
router.delete("/:id", deleteTask); // Delete task

export default router;
