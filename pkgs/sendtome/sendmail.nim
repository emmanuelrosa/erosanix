import std/[base64, strutils, tables, sysrand, times]

# Based on a BASH script from:
# https://unix.stackexchange.com/questions/82093/minimal-mta-that-delivers-mail-locally-for-cron
# Converted from BASH to Nim with the assistance of GPT-6 Luna

const spoolDir {.strdefine.}: string = "/tmp/sendtome"

type
  ParsedMessage* = object
    headers*: Table[string, seq[string]]
    body*: string

proc parseMessage*(raw: string): ParsedMessage =
  var separator = raw.find("\r\n\r\n")
  var separatorLength = 4

  let lfSeparator = raw.find("\n\n")
  if lfSeparator >= 0 and (separator < 0 or lfSeparator < separator):
    separator = lfSeparator
    separatorLength = 2

  if separator < 0:
    raise newException(ValueError, "Message has no blank line separating headers and body")

  result.headers = initTable[string, seq[string]]()

  let headerBlock =
    if separator == 0: ""
    else: raw[0 ..< separator]

  let bodyStart = separator + separatorLength
  result.body =
    if bodyStart < raw.len: raw[bodyStart .. ^1]
    else: ""

  var currentName = ""

  for rawLine in headerBlock.split('\n'):
    var line = rawLine

    if line.endsWith("\r"):
      line.setLen(line.len - 1)

    if line.len == 0:
      continue

    # Folded header line: append it to the preceding header.
    if line[0] == ' ' or line[0] == '\t':
      if currentName.len == 0:
        raise newException(ValueError, "Header continuation without a preceding header")

      var values = result.headers[currentName]
      values[^1].add(" " & line.strip())
      result.headers[currentName] = values
      continue

    let colon = line.find(':')
    if colon <= 0:
      raise newException(ValueError, "Malformed header line: " & line)

    currentName = line[0 ..< colon].toLowerAscii()

    let value =
      if colon + 1 < line.len: line[colon + 1 .. ^1].strip()
      else: ""

    var values = result.headers.getOrDefault(currentName)
    values.add(value)
    result.headers[currentName] = values

proc decodeBase64Body*(message: var ParsedMessage) =
  let encodings = message.headers.getOrDefault("content-transfer-encoding")
  if encodings.len == 0 or encodings[0].strip().toLowerAscii() != "base64":
    return

  # MIME Base64 bodies may be line-wrapped. Remove whitespace before decoding.
  var encoded = newStringOfCap(message.body.len)
  for ch in message.body:
    if ch notin {' ', '\t', '\r', '\n'}:
      encoded.add(ch)

  message.body = decode(encoded)
  message.headers["content-transfer-encoding"][0] = "7bit";

proc randomHexId(length: int64): string =
  const HexDigits = "0123456789abcdef"

  let bytes = urandom(length)
  result = newStringOfCap(bytes.len * 2)

  for b in bytes:
    let x = int(b)
    result.add(HexDigits[x shr 4])
    result.add(HexDigits[x and 0x0F])

proc ensureMessageId*(message: var ParsedMessage) =
  if message.headers.hasKey("message-id"):
    return

  message.headers["message-id"] = @["<" & randomHexId(32) & ">"]

proc ensureDate*(message: var ParsedMessage) =
  if message.headers.hasKey("date"):
    return

  message.headers["date"] = @[now().format("ddd, dd MMM yyyy HH:mm:ss ZZZ")]

when isMainModule:
  var filename = $getTime().toUnix() & "." & randomHexId(8)
  var output = newSeq[string](0)
  var message = parseMessage(stdin.readAll())
  message.decodeBase64Body()
  message.ensureMessageId()
  message.ensureDate()

  if message.headers.hasKey("message-id"):
    output.add("Message-ID: " & message.headers["message-id"][0])

  if message.headers.hasKey("date"):
    output.add("Date: " & message.headers["date"][0])

  if message.headers.hasKey("content-type"):
    output.add("Content-Type: " & message.headers["content-type"][0])

  if message.headers.hasKey("mime-version"):
    output.add("MIME-Version: " & message.headers["mime-version"][0])

  if message.headers.hasKey("content-transfer-encoding"):
    output.add("Content-Transfer-Encoding: " & message.headers["content-transfer-encoding"][0])

  if message.headers.hasKey("subject"):
    output.add("Subject: " & message.headers["subject"][0])

  if message.headers.hasKey("from"):
    output.add("From: " & message.headers["from"][0])

  if message.headers.hasKey("to"):
    for rawLine in message.headers["to"]:
      var line = rawLine
      output.add("To: " & line)

  output.add("")
  output.add(message.body)
  var content = output.join("\n")
  writeFile(spoolDir & "/new/" & filename, content)

