// lib/splash_screen.dart (or wherever you have this file)

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Make sure these imports point to the correct files in your project
import '../Authentication/user_auth_screen.dart'; // Your AuthSwitcher file
import 'mainHome.dart'; // Your Homepage file

class QuantumSplashScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  final bool enableSound;

  const QuantumSplashScreen({
    super.key,
    this.onComplete,
    this.enableSound = true,
  });

  @override
  State<QuantumSplashScreen> createState() => _QuantumSplashScreenState();
}

class _QuantumSplashScreenState extends State<QuantumSplashScreen>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late AnimationController _logoAssemblyController;
  late AnimationController _logoRotationController;
  late AnimationController _meshController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _progressController;
  late AnimationController _shapesController;
  late AnimationController _teamTextController;

  // --- Animations ---
  late Animation<double> _logoIconScale;
  late Animation<double> _logoBorderScale;
  late Animation<double> _logoSettleRotation;
  late Animation<double> _textOpacity;
  late Animation<double> _textShadow;
  late Animation<Color?> _textColor;
  late Animation<Offset> _textSlideUp;
  late Animation<double> _textScale;
  late Animation<Offset> _teamTextSlide;
  late Animation<double> _meshRotation;
  late Animation<double> _shapesOpacity;

  // --- State Variables ---
  double _progress = 0.0;
  bool _showContent = false;
  bool _soundEnabled = true;
  Timer? _progressTimer;

  final List<QuantumParticle> _particles = [];
  final List<FloatingShape> _shapes = [];

  @override
  void initState() {
    super.initState();
    _soundEnabled = widget.enableSound;
    // ... (All your controller and animation initializations remain the same)
    // --- Controller Initialization ---
    _logoAssemblyController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoRotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    _meshController = AnimationController(
      duration: const Duration(seconds: 400),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 28),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(seconds: 16),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    _shapesController = AnimationController(
      duration: const Duration(seconds: 24),
      vsync: this,
    );
    _teamTextController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // --- Animation Definitions ---
    _logoIconScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAssemblyController,
        curve: Curves.elasticOut,
      ),
    );

    _logoBorderScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAssemblyController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoSettleRotation = Tween<double>(begin: math.pi * 2, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoAssemblyController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _textShadow = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.linear));
    _textColor = ColorTween(
      begin: const Color(0xFF00FFFF),
      end: const Color(0xFFFF00FF),
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.linear));
    _textSlideUp = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _textScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _teamTextSlide = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _teamTextController, curve: Curves.easeOutCubic),
    );

    _meshRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _meshController, curve: Curves.linear));
    _shapesOpacity = Tween<double>(
      begin: 0,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _shapesController, curve: Curves.easeIn));

    _initializeParticles();
    _initializeShapes();
    _startAnimations();
  }

  // ... (All your _initializeParticles, _initializeShapes, _startAnimations methods remain the same)
  void _initializeParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(
        QuantumParticle(
          color: HSVColor.fromAHSV(1.0, (i * 18) % 360, 1.0, 0.7).toColor(),
          delay: i * 0.1,
        ),
      );
    }
  }

  void _initializeShapes() {
    final icons = [
      Icons.diamond,
      Icons.hexagon,
      Icons.change_history,
      Icons.star,
    ];
    for (int i = 0; i < 4; i++) {
      _shapes.add(
        FloatingShape(
          icon: icons[i],
          position: Offset(0.1 + i * 0.25, 0.2 + (i % 2) * 0.5),
          delay: 1.2 + i * 0.3,
        ),
      );
    }
  }

  void _startAnimations() {
    _meshController.repeat();

    Timer(const Duration(milliseconds: 300), () {
      setState(() => _showContent = true);
      _particleController.repeat();
      _playSound(220, 0.3);
      _teamTextController.forward();
    });

    Timer(const Duration(milliseconds: 800), () {
      _textController.forward();
    });

    Timer(const Duration(milliseconds: 1200), () {
      _shapesController.forward();
    });

    Timer(const Duration(milliseconds: 1800), () {
      _progressController.forward();
      _startProgressTimer();
    });
  }

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        _progress += math.Random().nextDouble() * 8;
        if (_progress >= 100) {
          _progress = 100;
          timer.cancel();
          _playSound(800, 0.2);

          _logoRotationController.stop();
          _logoAssemblyController.forward();

          // --- MODIFIED NAVIGATION LOGIC ---
          Timer(const Duration(milliseconds: 2000), () async {
            final prefs = await SharedPreferences.getInstance();
            // prefs.setBool("isLoggedIn", false);

            final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

            // This check prevents errors if the widget is disposed before navigation
            if (!mounted) return;

            if (isLoggedIn) {
              // User is logged in, go to the Homepage
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const Homepage(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;
                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            } else {
              // User is NOT logged in, go to the AuthSwitcher
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const AuthSwitcher(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOutCubic;
                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            }
          });
        } else if ((_progress / 20).floor() > ((_progress - 8) / 20).floor()) {
          _playSound(400 + (_progress * 2), 0.1);
        }
      });
    });
  }

  void _playSound(double frequency, double duration) {
    if (_soundEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    // ... (Your dispose method remains the same)
    _meshController.dispose();
    _logoAssemblyController.dispose();
    _logoRotationController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _shapesController.dispose();
    _teamTextController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (Your entire build method and all helper widgets remain the same)
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _meshController,
            builder: (context, child) {
              return CustomPaint(
                painter: QuantumMeshPainter(_meshRotation.value),
                size: Size.infinite,
              );
            },
          ),
          if (_showContent) ..._buildParticles(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_showContent) _buildLogo(),
                const SizedBox(height: 40),
                if (_showContent) _buildTitle(),
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (_showContent) ..._buildFloatingShapes(),
          if (_showContent) _buildProgressBar(),
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(
                _soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.white60,
                size: 24,
              ),
              onPressed: () => setState(() => _soundEnabled = !_soundEnabled),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoAssemblyController,
        _logoRotationController,
      ]),
      builder: (context, child) {
        final continuousRotation = _logoRotationController.value * 2 * math.pi;
        final isAssembling =
            _logoAssemblyController.isAnimating ||
            _logoAssemblyController.isCompleted;
        final effectiveRotation =
            isAssembling ? _logoSettleRotation.value : continuousRotation;

        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _logoBorderScale.value,
              child: Transform.rotate(
                angle: effectiveRotation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.8),
                    border: Border.all(
                      color: Colors.cyan.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Transform.scale(
              scale: _logoIconScale.value,
              child: Transform.rotate(
                angle: -effectiveRotation,
                child: const Icon(
                  Icons.sports_esports,
                  size: 60,
                  color: Colors.cyan,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textController, _teamTextController]),
      builder: (context, child) {
        final subtitleOpacity = Curves.easeIn.transform(
          (_textController.value > 0.4)
              ? ((_textController.value - 0.4) / 0.6)
              : 0.0,
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRect(
              child: FractionalTranslation(
                translation: _teamTextSlide.value,
                child: const Text(
                  'TEAM PLOTVORTEX',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: _textOpacity.value,
              child: Transform.scale(
                scale: _textScale.value,
                child: FractionalTranslation(
                  translation: _textSlideUp.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: ShaderMask(
                        shaderCallback:
                            (bounds) => const LinearGradient(
                              colors: [
                                Colors.cyan,
                                Colors.purple,
                                Colors.yellow,
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ).createShader(bounds),
                        child: Text(
                          'BOARD-ARENA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 8,
                            shadows: [
                              Shadow(
                                color: _textColor.value ?? Colors.cyan,
                                blurRadius: 20 + (_textShadow.value * 20),
                              ),
                              Shadow(
                                color: _textColor.value ?? Colors.cyan,
                                blurRadius: 40 + (_textShadow.value * 40),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: subtitleOpacity,
              child: const Text(
                'PLOTVORTEX',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.cyan,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildParticles() {
    return _particles
        .map(
          (particle) => AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              final size = MediaQuery.of(context).size;
              final animationValue =
                  (_particleController.value + particle.delay) % 1.0;
              return Positioned(
                left: particle.getX(animationValue, size.width),
                top: particle.getY(animationValue, size.height),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: particle.color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: particle.color,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
        .toList();
  }

  List<Widget> _buildFloatingShapes() {
    return _shapes
        .map(
          (shape) => AnimatedBuilder(
            animation: _shapesController,
            builder: (context, child) {
              final size = MediaQuery.of(context).size;
              return Positioned(
                left: shape.position.dx * size.width,
                top:
                    shape.position.dy * size.height +
                    (math.sin(_shapesController.value * 2 * math.pi) * 30),
                child: Opacity(
                  opacity: _shapesOpacity.value,
                  child: Transform.rotate(
                    angle: _shapesController.value * 2 * math.pi,
                    child: Icon(shape.icon, size: 32, color: Colors.cyan),
                  ),
                ),
              );
            },
          ),
        )
        .toList();
  }

  Widget _buildProgressBar() {
    return Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantum Loading',
                  style: TextStyle(color: Colors.cyan, fontSize: 16),
                ),
                Text(
                  '${_progress.round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: _progress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.cyan, Colors.purple, Colors.pink],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.8),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Positioned(
                            left:
                                _progressController.value *
                                constraints.maxWidth,
                            child: Container(
                              width: 2,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (All your helper classes like QuantumMeshPainter, etc. remain the same)
class QuantumMeshPainter extends CustomPainter {
  final double rotation;
  QuantumMeshPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
    const gridSize = 50.0;

    paint.color = Colors.cyan.withOpacity(0.1);
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    paint.style = PaintingStyle.fill;
    paint.shader = ui.Gradient.radial(
      Offset(size.width / 2, size.height / 2),
      size.width / 4,
      [Colors.cyan.withOpacity(0.05), Colors.transparent],
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(QuantumMeshPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}

class QuantumParticle {
  final Color color;
  final double delay;
  late double startX, startY, endX, endY;

  QuantumParticle({required this.color, required this.delay}) {
    _generateRandomPath();
  }

  void _generateRandomPath() {
    startX = math.Random().nextDouble();
    startY = math.Random().nextDouble();
    endX = math.Random().nextDouble();
    endY = math.Random().nextDouble();
  }

  double getX(double t, double w) =>
      (startX + (endX - startX) * (t * 2 % 1.0)) * w;
  double getY(double t, double h) =>
      (startY + (endY - startY) * (t * 2 % 1.0)) * h;
}

class FloatingShape {
  final IconData icon;
  final Offset position;
  final double delay;
  FloatingShape({
    required this.icon,
    required this.position,
    required this.delay,
  });
}
