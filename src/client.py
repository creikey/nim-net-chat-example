import socket
import sys
import threading
from sys import argv

def listen_thread(s):
  while True:
    s.settimeout(None)
    dataLen = int.from_bytes(s.recv(4), sys.byteorder)
    s.settimeout(1.0)
    data = bytearray()
    while len(data) < dataLen:
      newData = s.recv(dataLen - len(data))
      if newData == r"":
        print("Disconnected")
        return
      data.extend(newData)
    print(data.decode("utf-8"))

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
  s.connect((argv[1] if len(argv) > 1 else "127.0.0.1", 3333))
  threading.Thread(target=listen_thread, args=(s,), daemon=True).start()

  while True:
    toSend = input("")
    encoded = toSend.encode("utf-8")
    s.sendall(len(encoded).to_bytes(4, sys.byteorder) + encoded)
