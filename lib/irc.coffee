irc = require 'slate-irc'
net = require 'net'

logger = ->
  (irc) ->
    irc.stream.pipe process.stdout

join = (nick, channel) ->
  channel = "##{channel}" unless channel[0] is "#"
  stream = net.connect port: 6667, host: 'irc.freenode.org'
  client = irc stream
  client.use logger
  client.nick nick
  client.user nick, "Nomen Nescio"
  client.join channel
  client

say = (client, channel, msg) ->
  client.send channel, msg

module.exports =
  join: join
  say: say