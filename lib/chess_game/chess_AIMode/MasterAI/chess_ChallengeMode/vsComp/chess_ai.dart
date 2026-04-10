import 'models/piece.dart';

class ChessAI {
  // Get AI move
  Map<String, dynamic>? getMove(
    List<List<ChessPiece?>> board,
    Function(int, int, ChessPiece, bool) calculateRealValidMoves,
  ) {
    List<Map<String, dynamic>> allMoves = [];

    // Get all possible moves for black pieces
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && !piece.isWhite) {
          var moves = calculateRealValidMoves(row, col, piece, true);
          for (var move in moves) {
            allMoves.add({
              'fromRow': row,
              'fromCol': col,
              'toRow': move[0],
              'toCol': move[1],
              'piece': piece,
            });
          }
        }
      }
    }

    if (allMoves.isEmpty) return null;

    // Find best move
    Map<String, dynamic>? bestMove;
    double bestScore = -9999;

    for (var move in allMoves) {
      double score = _evaluateMove(board, move);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  double _evaluateMove(
    List<List<ChessPiece?>> board,
    Map<String, dynamic> move,
  ) {
    double score = 0;

    int toRow = move['toRow'];
    int toCol = move['toCol'];

    // Check if capturing a piece
    ChessPiece? targetPiece = board[toRow][toCol];
    if (targetPiece != null) {
      score += _getPieceValue(targetPiece.type) * 10;
    }

    // Prefer center control
    if (toRow >= 3 && toRow <= 4 && toCol >= 3 && toCol <= 4) {
      score += 3;
    }

    return score;
  }

  double _getPieceValue(ChessPieceType type) {
    switch (type) {
      case ChessPieceType.pawn:
        return 1;
      case ChessPieceType.knight:
        return 3;
      case ChessPieceType.bishop:
        return 3;
      case ChessPieceType.rook:
        return 5;
      case ChessPieceType.queen:
        return 9;
      case ChessPieceType.king:
        return 100;
    }
  }
}
