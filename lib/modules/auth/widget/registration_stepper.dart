import 'package:flutter/material.dart';

import '../../../app/themes/app_colors.dart';

class RegistrationStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const RegistrationStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        steps.length,
            (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber <= currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.secondary
                        : Colors.transparent,
                    border: Border.all(
                      color: isActive
                          ? AppColors.secondary
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: isActive
                          ? AppColors.background
                          : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 7),

                Flexible(
                  child: Text(
                    steps[index],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: stepNumber == currentStep
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: stepNumber == currentStep
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),

                if (index != steps.length - 1) ...[
                  const SizedBox(width: 7),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.border,
                    ),
                  ),
                  const SizedBox(width: 7),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}