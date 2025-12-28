const errHandler = (err, req, res, next) => {
  // Handle validation or known application errors
  if (err.code) {
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  // Fallback for unhandled or server errors
  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || "internal server error ...",
  });
};

export default errHandler;
