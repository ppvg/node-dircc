require! dnode
require! events
require! ircc
require! \./SingletonServer

module.exports = class ConnectionServer extends events.EventEmitter
  ~>
    @server = new SingletonServer
    @server.on \connection, @_onClientConnection
    @server.on \listening, @_onListening
    @server.on \superfluous, @_onSuperfluous
    @server.on \error, @_onServerError
    @server.on \close, @_onServerClose
    @connection = null

  listen: (path) ~>
    @server.listen path

  connect: (port, host) ~>
    if not @connection?
      @connection = new ircc.Connection
      @connection.connect port, host
      @connection.on \message, (message) ~>
        @emit \message, message
      @connection.on \connect, ~>
        @emit \connect

  close: ~>
    if @connection? then @connection.close!
    @server.close!

  send: (...args) ~>
    if @connection? then @connection.send ...args

  _onClientConnection: (socket) ~>
    api =
      connect: @connect
      close: @close
      send: @send

    (d = dnode api).on \remote, (remote) ~>
      @on \message, remote~message
      if @connection?
        remote.connect!
      else
        @on \connect, remote~connect
        remote.init!

    socket.pipe d .pipe socket

  _onListening: ~>
    @emit \listening

  _onSuperfluous: ~>
    @emit \superfluous

  _onServerError: (error) ~>
    @emit \error, error

  _onServerClose: ~>
    @emit \close