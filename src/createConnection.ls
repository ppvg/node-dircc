require! net
require! path
require! events
{spawn} = require \child_process
require! \./ConnectionServer
require! \./ConnectionClient

calledDirectly = module is require.main

if not calledDirectly
  module.exports = createConnection = (filename, callback) ->
    ee = new events.EventEmitter
    filename = path.resolve (filename || \ircc.sock)
    server = spawn \node, [module.filename, filename], { detached: true }
    server.unref!

    server.stdout.on \data, (data) ->
      data = data.toString!
      ready = data is \listening or data is \superfluous
      if ready
        socket = net.createConnection filename
        client = new ConnectionClient socket
        ee.emit \client, client
        if typeof callback is \function then callback client
      else
        ee.emit \error, new Error "Unexpected server output: #{data}"

    server.stderr.on \data, (data) ->
      ee.emit \error, new Error data.toString!

    ee

else
  server = new ConnectionServer
  server.on \listening, ->
    process.stdout.write \listening
  server.on \superfluous, ->
    process.stdout.write \superfluous
  server.on \error, (e) ->
    process.stderr.write \error:, e
    process.exit 1
  server.on \close, ->
    process.exit 0

  server.listen process.argv[2]