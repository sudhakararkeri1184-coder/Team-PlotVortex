import 'package:flutter/material.dart';
import 'package:v2/chess_screen/chess_ChallengeMode/vsComp/models/piece.dart';
// import 'package:offline_2d_chess/models/piece.dart';
import 'components/square.dart';
import 'components/dead_piece.dart';
import 'helpers/helper.dart';
import 'chess_ai.dart';

class CompGameBoard extends StatefulWidget {
  const CompGameBoard({super.key});

  @override
  State<CompGameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<CompGameBoard> {
  late List<List<ChessPiece?>> board;

  int selectedRow = -1;
  int selectedCol = -1;
  ChessPiece? selectedPiece;
  List<List<int>> validMoves = [];

  bool whiteTurn = true;
  bool checkStatus = false;

  List<ChessPiece> whiteDeadPieces = [];
  List<ChessPiece> blackDeadPieces = [];

  late List<int> whiteKingPos;
  late List<int> blackKingPos;

  final ChessAI _ai = ChessAI();
  List<Map<String, dynamic>> moveHistory = [];

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    board = List.generate(8, (i) => List<ChessPiece?>.filled(8, null));

    for (int i = 0; i < 8; i++) {
      board[1][i] = ChessPiece(ChessPieceType.pawn, false);
    }
    for (int i = 0; i < 8; i++) {
      board[6][i] = ChessPiece(ChessPieceType.pawn, true);
    }

    board[0][0] = ChessPiece(ChessPieceType.rook, false);
    board[0][7] = ChessPiece(ChessPieceType.rook, false);
    board[7][0] = ChessPiece(ChessPieceType.rook, true);
    board[7][7] = ChessPiece(ChessPieceType.rook, true);

    board[0][1] = ChessPiece(ChessPieceType.knight, false);
    board[0][6] = ChessPiece(ChessPieceType.knight, false);
    board[7][1] = ChessPiece(ChessPieceType.knight, true);
    board[7][6] = ChessPiece(ChessPieceType.knight, true);

    board[0][2] = ChessPiece(ChessPieceType.bishop, false);
    board[0][5] = ChessPiece(ChessPieceType.bishop, false);
    board[7][2] = ChessPiece(ChessPieceType.bishop, true);
    board[7][5] = ChessPiece(ChessPieceType.bishop, true);

    board[0][3] = ChessPiece(ChessPieceType.queen, false);
    board[7][3] = ChessPiece(ChessPieceType.queen, true);

    board[0][4] = ChessPiece(ChessPieceType.king, false);
    board[7][4] = ChessPiece(ChessPieceType.king, true);

    whiteKingPos = [7, 4];
    blackKingPos = [0, 4];

    whiteDeadPieces.clear();
    blackDeadPieces.clear();

    selectedRow = -1;
    selectedCol = -1;
    selectedPiece = null;
    validMoves = [];
    whiteTurn = true;
    checkStatus = false;
    moveHistory.clear();

    setState(() {});
  }

  bool isValidMove(int row, int col) {
    for (var move in validMoves) {
      if (move[0] == row && move[1] == col) return true;
    }
    return false;
  }

  void onSquareTap(int row, int col) {
    if (!whiteTurn) return;

    final tappedPiece = board[row][col];

    if (selectedPiece == null) {
      if (tappedPiece != null && tappedPiece.isWhite == whiteTurn) {
        selectPiece(row, col);
      }
    } else {
      if (tappedPiece != null &&
          tappedPiece.isWhite == selectedPiece!.isWhite) {
        selectPiece(row, col);
      } else if (isValidMove(row, col)) {
        movePiece(row, col);
      } else {
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
        setState(() {});
      }
    }
  }

  void selectPiece(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    selectedPiece = board[row][col];
    validMoves = calculateRealValidMoves(row, col, selectedPiece!, true);
    setState(() {});
  }

