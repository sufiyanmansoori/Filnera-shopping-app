function authDecorator() { return (target, property, descriptor) => descriptor; }
module.exports = authDecorator;
