import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/iryax_logo.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0D0B1F),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0D24),
              Color(0xFF141033),
              Color(0xFF1C1748),
              Color(0xFF0D0B1F),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.9 + (0.1 * value),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Ambient halo + Logo badge
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Soft ambient purple glow
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B4FE9).withValues(alpha: 0.28),
                            blurRadius: 55,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    // Layered glassmorphic container for logo (compact, neat & elegant)
                    Container(
                      width: 104,
                      height: 104,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF221C4A).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: const Color(0xFF5B4FE9).withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x35000000),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const IryaxLogo(
                        size: 76,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Brand Title
                const Text(
                  'IRYAX SPACE',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.5,
                  ),
                ),

                const SizedBox(height: 10),

                // Decorative gradient separator line
                Container(
                  width: 44,
                  height: 2.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5B4FE9),
                        Color(0xFF32D6A5),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                const Text(
                  'PREMIUM WORKSPACES & CABINS',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFFAAA5BF),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.0,
                  ),
                ),

                const Spacer(flex: 3),

                // Minimalist bottom loader & footer
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF5B4FE9),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'SMART WORKSPACE PLATFORM',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF6B658A),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}