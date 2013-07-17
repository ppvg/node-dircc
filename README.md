# dircc

[![Build Status](https://drone.io/github.com/PPvG/node-dircc/status.png)](https://drone.io/github.com/PPvG/node-dircc/latest) [![Code Coverage](https://drone.io/github.com/PPvG/node-dircc/files/coverage.png)](https://drone.io/github.com/PPvG/node-dircc/files/coverage.html)

Detachable, persistent IRC connection.

The actual connection to the server runs in a detached process, making it possible to reload your IRC client without breaking the connection to the server.

It uses an [ircc `Connection`][ircc] internally, which only handles the connection, not the communication. It doesn't respond to `PING`s, doesn't send `NICK` and `USER` at the start of the session, et cetera.

  [ircc]: https://npmjs.org/package/ircc

#### Example

    var dircc = require('dircc');

    dircc.createConnection('ircc.sock', function(client) {
      client.on('init', function() {
        // called if there is no connection yet, so create one:
        client.connect(6667, 'irc.example.com');
        client.on('connect', function() {
          // registration:
          client.send('NICK', 'MyBoy');
          client.send('USER', 'mybot', 0, 0, 'My Awesome Bot');
        });
      });
      client.on('message', function(message) {
        console.log(message);
        if (message.command === 'WELCOME') {
          client.send('JOIN', '#channel');
        }
      });
    });

#### Installation

`$ npm install dircc`

#### Dependencies

- Node.js 0.9.8 or above.
- [ircc][ircc]
- [dnode][dnode]

  [dnode]: https://github.com/substack/dnode


## API

### dircc(filename, *function(client) {}*)
### dircc.createConnection(filename, *function(client) {}*)

Creates a new ConnectionClient and connects it to the ConnectionServer via the unix socket at `filename`. If there is no server yet, it will be spawned.

The callback is optional and will be called when the ConnectionClient is ready.

Returns an eventemitter:

    var connectionEmitter = dircc('irc.sock');
    connectionEmitter.on('client', function(client) {
      /* ... */
    });

#### connectionEmitter.on('client', function(client) {})

Emitted when the ConnectionClient is ready.

#### connectionEmitter.on('error', function(error) {})

Emitted when there's a problem with the ConnectionServer.


### dircc.ConnectionClient

Connects to the `ConnectionServer` via the unix socket at `filename`:

    var client = new ircc.ConnectionClient(filename);

#### client.connect(...)

Calls the `server`'s `.connect(...)` method.

#### client.close()

Calls the `server`'s `.close()` method.

#### client.send(...)

Calls the `server`'s `.send(...)` method.

#### client.on('message', function(message) {})

Emitted when the ConnectionServer receives a message from the IRC server. The `message` is the same as you would expect from an [ircc][ircc] `Connection` or from the [ircp][ircp] `parser`.

  [ircp]: https://npmjs.org/package/ircp

#### client.on('connect', function() {})

Emitted when the ConnectionServer has a working `Connection` to the IRC server.

**Important:** this event is also emitted when connecting to an **existing** server with an **existing** `Connection`. Therefore it does **not** imply a "freshly made" connection.

#### client.on('init', function() {})

Emitted when connected to a ConnectionServer that doesn't have a `Connection` to an IRC server yet. This is, in essence, a prompt to call `client.connect(...)`:


### dircc.ConnectionServer

Manages a `Connection` and offers an API to communicate with it via a unix socket (using [dnode][dnode]).

    var server = new ircc.ConnectionServer();

#### server.listen(filename)

Start listening to the unix socket at `filename`. If it already exists and can be connected to, the server will emit 'superfluous' and stop.

#### server.connect(port, host)

Create and open `Connection` to IRC server at `host`:`port`.

#### server.close()

Close the `Connection`.

#### server.send(messageObject)
#### server.send(command, [parameters...])

Send an IRC message. See `Connection`.

#### server.on('listening', function() {})

Emitted after the `ConnectionServer` starts listening for clients on the unix socket.

#### server.on('connect', function() {})

Emitted after the `Connection` to the IRC server is created and open.

#### server.on('superfluous', function() {})

Emitted if there's already a server running on the given unix socket.

#### server.on('error', function(error) {})

Emitted when there's a problem with the unix socket server.

#### server.on('close', function() {})

Emitted after the unix socket has been closed.


## License

BSD 2-clause. See [LICENSE](https://github.com/PPvG/node-dircc/blob/master/LICENSE).