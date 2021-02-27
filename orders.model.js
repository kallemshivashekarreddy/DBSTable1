const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema({
  stockName: { type: String, required: true, trim: true },
  orderQty: {
    type: Number,
  },
  orderType: {
    type: String,
  },
  executedQty: {
    type: Number,
  },
  price: { type: Number },
  orderStatus: {
    type: Number,
  },
  orderDate: {
    type: Date,
  },
});

module.exports = mongoose.model("order", orderSchema);
