function rateLimitDecorator() { return (target, property, descriptor) => descriptor; }
module.exports = rateLimitDecorator;
