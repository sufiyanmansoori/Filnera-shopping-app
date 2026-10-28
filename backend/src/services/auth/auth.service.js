const bcrypt = require('bcryptjs');
const User = require('../../models/User.model');
const { signToken } = require('../../utils/jwt');
const { registerSchema, loginSchema } = require('../../validators/auth.validator');
const AppError = require('../../exceptions/AppError');
const ConflictError = require('../../exceptions/ConflictError');
const AuthenticationError = require('../../exceptions/AuthenticationError');

function validate(schema, value) {
  const { error, value: validated } = schema.validate(value, {
    abortEarly: false,
    stripUnknown: true,
  });
  if (error) throw new AppError(error.details[0].message, 400);
  return validated;
}

function publicUser(user) {
  return {
    id: user._id.toString(),
    email: user.email,
    fullName: user.name,
    roles: user.roles,
  };
}

function issueSession(user) {
  const token = signToken({ sub: user._id.toString(), roles: user.roles });
  return { token, user: publicUser(user) };
}

async function register(input) {
  const data = validate(registerSchema, {
    ...input,
    name: input.name || input.fullName,
    email: typeof input.email === 'string' ? input.email.trim().toLowerCase() : input.email,
  });

  if (await User.exists({ email: data.email })) {
    throw new ConflictError('An account with this email already exists');
  }

  let user;
  try {
    user = await User.create({
      name: data.name.trim(),
      email: data.email,
      phone: data.phone || '',
      password: await bcrypt.hash(data.password, 12),
      roles: ['customer'],
    });
  } catch (error) {
    if (error.code === 11000) {
      throw new ConflictError('An account with this email already exists');
    }
    throw error;
  }
  return issueSession(user);
}

async function login(input) {
  const data = validate(loginSchema, {
    ...input,
    email: typeof input.email === 'string' ? input.email.trim().toLowerCase() : input.email,
  });
  const user = await User.findOne({ email: data.email }).select('+password');
  if (!user || !(await bcrypt.compare(data.password, user.password))) {
    throw new AuthenticationError('Invalid email or password');
  }
  return issueSession(user);
}

module.exports = { register, login };
