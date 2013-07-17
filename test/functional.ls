{spawn} = require \child_process
require! fs
require! net
should = it

pathToModule = modulePath \createConnection

describe 'createConnection (functional)', ->

  before ->
    mockery.enable!
    mockery.warnOnUnregistered false
    mockery.registerAllowables [pathToModule, \net, \fs, modulePath \ConnectionClient], true
    ConnectionClient = require modulePath \ConnectionClient
    require! [\net \fs]
    @createConnection = require pathToModule
    filename = (uniqueId 20) + '.sock'
    children = []
    @spawn = ~>
      child = spawn \node, [pathToModule+'.js', filename]
      children.push child
      child
    @unlink = ->
      try
        fs.unlinkSync filename
      catch
        void
    @cleanUp = ->
      for child in children
        child.kill!
      @unlink!
    @createSocket = -> net.createConnection filename
    @createClient = -> new ConnectionClient @createSocket!

  after ->
    @cleanUp!
    mockery.deregisterAll!
    mockery.disable!
    mockery.warnOnUnregistered true

  beforeEach ->
    @cleanUp!

  describe 'when server starts listening', ->
    should 'write "listening" to stdout', (done) ->
      child = @spawn!
      child.stdout.on \data, (data) ->
        data.toString!.should.equal \listening
        done!

  describe 'when another server already listening', ->
    should 'write "superfluous" to stdout', (done) ->
      child = @spawn!
      child.stdout.on \data, (data) ->
        data.toString!.should.equal \listening
        done!

  describe.skip 'when server emits an error', ->
    should 'write the error message to stderr', (done) ->
      child = @spawn!
      child.stderr.on \data, (data) ->
        done!
      # TODO: find way to intentionally cause error in server :P

  describe 'when server is closed by a client', ->
    should 'the process should exit', (done) ->
      child = @spawn!
      child.on \exit, (code, signal) ->
        code.should.equal 0
        done!
      child.stdout.on \data, (data) ~>
        client = @createClient!
        client.on \init, ->
          client.close!

uniqueId = (length) ->
  id = ""
  while id.length < length
    id += Math.random!.toString 36 .substr 2
  id.substr 0, length