import sugar
from strformat import fmt
from strutils import replace

type
    PlayerID* = enum
        Default
        Player1
        Player2

    GameResults* = enum
        NO_RESULT = "NO_RESULT"
        WIN = "WIN"
        LOSS = "LOSS"
        DRAW = "DRAW"


    MoveType* = tuple
        y: int
        x: int

    GameBoardGridType = array[3, array[3, PlayerID]]
    
    ResultType* = tuple
        result: GameResults
        player: PlayerID

    GameBoard* = object
        grid* : GameBoardGridType
        result* : ResultType

    InvalidMoveError = object of ValueError


proc reverse_result*(game_result: GameResults): GameResults = 
    case game_result:
    of WIN : result = LOSS
    of LOSS: result = WIN
    else: result = game_result

    return result

proc newGameBoard*(): GameBoard=
    var grid: GameBoardGridType
    return GameBoard(grid: grid)

proc newGameBoard*(grid: GameBoardGridType): GameBoard=
    return GameBoard(grid: grid)

proc pretty_print_grid*(board: GameBoard): string =
    result = $(board.grid)
    result = result.replace("[[", "[")
    result = result.replace("]]", "]")
    result = result.replace("], ", "]\n")
    result = result.replace($(Default), " ")
    result = result.replace($(Player1), "X")
    result = result.replace($(Player2), "O")
    return result

proc can_play(self: GameBoard, y: int, x: int): bool = 
    if not(0 <= x and x < 3) or not(0 <= y and y < 3):
        return false
    return self.grid[y][x] == PlayerID.Default

proc get_valid_moves*(self: GameBoard): seq[MoveType] =
    result = collect(newSeq):
        for y in 0..<3:
            for x in 0..<3:
                if self.can_play(y,x): (y,x)

proc has_valid_moves(self: GameBoard): bool =
    return self.get_valid_moves().len() > 0

proc get_player(self: GameBoard): PlayerID = 
    var player1_move_count, player2_move_count = 0
    for y in 0..2:
        for x in 0..2:
            case self.grid[y][x]:
            of Player1: inc(player1_move_count)
            of Player2: inc(player2_move_count)
            of Default: discard
    
    if player1_move_count > player2_move_count:
        result = Player2
    else:
        result = Player1
    return result


proc next_player*(player: PlayerID): PlayerID = 
    case player:
    of Player1: result = Player2
    of Player2: result = Player1
    else: discard

proc set_draw(self: var GameBoard) = 
    self.result = (GameResults.DRAW, PlayerID.Default)

proc set_win(self: var GameBoard, player: PlayerID) = 
    self.result = (GameResults.WIN, player)

proc has_won(self: GameBoard, player: PlayerID): bool = 
    result = false
    for y in 0..2:
        result = result or (self.grid[y][0] == self.grid[y][1] and self.grid[y][1] == self.grid[y][2] and self.grid[y][2] == player)

    for x in 0..2:
        result = result or (self.grid[0][x] == self.grid[1][x] and self.grid[1][x] == self.grid[2][x] and self.grid[2][x] == player)
    result = result or (self.grid[0][0] == self.grid[1][1] and self.grid[1][1] == self.grid[2][2] and self.grid[2][2] == player)
    result = result or (self.grid[2][0] == self.grid[1][1] and self.grid[1][1] == self.grid[0][2] and self.grid[0][2] == player)


proc terminal_state*(self: GameBoard): bool = 
    return (self.result[0] != GameResults.NO_RESULT) or not self.has_valid_moves()

proc check_if_draw(self: var GameBoard) =
    let is_draw = self.terminal_state() and not(self.has_won(Player1) or self.has_won(Player2))
    if is_draw:
        self.set_draw()

proc check_if_win(self: var GameBoard, player: PlayerID) = 
    let victory = self.has_won(player)
    if victory:
        self.set_win(player)


proc play*(self: GameBoard, move: MoveType, player: PlayerID = PlayerID.Default): GameBoard = 
    if self.terminal_state():
        result = newGameBoard(self.grid)
        result.set_draw()
    
    var player = player
    if player == PlayerID.Default:
        player = self.get_player()
    var grid = self.grid
    var (y,x) = move
    if self.can_play(y, x):
        grid[y][x] = player
    else:
        raise newException(InvalidMoveError, fmt"{y}, {x} is invalid move")
    result = newGameBoard(grid)
    result.check_if_win(player)
    result.check_if_draw()
    return result

# var board = newGameBoard()
# board = board.play((0,0))
# board = board.play((1,1))
# board = board.play((1,2))
# board = board.play((2,0))
# board = board.play((0,2))

# echo board


