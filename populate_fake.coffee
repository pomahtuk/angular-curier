mongoose = require 'mongoose'
Faker    = require 'Faker'
models   = require('./models/db')
require 'date-utils'
#mongoose.set('debug', true)

# firmSchema  = new mongoose.Schema
#   title:       String
#   info:        String
#   adress:      String

# orderSchema = new mongoose.Schema
#   date:           { type: Date, default: Date.now }
#   day_of_week:    String
#   firm:           { type : mongoose.Schema.ObjectId, ref : 'firm' }
#   order_summ:     Number
#   delivery_cost:  Number
#   curier:         { type : mongoose.Schema.ObjectId, ref : 'curier' }

# curierSchema = new mongoose.Schema
#   name:         String

# Order    = mongoose.model 'order', orderSchema
# Firm     = mongoose.model 'firm', firmSchema
# Curier   = mongoose.model 'curier', curierSchema

mongoose.connect 'mongodb://localhost/curier'

curiers = []
firms   = []
orders  = []

for i in [0..4]
  curier = {
    name:  Faker.Name.findName()
    phone: Faker.PhoneNumber.phoneNumber()
  }

  number_bool = Faker.random.number(1)
  if number_bool is 1 
    fixed_pay  = true 
    pay_amount = Faker.random.number(10000)
  else 
    fixed_pay  = false
    pay_amount = 0

  firm = {
    title:      Faker.Company.companyName()
    info:       Faker.Lorem.paragraph()
    adress:     Faker.Address.streetAddress()
    phone:      Faker.PhoneNumber.phoneNumber()
    fixed_pay:  fixed_pay
    pay_amount: pay_amount
  }

  firm = new models.Firm(firm)
  firm.save()
  firms.push firm

  curier = new models.Curier(curier)
  curier.save()
  curiers.push curier

for firm in firms
  for curier in curiers
    date = new Date().addDays(Faker.random.number(6))  

    number_bool = Faker.random.number(1)
    if number_bool is 1 
      outside       = true 
      curier_income = Faker.random.number(10000)
    else 
      outside       = false
      curier_income = 0

    order = {
      date:            date
      day_of_week:     date.getDay()
      firm:            firm._id
      order_summ:      Faker.random.number(10000)
      delivery_cost:   Faker.random.number(1000)
      curier:          curier._id
      outside:         outside
      curier_income:   curier_income
      delivery_adress: Faker.Address.streetAddress()
      comment:         Faker.Lorem.paragraph()
    }

    order = new models.Order(order)
    order.save()
    console.log order