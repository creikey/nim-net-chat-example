# nim-net-chat-example
Example of using std/net to make a simple TCP chat server in nim


## the server
Accepts all connections over the port defined in `common.nim` and relays all messages
sent from a client to all other clients connected.x

## the client
Connects to the server, listens for messages from the other clients sent by the server,
and allows the user to send messages to other clients by listening to `stdin`. A python
implementation of this client is in `client.py` as well