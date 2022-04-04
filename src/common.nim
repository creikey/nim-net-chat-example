import net

const port* = Port(3333)

# from flatty/binny library
func readUint32(s: string, i: int): uint32 {.inline.} =
  result = cast[ptr uint32](s[i].unsafeAddr)[]
func addUint32*(s: var string, v: uint32) {.inline.} =
  s.setLen(s.len + sizeof(v))
  cast[ptr uint32](s[s.len - sizeof(v)].addr)[] = v

proc recvData*(s: Socket): string =
  let lengthData = s.recv(4)
  if lengthData == "":
    return ""
  try:
    result = s.recv(lengthData.readUint32(0).int, timeout=1000)
  except TimeoutError:
    echo "Timed out receiving actual data"
    result = ""

proc sendData*(s: Socket, data: string): bool =
  ## returns false on failure
  var msg: string
  msg.addUint32(data.len.uint32)
  msg.add(data)
  result = s.trySend(msg)