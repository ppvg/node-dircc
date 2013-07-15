require! stream
should = it
pathToModule = modulePath \protocol, \ParserStream

describe \ParserStream, ->

  should 'be a Transform stream', ->
    @ParserStream.prototype.should.have.property '_transform'

  should 'split the input into lines and emit objects', (done) ->
    ps = new @ParserStream
    count = 0
    ps.on 'data', (data) ->
      data.should.be.an \object
      count += 1
      if count is 3 then done!
      if count > 3 then throw new Error "Too many objects emitted"
    for til 3 then ps.write 'VERSION\r\n'

  should 'parse incoming lines', (done) ->
    ps = new @ParserStream
    ps.write 'VERSION\r\n'
    ps.write 'VERSION\r\n'
    ps.on 'data', (data) ~>
      data.should.equal @mockMessage
    setImmediate ->
      parser.should.have.been.calledTwice
      done!

  beforeEach ->
    parser.reset!
    @mockMessage = { command: 'VERSION' }
    parser.returns @mockMessage

  before ->
    mockery.enable();
    mockery.registerAllowables [\stream pathToModule]
    mockery.registerMock \./parser, parser
    @ParserStream = require pathToModule

  after ->
    mockery.deregisterAll();
    mockery.disable();

  parser = sinon.stub!
  parser.parse = parser