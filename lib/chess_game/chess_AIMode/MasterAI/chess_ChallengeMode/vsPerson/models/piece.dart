enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;

  ChessPiece(this.type, this.isWhite);

  String get imagePath {
    String colorPrefix = isWhite ? "w" : "b";
    switch (type) {
      case ChessPieceType.pawn:
        // if (colorPrefix == 'w') {
        //   return "";
        // }

        return "assets/$colorPrefix-icons8-pawn-64.png";
      case ChessPieceType.rook:
        return "assets/$colorPrefix-icons8-rook-64.png";
      case ChessPieceType.knight:
        return "assets/$colorPrefix-icons8-knight-64.png";
      case ChessPieceType.bishop:
        return "assets/$colorPrefix-icons8-bishop-64.png";
      case ChessPieceType.queen:
        return "assets/$colorPrefix-icons8-queen-64.png";
      case ChessPieceType.king:
        return "assets/$colorPrefix-icons8-king-64.png";
    }
  }
}
