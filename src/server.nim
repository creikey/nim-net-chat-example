import net, common

let socket = newSocket()
socket.bindAddr(port)
socket.listen()
echo "Listening on ", port

var messages: Channel[string]
var connected: Channel[Socket]

open messages
open connected

proc listenForMessages(s: Socket) {.thread.} =
  while true:
    echo "Listening for messages..."
    let msg = recvData(s)
    if msg == "":
      echo "Client disconnected"
      break
    echo "Message received from a client: ", msg
    messages.send msg

proc broadcaster() {.thread.} =
  var clients = newSeq[Socket]()
  while true:
    let newMsg = messages.recv

    let numNewConnected = connected.peek
    if numNewConnected == -1:
      break
    for i in 0..numNewConnected-1:
      clients.add(connected.recv)
    
    var clientsToRemove = newSeq[int]()

    for i in 0..high(clients):
      if not sendData(clients[i], newMsg):
        clientsToRemove.add(i)
    
    for c in clientsToRemove:
      clients.del(c)


var broadcasterThread: Thread[void]

createThread(broadcasterThread, broadcaster)

var listenThreads = newSeq[Thread[Socket]]()
while true:
  var newClient: Socket
  var address = ""
  socket.acceptAddr(newClient, address)
  echo "Client connected from: ", address
  connected.send newClient

  listenThreads.add(Thread[Socket]())
  createThread(listenThreads[high(listenThreads)], listenForMessages, newClient)
