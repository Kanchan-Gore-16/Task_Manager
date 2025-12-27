import swaggerJsdoc from "swagger-jsdoc";

export const swaggerSpec = swaggerJsdoc({
  definition: {
    openapi: "3.0.0",
    info: {
      title: "Task Manager API",
      version: "1.0.0",
      description: "API documentation for Smart Task Manager",
    },
    servers: [
      {
        url: "http://localhost:5001",
        description: "Local server",
      },
    ],
  },
  apis: ["./src/routes/task.routes.js"],
});
