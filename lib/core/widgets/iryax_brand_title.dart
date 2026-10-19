import 'package:flutter/material.dart';

import '../../app/themes/app_colors.dart';

class IryaxBrandTitle extends StatelessWidget {
  final double fontSize;

  const IryaxBrandTitle({
    super.key,
    this.fontSize = 19,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'IRYAX',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'Space',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}