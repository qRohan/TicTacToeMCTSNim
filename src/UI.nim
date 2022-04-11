import illwill

proc exitProc*() {.noconv.} =
  illwillDeinit()
  showCursor()
  quit(0)

setControlCHook(exitProc)
illwillInit(mouse=true)


proc drawBoard*(tb: var TerminalBuffer) = 
    hideCursor()
    var bb = newBoxBuffer(tb.width, tb.height)
    drawHorizLine(bb, 2, 14, 4)
    drawHorizLine(bb, 2, 14, 6)
    drawVertLine(bb, 6, 2, 8)
    drawVertLine(bb, 10, 2, 8)
    tb.write(bb)


proc isWithinBoard(x: Natural, y: Natural): bool=
    result = (x in 2..14) and (y in 2..8)

proc getMoveFromCoord(x: 2..14, y: 2..8): tuple[y: int, x: int] = 
    var resY , resX: int
    case x:
        of 2..5: resX = 0
        of 7..9: resX = 1
        of 11..14: resX = 2
        else: resX = -1

    case y:
        of 2..3: resY = 0
        of 5: resY = 1
        of 7..8: resY = 2
        else: resY = -1
    
    result = (y: resY, x: resX)

proc getMove*(): tuple[y: int, x: int] = 
    while true:
        var key = getKey()
        if key == Key.Mouse:
            let mouse = getMouse()
            if mouse.button == mbLeft and mouse.action == mbaPressed:
                if isWithinBoard(mouse.x, mouse.y):
                    result =  getMoveFromCoord(mouse.x, mouse.y)
                    if result.x != -1 and result.y != -1:
                        return

proc drawMove*(tb: var TerminalBuffer, move: tuple[y: int, x: int], character: string) = 
    var 
        yPos = 3 + move.y * 2
        xPos = 4 + move.x * 4

    tb.setCursorPos(xPos, yPos)
    tb.write(character)

proc display_terminal_message*(tb: var TerminalBuffer, message: string, color: ForegroundColor = fgWhite )=
    var 
        xPos = 2
        yPos = 10

    tb.setForegroundColor(color)
    tb.setCursorPos(xPos, yPos)
    tb.write(message)
    tb.display()
    

proc newTerminalBuffer*(): TerminalBuffer=
    return newTerminalBuffer(terminalWidth(), terminalHeight())

# var tb = newTerminalBuffer(terminalWidth(), terminalHeight())
# drawBoard(tb)


# tb.setForegroundColor(fgRed, bright=true)
# tb.setCursorPos(4, 3)
# tb.write("X")
# tb.setCursorPos(4, 5)
# tb.write("O")
# tb.setCursorPos(4, 7)
# tb.write("O")
# tb.display()
# tb.setCursorPos(20, 20)

    

