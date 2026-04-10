import 'package:flutter/material.dart';
import '../values.dart';
import '../models/piece.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;

  const Square({
    super.key,
    required this.isWhite,
    this.piece,
    this.isSelected = false,
    this.isValidMove = false,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor =
        isWhite ? ChessColors.whiteSquare : ChessColors.blackSquare;

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
                : null,
      ),
      child: Stack(
        children: [
          // ✨ Selection highlight
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 4),
                color: Colors.green.withOpacity(0.3),
              ),
            ),

          // ✨ Valid move indicator (elegant dot)
          if (isValidMove && piece == null)
            Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

          // ✨ Valid move capture indicator (ring around piece)
          if (isValidMove && piece != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade400, width: 4),
                color: Colors.red.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

          // ✨ Chess piece with shadow
          if (piece != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  piece!.imagePath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
