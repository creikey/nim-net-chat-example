# Package

version       = "0.1.0"
author        = "Cameron Reikes"
description   = "Example of using std/net to make a simple TCP chat server in nim"
license       = "MIT"
srcDir        = "src"
bin           = @["server", "client"]


# Dependencies

requires "nim >= 1.6.0"