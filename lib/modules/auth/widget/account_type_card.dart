import 'package:flutter/material.dart';

import '../../../app/themes/app_colors.dart';

class AccountTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionText;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const AccountTypeCard({
    super.key,
    required this.title,
    required this.description,
    required this.actionText,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: title == 'Medical Cabin'
                ? accentColor.withValues(alpha: 0.65)
                : AppColors.border.withValues(alpha: 0.8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: TextStyle(
                color: title == 'Medical Cabin'
                    ? accentColor
                    : AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: accentColor,
                  size: 15,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}