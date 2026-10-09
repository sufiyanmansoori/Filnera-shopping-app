function toPublicUser(user) {
  const { password, __v, ...safeUser } = user.toObject ? user.toObject() : user;
  return safeUser;
}

module.exports = { toPublicUser };
