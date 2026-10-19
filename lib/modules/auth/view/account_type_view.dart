import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/modules/auth/widget/account_type_card.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';
import '../../../core/widgets/iryax_brand_title.dart';
import '../../../core/widgets/iryax_logo.dart';
import '../../../core/widgets/security_footer.dart';
import '../controller/auth_controller.dart';
import '../model/account_type.dart';

class AccountTypeView extends GetView<AuthController> {
  const AccountTypeView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  18,
                  20,
                  18,
                  24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.border.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    _buildGradientLine(),

                    const SizedBox(height: 16),

                    const IryaxLogo(
                      size: 68,
                    ),

                    const SizedBox(height: 10),

                    /// Cancellation / Refund notes
                    _buildCancellationPolicy(),

                    const SizedBox(height: 14),

                    const IryaxBrandTitle(),

                    const SizedBox(height: 3),

                    const Text(
                      'Choose Your Account Type',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Select how you want to register with IRYAX Space',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// USER
                    AccountTypeCard(
                      title: AccountType.user.title,
                      description: AccountType.user.description,
                      actionText: AccountType.user.actionText,
                      icon: Icons.person_outline_rounded,
                      accentColor: AppColors.primary,
                      onTap: () {
                        controller.selectAccountType(
                          AccountType.user,
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    /// CABIN OWNER
                    AccountTypeCard(
                      title: AccountType.cabinOwner.title,
                      description:
                      AccountType.cabinOwner.description,
                      actionText:
                      AccountType.cabinOwner.actionText,
                      icon: Icons.home_work_outlined,
                      accentColor: AppColors.secondary,
                      onTap: () {
                        controller.selectAccountType(
                          AccountType.cabinOwner,
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    /// MEDICAL CABIN
                    AccountTypeCard(
                      title: AccountType.medicalCabin.title,
                      description:
                      AccountType.medicalCabin.description,
                      actionText:
                      AccountType.medicalCabin.actionText,
                      icon: Icons.medical_services_outlined,
                      accentColor: AppColors.purple,
                      onTap: () {
                        controller.selectAccountType(
                          AccountType.medicalCabin,
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    _buildSignIn(),

                    const SizedBox(height: 14),

                    const SecurityFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancellationPolicy() {
    return const Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PolicyItem(
            text: 'Free Cancellation Within 24 Hours',
          ),
          SizedBox(height: 3),
          _PolicyItem(
            text: '50% Refund After 24 Hours',
          ),
          SizedBox(height: 3),
          _PolicyItem(
            text: 'No Refund For No-Shows',
          ),
        ],
      ),
    );
  }

  Widget _buildGradientLine() {
    return Container(
      width: 76,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.purple,
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.offAllNamed(AppRoutes.login);
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final String text;

  const _PolicyItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '•',
          style: TextStyle(
            color: Color(0xFFE26817),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFE26817),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}