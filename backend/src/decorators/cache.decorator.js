function cacheDecorator() { return (target, property, descriptor) => descriptor; }
module.exports = cacheDecorator;