  void movePiece(int newRow, int newCol) {
    if (selectedPiece == null) return;

    // ✅ FIX: Explicitly cast the lists to correct type
    moveHistory.add({
      'fromRow': selectedRow,
      'fromCol': selectedCol,
      'toRow': newRow,
      'toCol': newCol,
      'piece': selectedPiece,
      'capturedPiece': board[newRow][newCol],
      'whiteKingPos': List<int>.from(whiteKingPos),
      'blackKingPos': List<int>.from(blackKingPos),
      // ✅ Changed: Cast to List<ChessPiece>
      'whiteDeadPieces': List<ChessPiece>.from(whiteDeadPieces),
      'blackDeadPieces': List<ChessPiece>.from(blackDeadPieces),
      'wasWhiteTurn': whiteTurn,
    });

    // Capture if enemy piece exists
    final targetPiece = board[newRow][newCol];
    if (targetPiece != null) {
      if (targetPiece.isWhite) {
        whiteDeadPieces.add(targetPiece);
      } else {
        blackDeadPieces.add(targetPiece);
      }
    }

    // Move piece on board
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Update king position if moved
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPos = [newRow, newCol];
      } else {
        blackKingPos = [newRow, newCol];
      }
    }

    // Reset selection state
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];

    // Check if king is in check after move
    checkStatus = isKingInCheck(whiteTurn);

    // Check for checkmate
    if (checkStatus) {
      if (isCheckmate(!whiteTurn)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _buildCheckmateDialog(),
        );
      }
    }

    // Change turns
    whiteTurn = !whiteTurn;

    setState(() {});

    if (!whiteTurn) {
      Future.delayed(const Duration(milliseconds: 500), _makeAIMove);
    }
  }

  void _undoSingleMove() {
    if (moveHistory.isEmpty) return;

    final lastMove = moveHistory.removeLast();

    // Restore piece positions
    board[lastMove['fromRow']][lastMove['fromCol']] = lastMove['piece'];
    board[lastMove['toRow']][lastMove['toCol']] = lastMove['capturedPiece'];

    // Restore king positions
    whiteKingPos = lastMove['whiteKingPos'];
    blackKingPos = lastMove['blackKingPos'];

    // ✅ FIX: Explicitly cast to List<ChessPiece>
    whiteDeadPieces = List<ChessPiece>.from(lastMove['whiteDeadPieces']);
    blackDeadPieces = List<ChessPiece>.from(lastMove['blackDeadPieces']);

    // Restore turn
    whiteTurn = lastMove['wasWhiteTurn'];

    // Clear selection
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];

    // Update check status
    checkStatus = isKingInCheck(whiteTurn);

    setState(() {});
  }

  void _makeAIMove() {
    if (whiteTurn) return;

    final aiMove = _ai.getMove(board, calculateRealValidMoves);

    if (aiMove == null) return;

    int fromRow = aiMove['fromRow'];
    int fromCol = aiMove['fromCol'];
    int toRow = aiMove['toRow'];
    int toCol = aiMove['toCol'];

    selectedRow = fromRow;
    selectedCol = fromCol;
    selectedPiece = board[fromRow][fromCol];

    movePiece(toRow, toCol);
  }

  void undoLastMove() {
    // Can only undo during player's turn
    if (!whiteTurn || moveHistory.isEmpty) return;

    // Undo AI's last move
    if (moveHistory.isNotEmpty) {
      _undoSingleMove();
    }

    // Undo player's last move
    if (moveHistory.isNotEmpty) {
      _undoSingleMove();
    }

    // Ensure we're back to white's turn
    if (!whiteTurn) {
      whiteTurn = true;
    }

    setState(() {});
  }

  List<List<int>> calculateRealValidMoves(
    int row,
    int col,
    ChessPiece piece,
    bool simulate,
  ) {
    final candidateMoves = calculateRawValidMoves(row, col, piece);
    if (!simulate) return candidateMoves;

    List<List<int>> realMoves = [];

    for (var move in candidateMoves) {
      int endRow = move[0];
      int endCol = move[1];
      if (isSimulatedMoveSafe(piece, row, col, endRow, endCol)) {
        realMoves.add(move);
      }
    }

    return realMoves;
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece piece) {
    List<List<int>> candidateMoves = [];

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        if (isInBounds(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);

          int startRow = piece.isWhite ? 6 : 1;
          if (row == startRow && board[row + 2 * direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        if (isInBounds(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBounds(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;

      case ChessPieceType.rook:
        candidateMoves.addAll(
          lineMoves(row, col, piece, [
            [-1, 0],
            [1, 0],
            [0, -1],
            [0, 1],
          ]),
        );
        break;

      case ChessPieceType.knight:
        List<List<int>> knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];
        for (var move in knightMoves) {
          int newRow = row + move[0];
          int newCol = col + move[1];
          if (!isInBounds(newRow, newCol)) continue;
          var target = board[newRow][newCol];
          if (target == null || target.isWhite != piece.isWhite) {
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;

      case ChessPieceType.bishop:
        candidateMoves.addAll(
          lineMoves(row, col, piece, [
            [-1, -1],
            [-1, 1],
            [1, -1],
            [1, 1],
          ]),
        );
        break;

      case ChessPieceType.queen:
        candidateMoves.addAll(
          lineMoves(row, col, piece, [
            [-1, 0],
            [1, 0],
            [0, -1],
            [0, 1],
            [-1, -1],
            [-1, 1],
            [1, -1],
            [1, 1],
          ]),
        );
        break;

      case ChessPieceType.king:
        List<List<int>> kingMoves = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var move in kingMoves) {
          int newRow = row + move[0];
          int newCol = col + move[1];
          if (!isInBounds(newRow, newCol)) continue;
          var target = board[newRow][newCol];
          if (target == null || target.isWhite != piece.isWhite) {
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;
    }
    return candidateMoves;
  }

  List<List<int>> lineMoves(
    int row,
    int col,
    ChessPiece piece,
    List<List<int>> directions,
  ) {
    List<List<int>> moves = [];
    for (var direction in directions) {
      int dRow = direction[0];
      int dCol = direction[1];
      int tempRow = row + dRow;
      int tempCol = col + dCol;

      while (isInBounds(tempRow, tempCol)) {
        var target = board[tempRow][tempCol];
        if (target == null) {
          moves.add([tempRow, tempCol]);
        } else {
          if (target.isWhite != piece.isWhite) {
            moves.add([tempRow, tempCol]);
          }
          break;
        }
        tempRow += dRow;
        tempCol += dCol;
      }
    }
    return moves;
  }

  bool isInBounds(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool isSimulatedMoveSafe(
    ChessPiece piece,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    var originalPiece = board[endRow][endCol];
    var originalStart = board[startRow][startCol];

    List<int> origWhiteKing = List.from(whiteKingPos);
    List<int> origBlackKing = List.from(blackKingPos);

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPos = [endRow, endCol];
      } else {
        blackKingPos = [endRow, endCol];
      }
    }

    bool kingInCheck = isKingInCheck(piece.isWhite);

    board[startRow][startCol] = originalStart;
    board[endRow][endCol] = originalPiece;
    whiteKingPos = origWhiteKing;
    blackKingPos = origBlackKing;

    return !kingInCheck;
  }

  bool isKingInCheck(bool white) {
    List<int> kingPos = white ? whiteKingPos : blackKingPos;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        ChessPiece? piece = board[r][c];
        if (piece == null || piece.isWhite == white) continue;

        var enemyMoves = calculateRawValidMoves(r, c, piece);
        for (var move in enemyMoves) {
          if (move[0] == kingPos[0] && move[1] == kingPos[1]) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isCheckmate(bool blackTurn) {
    if (!isKingInCheck(blackTurn)) return false;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        ChessPiece? piece = board[r][c];
        if (piece == null || piece.isWhite != blackTurn) continue;
        var moves = calculateRealValidMoves(r, c, piece, true);
        if (moves.isNotEmpty) return false;
      }
    }
    return true;
  }

  // ✨ Enhanced Checkmate Dialog
  Widget _buildCheckmateDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber.shade50, Colors.orange.shade50],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.amber.shade700),
            const SizedBox(height: 16),
            Text(
              "Checkmate!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${whiteTurn ? "Black" : "White"} wins!",
              style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                initializeBoard();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Play Again"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900, Colors.grey.shade800],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✨ Enhanced AppBar
              _buildAppBar(),

              const SizedBox(height: 16),

              // ✨ Enhanced Dead Pieces Display - Black
              _buildDeadPiecesSection(blackDeadPieces, false),

              const SizedBox(height: 16),

              // ✨ Enhanced Chessboard with frame
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.brown.shade800,
                            Colors.brown.shade700,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 64,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                ),
                            itemBuilder: (context, index) {
                              int row = index ~/ 8;
                              int col = index % 8;
                              bool isWhiteSquare = Helper.isWhiteSquare(
                                row,
                                col,
                              );
                              bool isSelected =
                                  (selectedRow == row && selectedCol == col);
                              bool isValid = isValidMove(row, col);

                              return GestureDetector(
                                onTap: () => onSquareTap(row, col),
                                child: Square(
                                  isWhite: isWhiteSquare,
                                  piece: board[row][col],
                                  isSelected: isSelected,
                                  isValidMove: isValid,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✨ Enhanced Dead Pieces Display - White
              _buildDeadPiecesSection(whiteDeadPieces, true),

              // ✨ Enhanced Status Indicator
              _buildStatusSection(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ Enhanced AppBar Widget
  // ✨ Enhanced AppBar Widget
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.castle, color: Colors.amber.shade400, size: 28),
              const SizedBox(width: 12),
              Text(
                'Flutter Chess',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              // ✅ Only highlight when undo is available and it's white's turn
              color:
                  (moveHistory.isEmpty || !whiteTurn)
                      ? Colors.grey.shade700
                      : Colors.amber.shade700,
              borderRadius: BorderRadius.circular(8),
              boxShadow:
                  (moveHistory.isEmpty || !whiteTurn)
                      ? []
                      : [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
            ),
            child: IconButton(
              icon: const Icon(Icons.undo, color: Colors.white),
              // ✅ Only enable during white's turn with move history
              onPressed:
                  (moveHistory.isEmpty || !whiteTurn) ? null : undoLastMove,
              tooltip: 'Undo',
            ),
          ),
        ],
      ),
    );
  }

  // ✨ Enhanced Dead Pieces Section
  // ✨ Enhanced Dead Pieces Section
  Widget _buildDeadPiecesSection(List<ChessPiece> pieces, bool isWhite) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // ✅ Black background for white pieces, lighter for black pieces
        color: isWhite ? Colors.black87 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isWhite
                  ? Colors.white.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:
          pieces.isEmpty
              ? Center(
                child: Text(
                  isWhite ? 'White Captured' : 'Black Captured',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
              : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pieces.length,
                itemBuilder: (_, i) {
                  return DeadPiece(piece: pieces[i], isWhite: isWhite);
                },
              ),
    );
  }

  // ✨ Enhanced Status Section
  Widget _buildStatusSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              checkStatus
                  ? [Colors.red.shade700, Colors.red.shade900]
                  : [Colors.grey.shade800, Colors.grey.shade900],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                checkStatus
                    ? Colors.red.withOpacity(0.4)
                    : Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: checkStatus ? 2 : 0,
          ),
        ],
      ),
      child: Column(
        children: [
          if (checkStatus)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade300,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Check!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          if (checkStatus) const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: whiteTurn ? Colors.white : Colors.grey.shade900,
                  border: Border.all(
                    color: whiteTurn ? Colors.grey.shade800 : Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (whiteTurn ? Colors.white : Colors.grey.shade900)
                          .withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${whiteTurn ? "White" : "Black"}\'s Turn',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
