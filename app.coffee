'use strict'

path    = require('path')
express = require('express')

app     = express()
server  = require('http').createServer(app)
primus  = new require('primus')(server,
                                redis: { host: 'localhost', port: 6379},
                                transformer: 'websockets')

PrimusRooms = require('primus-rooms')
PrimusRedis = require('primus-redis-rooms')

routes     = require('./routes')
corocket   = require('./lib/corocket')

{debug, info, dispatch} = require('./lib/helpers')

primus.use('rooms', PrimusRooms)  # Remember to use rooms first
primus.use('redis', PrimusRedis)

app.configure ->
  app.set('port', process.env.PORT or 5000)
  app.use(express.favicon())
  app.use(express.logger 'dev')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(app.router)
  app.use(express.static(path.join __dirname, 'out'))

app.configure 'development', ->
  app.use(express.errorHandler())

primus.on 'connection', (spark) ->
  debug 'connected'
  session = undefined

  spark.on 'data', ({type,payload}) ->
    switch type
      when 'join'
        session = corocket.join(payload.nick, payload.channel, spark)
      when 'say', 'away', 'leave', 'busy'
        session[type](payload.msg)
      else
        debug payload[type]

  spark.on 'end', ->
    session?.leave('Goodbye')

server.listen app.get('port')
