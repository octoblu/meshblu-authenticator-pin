express      = require 'express'
morgan       = require 'morgan'
errorHandler = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
bodyParser   = require 'body-parser'
cors         = require 'cors'
meshblu      = require 'meshblu'
Routes       = require './app/routes'

try
  meshbluJSON  = require './meshblu.json'
catch
  meshbluJSON =
    uuid:   process.env.PIN_AUTHENTICATOR_UUID
    token:  process.env.PIN_AUTHENTICATOR_TOKEN
    server: process.env.MESHBLU_HOST
    port:   process.env.MESHBLU_PORT

port = process.env.PIN_AUTHENTICATOR_PORT ? 80

app = express()
app.use meshbluHealthcheck()
app.use morgan('dev')
app.use errorHandler()
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)
app.use cors()

conn = meshblu.createConnection meshbluJSON
conn.once 'ready', ->
  routes = new Routes app, meshbluJSON.uuid, conn
  routes.register()

  app.listen port, =>
    console.log "listening at localhost:#{port}"

process.on 'SIGTERM', =>
  console.log 'SIGTERM caught, exiting'
  process.exit 0

conn.on 'notReady', ->
  console.error "Unable to establish a connection to meshblu"
