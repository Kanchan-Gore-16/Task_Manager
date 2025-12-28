import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import swaggerUi from "swagger-ui-express";
import { swaggerSpec } from "../swagger.js";
import taskRoutes from "./routes/task.routes.js";
import errHandler from "./middlewares/error.middleware.js";

dotenv.config();

const app = express();

app.use(cors());

// Parse incomming JSON and form data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res
    .status(200)
    .json({ status: "sucess", message: "smart task manager API is running" });
});

app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec)); // Swagger API documentation
app.use("/api/tasks", taskRoutes); // API routes

// Global error tandling middleware
app.use(errHandler);

export default app;
