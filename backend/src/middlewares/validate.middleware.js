import { ZodError } from "zod";

// Middleware to validate request body using Zod schema
const validate = (schema) => (req, res, next) => {
  try {
    schema.parse(req.body);
    next();
  } catch (error) {
    if (error instanceof ZodError) {
      return res.status(400).json({
        success: false,
        message: error.issues.map((issue) => issue.message),
      });
    }

    next(error); // Forward unexpected errors to global handler
  }
};

export default validate;
