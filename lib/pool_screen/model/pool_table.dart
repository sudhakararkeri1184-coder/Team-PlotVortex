import 'package:vector_math/vector_math.dart' as vector;

class PoolTable {
  final double width;
  final double height;
  final double cushionWidth = 20.0;
  final List<Pocket> pockets;

  PoolTable({this.width = 900.0, this.height = 450.0})
    : pockets = _initializePockets(width, height);

  static List<Pocket> _initializePockets(double width, double height) {
    final pocketRadius = 30.0;
    return [
      Pocket(position: vector.Vector2(0, 0), radius: pocketRadius), // Top-left
      Pocket(
        position: vector.Vector2(width / 2, 0),
        radius: pocketRadius,
      ), // Top-center
      Pocket(
        position: vector.Vector2(width, 0),
        radius: pocketRadius,
      ), // Top-right
      Pocket(
        position: vector.Vector2(0, height),
        radius: pocketRadius,
      ), // Bottom-left
      Pocket(
        position: vector.Vector2(width / 2, height),
        radius: pocketRadius,
      ), // Bottom-center
      Pocket(
        position: vector.Vector2(width, height),
        radius: pocketRadius,
      ), // Bottom-right
    ];
  }

  bool isInPocket(vector.Vector2 position, double ballRadius) {
    for (final pocket in pockets) {
      final distance = (position - pocket.position).length;
      if (distance < pocket.radius) {
        return true;
      }
    }
    return false;
  }
}

class Pocket {
  final vector.Vector2 position;
  final double radius;

  Pocket({required this.position, required this.radius});
}
