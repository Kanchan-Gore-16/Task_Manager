const errHandler = (err, req, res, next) => {
  if (err.code) {
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  res
    .status(err.statusCode || 500)
    .json({
      success: false,
      message: err.message || "internal server error ...",
    });
};

export default errHandler;
