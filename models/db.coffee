mongoose = require 'mongoose'
mongoose.set('debug', true)

firmSchema  = new mongoose.Schema
  title:       String
  info:        String
  adress:      String
  phone:       String
  fixed_pay:   Boolean
  pay_amount:  Number

orderSchema = new mongoose.Schema
  date:            { type: Date, default: Date.now }
  day_of_week:     String
  firm:            { type : mongoose.Schema.ObjectId, ref : 'firm' }
  delivery_adress: String
  order_summ:      Number
  delivery_cost:   Number
  curier:          { type : mongoose.Schema.ObjectId, ref : 'curier' }
  comment:         String
  outside:         Boolean
  curier_income:   Number

curierSchema = new mongoose.Schema
  name:         String
  phone:        String

userSchema = new mongoose.Schema
  password:     String
  username:     String

User     = mongoose.model 'user', userSchema
Order    = mongoose.model 'order', orderSchema
Firm     = mongoose.model 'firm', firmSchema
Curier   = mongoose.model 'curier', curierSchema

exports.User   = User
exports.Firm   = Firm
exports.Order  = Order
exports.Curier = Curier