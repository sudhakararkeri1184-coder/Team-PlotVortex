
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Core2Web About Us',
      // Added a theme to define the text styles used in the screen
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const AboutUsScreen(),
    );
  }
}

//==============================================================================
// Main About Us Screen
//==============================================================================
class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D1B69), Color(0xFF8B2C8B), Color(0xFFE91E63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Back Button with fade-in animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // In a real app, this would navigate back.
                          // For this example, we'll just print a message.
                          print("Back button pressed!");
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Header Section with animation
              _AnimatedSection(
                delay: const Duration(milliseconds: 200),
                child: _buildHeader(),
              ),
              // Founder Section with animation
              _AnimatedSection(
                delay: const Duration(milliseconds: 400),
                child: _buildFounderSection(),
              ),
              // Features Section with animation
              // _AnimatedSection(
              //   delay: const Duration(milliseconds: 600),
              //   child: _buildFeaturesSection(),
              // ),
              // Team Section with animation
              _AnimatedSection(
                delay: const Duration(milliseconds: 800),
                child: _buildTeamSection(),
              ),
              // Mentors and Teachers Section with animation
              // _AnimatedSection(
              //   delay: const Duration(milliseconds: 1000),
              //   child: _buildMentorsTeachersSection(),
              // ),
              // Technology Section with animation
              // _AnimatedSection(
              //   delay: const Duration(milliseconds: 1200),
              //   child: _buildTechnologySection(),
              // ),
              // const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          // Logo and Brand
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'C2W',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Core2Web',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Board Arena',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'About Our Game Engine',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 16),
          const Text(
            'To create an equivalent slogan for a board game, we\'ll follow the same structure but replace the concepts',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.9),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFounderSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text('Our Founder', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 30),
          // Using LayoutBuilder for better responsive behavior
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  children: [
                    _buildFounderPhoto(),
                    const SizedBox(width: 40),
                    Expanded(child: _buildFounderBio()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildFounderPhoto(),
                    const SizedBox(height: 30),
                    _buildFounderBio(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFounderPhoto() {
    return Column(
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/WhatsApp%20Image%202025-07-22%20at%2023.01.52_83e05e9c.jpg-FhmDKYLFQkA8UsD9Rfr2sPXCM8ak2V.jpeg',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => const Center(
                    child: Icon(Icons.person, size: 100, color: Colors.white54),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Shashikant Bagal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Founder & CEO',
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.9),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildFounderBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Shashikant Bagal (Shashi Sir)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Shashikant Bagal (Shashi Sir) is a highly accomplished technologist, educator, and entrepreneur. His most notable achievement is the establishment of Core2web in January 2017, where he teaches students in core programming languages like C, C++, Java, and Python, along with Operating System fundamentals. Beyond foundational concepts, he also specializes in modern framework-based development, including Flutter for cross-platform apps, React for front-end development, and Spring Boot for enterprise Java applications.\n\nHe further expanded his entrepreneurial journey by co-founding Incubators System Pvt. Ltd. and mentoring for multiple startups.\n\nCombining strong theoretical knowledge with real-world industry experience, Shashi Sir bridges the gap between education and practical application, inspiring countless students and professionals in the ever-evolving field of technology.',
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.9),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection() {
    final teamMembers = [
      {
        'name': 'Yash Shinde',
        'role': 'Team Leader',
        'image': 'https://via.placeholder.com/120/33FF57/FFFFFF?text=Yash',
      },
      {
        'name': 'Janhavi Gujar',
        'role': 'UI UX Developer',
        'image': 'https://via.placeholder.com/120/FF5733/FFFFFF?text=Janhavi',
      },
      {
        'name': 'Siddharam Kore',
        'role': 'Frontend Developer',
        'image': 'https://via.placeholder.com/120/3357FF/FFFFFF?text=Deepankar',
      },
      {
        'name': 'Sudhakar Arkeri',
        'role': 'Game Developer',
        'image': 'https://via.placeholder.com/120/FFFF33/000000?text=Shubham',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              'Meet Our Core2Web Team',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: teamMembers.length,
              itemBuilder: (context, index) {
                return TeamMemberCard(
                  name: teamMembers[index]['name']!,
                  role: teamMembers[index]['role']!,
                  imageUrl: teamMembers[index]['image']!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//==============================================================================
// Helper Widgets (Previously in separate files)
//==============================================================================

class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedSection({Key? key, required this.child, required this.delay})
    : super(key: key);

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final String icon;
  final String title;
  final String description;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color:
              _isHovered
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.2),
              blurRadius: _isHovered ? 15 : 10,
              offset: Offset(0, _isHovered ? 8 : 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 15),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MentorTeacherCard extends StatefulWidget {
  final String name;
  final String role;
  final String description;

  const MentorTeacherCard({
    Key? key,
    required this.name,
    required this.role,
    required this.description,
  }) : super(key: key);

  @override
  State<MentorTeacherCard> createState() => _MentorTeacherCardState();
}

class _MentorTeacherCardState extends State<MentorTeacherCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              _isHovered
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.2),
              blurRadius: _isHovered ? 15 : 10,
              offset: Offset(0, _isHovered ? 5 : 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.role,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.7),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamMemberCard extends StatefulWidget {
  final String name;
  final String role;
  final String imageUrl;

  const TeamMemberCard({
    Key? key,
    required this.name,
    required this.role,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<TeamMemberCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              _isHovered
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.2),
              blurRadius: _isHovered ? 15 : 10,
              offset: Offset(0, _isHovered ? 5 : 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: Colors.white.withOpacity(0.1),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.role,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
