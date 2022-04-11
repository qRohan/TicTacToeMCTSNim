import illwill, UI
import TicTacToe
from MCTS import newMCTS, run_mcts


proc get_player_character(ID: PlayerID): string =
    case ID 
        of Player1: result = "X"
        of Player2: result = "O" 
        of Default: result = " " 

proc draw(tb : var TerminalBuffer, board: GameBoard) =  
    let grid = board.grid
    tb.drawBoard()
    for y in 0..2:
        for x in 0..2:
            tb.drawMove((y: y, x: x), get_player_character(grid[y][x]))
    tb.display()



var tb = newTerminalBuffer()
var board = newGameBoard()
tb.draw(board)
while true:
    tb = newTerminalBuffer()
    var move = getMove()
    board = board.play(move)
    tb.draw(board)
    if board.result.result != NO_RESULT:
        if board.result.result == DRAW:
            tb.display_terminal_message("DRAW")
        else:
            tb.display_terminal_message("Player Wins", fgGreen)
        break

    var mcts = newMCTS(board, PlayerID(2), 2000)
    var cpu_move = mcts.run_mcts()
    board = board.play(cpu_move)
    tb.draw(board)  
    if board.result.result != NO_RESULT:
        if board.result.result == DRAW:
            tb.display_terminal_message("DRAW")
        else:
            tb.display_terminal_message("Computer Wins", fgRed)
        break

while true:
    var key = getKey()
    case key
        of Key.Escape, Key.Q: exitProc()
        else: discard