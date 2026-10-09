const mongoose = require('mongoose');
const { InventorySchema } = require('./schemas');
module.exports = mongoose.model('Inventory', InventorySchema);
