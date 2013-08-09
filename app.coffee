###
Module dependencies.
###
express       = require "express"
coffee        = require 'coffee-script'
routes        = require "./routes/index"
firms         = require "./routes/firms"
orders        = require "./routes/orders"
curiers       = require "./routes/curiers"
manager       = require "./routes/manager"
models        = require "./models/db"
path          = require "path"
fs            = require 'fs'
connect       = require 'connect'
assets        = require 'connect-assets'
connectDomain = require 'connect-domain'
mongoose      = require 'mongoose'
MongoStore    = require('connect-mongo')(express)

####
## USERS BASE FUNCTIONALITY
####
flash         = require('connect-flash')
passport      = require('passport')
LocalStrategy = require('passport-local').Strategy

passport.serializeUser (user, done) ->
  done null, user.id

passport.use new LocalStrategy (username, password, done) ->
  models.User.findOne
    'username': username
  , (err, user) ->
    console.log user
    return done(err)  if err
    unless user
      return done(null, false,
        message: "Incorrect username."
      )
    unless user.password is password
      return done(null, false,
        message: "Incorrect password."
      )
    done null, user

ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated() 
    return next()
  res.redirect('/login')

passport.deserializeUser (id, done) ->
  models.User.findById id, (err, user) ->
    done err, user

conf =
  db:
    db: "curier"
    host: "192.168.0.1"
  secret: "076ee61d63aa10a125ea872411e433b9"

####
## MAIN APP CODE
####

mongoose.connect 'mongodb://localhost/curier'

# dbref = require "mongoose-dbref"
# utils = dbref.utils
# loaded = dbref.install mongoose

app = express()

# all environments
app.set "port", process.env.PORT or 2500
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.set 'view options', {
  layout: false
}
app.use express.favicon('/public/images/favicon.ico')
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use assets()
app.use express.cookieParser("your secret here")
app.use express.session(
  secret: conf.secret
  maxAge: new Date(Date.now() + 3600000)
  store: new MongoStore({ host: '127.0.0.1', port: 27017, db: 'curier', collection: 'sessions' })
)
app.use connectDomain()
app.use flash()
app.use passport.initialize()
app.use passport.session()
app.use app.router
app.use connect.static(__dirname + '/assets')
app.use express.static(__dirname + '/assets')

app.use (err, req, res, next) ->
  console.log  err
  res.send 500, "Houston, we have a problem!\n"

app.use express.errorHandler() if "development" is app.get("env")

#
# Main route
#
app.get "/", ensureAuthenticated, routes.index
###### ensureAuthenticated


#
# Firms routes
#
app.get    "/data/firm/", ensureAuthenticated, firms.index
app.get    "/data/firm/:id", ensureAuthenticated, firms.certain_firm
app.post   "/data/firm/", ensureAuthenticated, firms.create_firm
app.delete "/data/firm/:id", ensureAuthenticated, firms.delete_firm
app.post   "/data/firm/:id", ensureAuthenticated, firms.update_firm

#
# Orders routes
#
app.get    "/data/order/", ensureAuthenticated, orders.index
app.get    "/data/order/:id", ensureAuthenticated, orders.certain_order
app.post   "/data/order/", ensureAuthenticated, orders.create_order
app.delete "/data/order/:id", ensureAuthenticated, orders.delete_order
app.post   "/data/order/:id", ensureAuthenticated, orders.update_order
app.get    "/data/order/firm/:id", ensureAuthenticated, orders.orders_for_firm
app.get    "/data/order/curier/:id", ensureAuthenticated, orders.orders_for_curier

app.get    "/data/chart/order/", ensureAuthenticated, orders.orders_chart
app.get    "/data/chart/order/:range", ensureAuthenticated, orders.orders_chart

app.get    "/data/report/order/day/all/", ensureAuthenticated, orders.orders_total_day_all
app.get    "/data/report/order/day/all/:date", ensureAuthenticated, orders.orders_total_day_all
app.get    "/data/report/order/firm/:id", ensureAuthenticated, orders.orders_total_day_firm
app.get    "/data/report/order/day/total/", ensureAuthenticated, orders.orders_total_day
app.get    "/data/report/order/day/total/", ensureAuthenticated, orders.orders_total_day
app.get    "/data/report/order/day/total/:date", ensureAuthenticated, orders.orders_total_day
app.get    "/data/report/order/month/total/", ensureAuthenticated, orders.orders_total_month
app.get    "/data/report/order/month/total/:date", ensureAuthenticated, orders.orders_total_month

#
# Curiers routes
#
app.get    "/data/curier/", ensureAuthenticated, curiers.index
app.get    "/data/curier/:id", ensureAuthenticated, curiers.certain_curier
app.post   "/data/curier/", ensureAuthenticated, curiers.create_curier
app.delete "/data/curier/:id", ensureAuthenticated, curiers.delete_curier
app.post   "/data/curier/:id", ensureAuthenticated, curiers.update_curier


#
# View routes
#
app.get "/partials/:name", routes.partials
app.get "/template/:folder/:name", routes.templates

#
# Auth routes
#
app.get '/login', manager.login
app.get '/logout', manager.logout
app.post '/login', passport.authenticate 'local', { successRedirect: '/', failureRedirect: '/login', failureFlash: true}

#
# Helprer routes for views
#
app.get "/firm/*", ensureAuthenticated, routes.index
app.get "/order/*", ensureAuthenticated, routes.index
app.get "/curier/*", ensureAuthenticated, routes.index
app.get "/reports/*", ensureAuthenticated, routes.index


app.listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")