import 'package:flutter/material.dart';

import '../../app/themes/app_colors.dart';

class SecurityFooter extends StatelessWidget {
  const SecurityFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.shield_outlined,
          size: 17,
          color: AppColors.hint,
        ),
        SizedBox(width: 5),
        Text(
          'SSL Secured',
          style: TextStyle(
            color: AppColors.hint,
            fontSize: 12,
          ),
        ),
        SizedBox(width: 16),
        Text(
          '|',
          style: TextStyle(
            color: AppColors.border,
          ),
        ),
        SizedBox(width: 16),
        Icon(
          Icons.bolt_outlined,
          size: 17,
          color: AppColors.hint,
        ),
        SizedBox(width: 5),
        Text(
          'Enterprise Grade',
          style: TextStyle(
            color: AppColors.hint,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}