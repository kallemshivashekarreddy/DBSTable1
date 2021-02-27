const express = require("express");
const mongoose = require("mongoose");
const morgan = require("morgan");
const app = express();
const cors = require("cors");
const port = 8000;
const Order = require("./orders.model.js");

app.use(cors());
app.use(morgan());
app.use(express.json());

mongoose
  .connect(
    "mongodb+srv://anirudh:5vJLI9g62rWusBUc@cluster0.pjikp.mongodb.net/ecommerce?",
    {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      useCreateIndex: true,
    }
  )
  .then(() => {
    console.log("connection established !");
  });

app.post("/login", () => {});
app.post("/signup", () => {});
app.post("/signout", () => {});

app.post("/order", async (req, res) => {
  const {
    stockName,
    orderQty,
    executedQty,
    price,
    orderStatus,
    orderDate,
  } = req.body;

  let order = new Order({
    stockName,
    orderQty,
    executedQty,
    price,
    orderStatus,
    orderDate,
  });
  order = await order.save();
  return res.status(201).json({ order });
});

app.get("/order", async (req, res) => {
  let { stock, fromDate, toDate } = req.query;

  const orders = Order.find({
    orderDate: {
      $gte: new Date(new Date(fromDate).setHours(00, 00, 00)),
      $lt: new Date(new Date(toDate).setHours(23, 69, 59)),
    },
    stockName: stock,
  });

  return res.status(200).json({
    orders,
  });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}!`);
});
