// lib/chess_screen/chess_CompetitiveMode/services/multiplayer_chess_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ✅ CORRECTED PATH
import 'package:v2/chess_screen/chess_MultiplayerMode/3DchessMode/constants/chess_html.dart';

class MultiplayerChessService {
  late WebViewController controller;
  Function(String)? onMessageReceived;

  void initialize({Function(String)? onMessageReceived}) {
    this.onMessageReceived = onMessageReceived;

    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'FlutterChannel',
            onMessageReceived: (JavaScriptMessage message) {
              if (onMessageReceived != null) {
                onMessageReceived(message.message);
              }
            },
          )
          ..loadRequest(
            Uri.dataFromString(
              ChessHtml.content,
              mimeType: 'text/html',
              encoding: Encoding.getByName('utf-8'),
            ),
          );
  }

  void enableInput() {
    controller.runJavaScript('enableInput();');
  }

  void disableInput() {
    controller.runJavaScript('disableInput();');
  }

  void loadFen(String fen) {
    final escapedFen = fen.replaceAll("'", "\\'");
    controller.runJavaScript("loadFen('$escapedFen');");
  }

  void undoMove() {
    controller.runJavaScript('undoMove();');
  }

  void rotateBoard() {
    controller.runJavaScript('rotateBoard();');
  }

  void resetGame() {
    loadFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
  }
}
