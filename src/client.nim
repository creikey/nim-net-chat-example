import net, common, os

let socket = newSocket()

socket.connect(if commandLineParams().len > 0: commandLineParams()[0] else: "127.0.0.1", port)
echo "Connected"

proc echoWhatsSaid(s: Socket) {.thread.} =
  while true:
    let msg = recvData(s)
    if msg == "":
      echo "Disconnected"
      quit(0)
    echo msg

var echoThread: Thread[Socket]
createThread(echoThread, echoWhatsSaid, socket)

while true:
  let text = readLine(stdin)
  if not sendData(socket, text):
    echo "Could not send data, disconnected. Exiting"
    quit(0)