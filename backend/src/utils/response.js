function successResponse(res, statusCode = 200, data = null, message = 'Success') {
  return res.status(statusCode).json({ success: true, message, data });
}

function errorResponse(res, statusCode = 500, message = 'Something went wrong', errors = null) {
  return res.status(statusCode).json({ success: false, message, errors });
}

module.exports = { successResponse, errorResponse };
