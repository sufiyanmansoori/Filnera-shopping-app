module.exports = () => (req, res, next) => {
  req.ip = req.ip || req.socket.remoteAddress;
  next();
};
