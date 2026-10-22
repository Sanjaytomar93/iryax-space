import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_colors.dart';

class LoginSuccessDialog extends StatefulWidget {
  const LoginSuccessDialog({
    super.key,
    required this.userName,
    required this.role,
    required this.onComplete,
  });

  final String userName;
  final String role;
  final VoidCallback onComplete;

  static Future<void> show({
    required String userName,
    required String role,
    required VoidCallback onComplete,
  }) {
    return Get.dialog(
      LoginSuccessDialog(
        userName: userName,
        role: role,
        onComplete: onComplete,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
    );
  }

  @override
  State<LoginSuccessDialog> createState() =>
      _LoginSuccessDialogState();
}

class _LoginSuccessDialogState extends State<LoginSuccessDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _progressController;
  late final AnimationController _pulseController;

  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _checkScaleAnim;

  bool _completed = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _checkScaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_entryController);

    _entryController.forward();

    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) {
        _progressController.forward().whenComplete(_finish);
      }
    });
  }

  void _finish() {
    if (_completed || !mounted) return;
    _completed = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String get _displayRole {
    final role = widget.role.trim();
    if (role.isEmpty) return 'user';
    return role.toLowerCase();
  }

  String get _displayName {
    final name = widget.userName.trim();
    if (name.isEmpty) return 'there';
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.55),
                    AppColors.secondary.withValues(alpha: 0.45),
                    AppColors.purple.withValues(alpha: 0.4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 28,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(1.4),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xE61E1A3A),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(28, 38, 28, 26),
                          child: Column(
                            children: [
                              ScaleTransition(
                                scale: _checkScaleAnim,
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    final glow =
                                        0.28 + (_pulseController.value * 0.22);
                                    return Container(
                                      width: 84,
                                      height: 84,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primary,
                                            AppColors.secondary,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: glow),
                                            blurRadius: 22,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 42,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              const Text(
                                'Welcome back!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _displayName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardLight.withValues(
                                    alpha: 0.75,
                                  ),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: AppColors.border.withValues(
                                      alpha: 0.65,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _displayRole,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: SizedBox(
                              height: 5,
                              child: AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, _) {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        color: AppColors.border.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: _progressController.value,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primary,
                                                AppColors.secondary,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _finish,
                          borderRadius: BorderRadius.circular(99),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
