import 'package:flutter/material.dart';
import '../models/piece.dart';

class DeadPiece extends StatelessWidget {
  final ChessPiece piece;
  final bool isWhite;

  const DeadPiece({super.key, required this.piece, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:
            isWhite
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isWhite
                  ? Colors.white.withOpacity(0.3)
                  : Colors.black.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: 0.7,
        child: Image.asset(
          piece.imagePath,
          fit: BoxFit.contain,
          width: 36,
          height: 36,
        ),
      ),
    );
  }
}
