import express from "express";
import cors from "cors";
import dotenv from "dotenv";

import taskRoutes from "./routes/task.routes.js";
import errHandler from "./middlewares/error.middleware.js";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res
    .status(200)
    .json({ status: "sucess", message: "smart task manager API is running" });
});

app.use("/api/tasks", taskRoutes);

app.use(errHandler);

export default app;
