import net, common

let socket = newSocket()
socket.bindAddr(port)
socket.listen()
echo "Listening on ", port

type ClientId = distinct int
proc `==` *(a, b: ClientId): bool {.borrow.}
proc `$` *(a: ClientId): string {.borrow.}

type Client = object
  id: ClientId
  s: Socket

type Message = object
  sender: ClientId
  text: string

var messages: Channel[Message]
var connected: Channel[Client]

open messages
open connected

proc listenForMessages(c: Client) {.thread.} =
  while true:
    echo "Listening for messages..."
    let msg = recvData(c.s)
    if msg == "":
      echo "Client disconnected"
      break
    echo "Message received from a client: ", msg
    messages.send Message(sender: c.id, text: msg)

proc broadcaster() {.thread.} =
  var clients = newSeq[Client]()
  while true:
    let newMsg: Message = messages.recv

    let numNewConnected = connected.peek
    if numNewConnected == -1:
      break
    for i in 0..numNewConnected-1:
      clients.add(connected.recv)
    
    var clientsToRemove = newSeq[int]()

    for i in 0..high(clients):
      if clients[i].id != newMsg.sender and not sendData(clients[i].s, newMsg.text):
        clientsToRemove.add(i)
    
    for c in clientsToRemove:
      clients.del(c)


var broadcasterThread: Thread[void]

createThread(broadcasterThread, broadcaster)

var listenThreads = newSeq[Thread[Client]]()
var nextClientId = 0
while true:
  var newClient: Client
  newClient.id = nextClientId.ClientId
  var address = ""
  socket.acceptAddr(newClient.s, address)
  echo "Client connected from: ", address
  connected.send newClient

  listenThreads.add(Thread[Client]())
  createThread(listenThreads[high(listenThreads)], listenForMessages, newClient)
  nextClientId += 1