import 'package:flutter/material.dart';

import '../../../app/themes/app_colors.dart';
import '../../../core/widgets/iryax_logo.dart';

class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: IryaxLogo(
          size: 220,
        ),
      ),
    );
  }
}