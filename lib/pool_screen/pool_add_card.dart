import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:v2/chess_screen/chess_TournamentMode/model/chess_tournament_model.dart';
// import 'package:poolgameui/model/tournament_model.dart';

class Addcard extends StatefulWidget {
  const Addcard({super.key});

  @override
  State<Addcard> createState() => _AddcardState();
}

class _AddcardState extends State<Addcard> with SingleTickerProviderStateMixin {
  bool isPaid = false;
  late AnimationController _animationController;

  TextEditingController categorycontroller = TextEditingController();
  TextEditingController tournamentcontroller = TextEditingController();

  String tournamentId = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    tournamentId = _generateTournamentId();
  }

  String _generateTournamentId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    math.Random rnd = math.Random();
    return 'TOURN-${String.fromCharCodes(Iterable.generate(9, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))))}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    categorycontroller.dispose();
    tournamentcontroller.dispose();
    super.dispose();
  }

  void _createTournament() {
    if (categorycontroller.text.trim().isEmpty ||
        tournamentcontroller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final tournament = TournamentModel(
      title: tournamentcontroller.text.trim(),
      category: categorycontroller.text.trim(),
      mode: categorycontroller.text.trim(),
      isPaid: isPaid,
      tournamentId: tournamentId,
      createdAt: null!,
      creatorId: '',
    );

    Navigator.of(context).pop(tournament);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Tournament',
          style: TextStyle(
            color: Color(0xFFD86FED),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E1647), // deep blue
              Color(0xFF3A298F), // purple blue
              Color(0xFF00A3FF), // cyan accent
              Color(0xFF1A2336), // navy
            ],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: BlobPainter(_animationController.value),
                  child: Container(),
                );
              },
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: kToolbarHeight + 24,
                left: 18,
                right: 18,
                bottom: 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionCard(
                    icon: Icons.emoji_events,
                    label: 'Tournament Name',
                    color: Color(0xFF975FE9),
                    child: TextField(
                      controller: tournamentcontroller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter tournament name...',
                        hintStyle: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  _sectionCard(
                    icon: Icons.category,
                    label: 'Tournament Type',
                    color: Color(0xFFF7B900),
                    child: Row(
                      children: [
                        _selectTypeBox(
                          icon: Icons.attach_money,
                          label: 'Paid Entry',
                          description: 'Entry fee',
                          selected: isPaid,
                          onTap: () {
                            setState(() => isPaid = true);
                          },
                        ),
                        SizedBox(width: 14),
                        _selectTypeBox(
                          icon: Icons.people,
                          label: 'Free Entry',
                          description: 'No entry fee',
                          selected: !isPaid,
                          onTap: () {
                            setState(() => isPaid = false);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  _sectionCard(
                    icon: Icons.tag_outlined,
                    label: 'Category',
                    color: Color(0xFFDA4299),
                    child: TextField(
                      controller: categorycontroller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'e.g., Blitz, Rapid, Classical...',
                        hintStyle: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                  SizedBox(height: 18),
                  _sectionCard(
                    icon: Icons.tag,
                    label: 'Tournament ID',
                    color: Color(0xFF5880CC),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tournamentId,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ID copied to clipboard')),
                            );
                          },
                          child: Icon(Icons.copy, color: Colors.white70),
                        ),
                      ],
                    ),
                    footer: Text(
                      "This unique ID will be used to identify your tournament",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _createTournament,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFB85FF2), Color(0xFFFA52A0)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Create Tournament',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Widget child,
    Widget? footer,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.20), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              SizedBox(width: 9),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          child,
          if (footer != null) ...[SizedBox(height: 10), footer],
        ],
      ),
    );
  }

  Widget _selectTypeBox({
    required IconData icon,
    required String label,
    required String description,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 77,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color:
                selected
                    ? (label == 'Paid Entry'
                        ? Colors.grey[800]
                        : Colors.green[700])
                    : Colors.grey[900],
            border: Border.all(
              color:
                  selected
                      ? (label == 'Paid Entry'
                          ? Colors.deepPurple.withOpacity(0.4)
                          : Colors.greenAccent)
                      : Colors.transparent,
              width: 2.1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 14),
              Icon(
                icon,
                color: selected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 26,
              ),
              SizedBox(width: 13),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for animated blobs
class BlobPainter extends CustomPainter {
  final double animationValue;
  BlobPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double t = animationValue;
    final double w = size.width;
    final double h = size.height;

    blob(
      canvas,
      const Color(0xFF6F49FF),
      Offset(w * (0.2 + 0.02 * math.sin(t * math.pi * 2)), h * 0.15),
      140,
      24,
    );
    blob(
      canvas,
      const Color(0xFF00C2FF),
      Offset(w * 0.85, h * (0.25 + 0.02 * math.cos(t * math.pi * 2))),
      120,
      22,
    );
    blob(
      canvas,
      const Color(0xFF22D38A),
      Offset(w * 0.2, h * (0.7 + 0.03 * math.sin(t * math.pi))),
      160,
      26,
    );
    blob(
      canvas,
      const Color(0xFFFF9A32),
      Offset(w * (0.7 + 0.03 * math.cos(t * math.pi)), h * 0.9),
      130,
      20,
    );
  }

  void blob(
    Canvas canvas,
    Color color,
    Offset position,
    double size,
    double blur,
  ) {
    final paint =
        Paint()
          ..color = color.withOpacity(0.15)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.drawCircle(position, size, paint);
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
