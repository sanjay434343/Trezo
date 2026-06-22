import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'label': '01',
      'title': 'AI\nScanner.',
      'body':
          'Powered by Machine Learning, point your camera to auto-extract product names, dates, and prices.',
      'icon': Icons.psychology_rounded,
      'bg': Color(0xFF000000),
      'accent': Color(0xFFFFFFFF),
      'chip': Color(0xFF8AFF80),
    },
    {
      'label': '02',
      'title': 'Encryption\n& Locks.',
      'body':
          'Your vault is fully encrypted. Enable App Lock with biometrics or PIN to secure your sensitive data.',
      'icon': Icons.lock_outline_rounded,
      'bg': Color(0xFFFFFFFF),
      'accent': Color(0xFF000000),
      'chip': Color(0xFF000000),
    },
    {
      'label': '03',
      'title': 'Smart\nReminders.',
      'body':
          'Never miss an expiry date. Receive automated alerts before warranties and documents expire.',
      'icon': Icons.notifications_active_rounded,
      'bg': Color(0xFF000000),
      'accent': Color(0xFFFFFFFF),
      'chip': Color(0xFFFF6B35),
    },
    {
      'label': '04',
      'title': 'Your\nVault.',
      'body':
          'Everything stays locally on your device. Complete privacy and offline access at all times.',
      'icon': Icons.security_rounded,
      'bg': Color(0xFFFFFFFF),
      'accent': Color(0xFF000000),
      'chip': Color(0xFF000000),
    },
  ];

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _previous() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentIndex];
    final bg = page['bg'] as Color;
    final accent = page['accent'] as Color;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        color: bg,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (context, index) {
                    final p = _pages[index];
                    final a = p['accent'] as Color;
                    final c = p['chip'] as Color;
                    final pageBg = p['bg'] as Color;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon chip
                          TweenAnimationBuilder<double>(
                            key: ValueKey('icon_$index'),
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutBack,
                            builder: (ctx, v, _) => Transform.scale(
                              scale: v,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: c,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  p['icon'] as IconData,
                                  size: 40,
                                  color: pageBg,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Title
                          TweenAnimationBuilder<double>(
                            key: ValueKey('text_$index'),
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutExpo,
                            builder: (ctx, v, _) => Transform.translate(
                              offset: Offset(0, 24 * (1 - v)),
                              child: Opacity(
                                opacity: v.clamp(0.0, 1.0),
                                child: Text(
                                  p['title'] as String,
                                  style: TextStyle(
                                    fontFamily: 'LibreBaskerville',
                                    color: a,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            p['body'] as String,
                            style: TextStyle(
                              color: a.withValues(alpha: 0.55),
                              fontSize: 16,
                              height: 1.65,
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom navigation elements (Fixed in place at the bottom of the screen)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _currentIndex > 0 ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: _currentIndex == 0,
                        child: GestureDetector(
                          onTap: _previous,
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Dots
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        _pages.length,
                        (dotIndex) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentIndex == dotIndex ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentIndex == dotIndex
                                ? accent
                                : accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Next / Get Started
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutExpo,
                      switchOutCurve: Curves.easeInExpo,
                      child: _currentIndex < _pages.length - 1
                          ? _PillButton(
                              key: const ValueKey('next_btn'),
                              label: 'Next',
                              bg: accent,
                              fg: bg,
                              onTap: _next,
                            )
                          : _PillButton(
                              key: const ValueKey('start_btn'),
                              label: 'Start',
                              bg: accent,
                              fg: bg,
                              onTap: () => context.go('/permission'),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _PillButton({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          '$label →',
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
