class Helper {
  // Determine if square should be white or black based on row and column
  static bool isWhiteSquare(int row, int col) {
    return (row + col) % 2 == 0;
  }
}
