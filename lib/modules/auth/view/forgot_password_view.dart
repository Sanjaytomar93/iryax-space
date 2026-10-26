import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/iryax_logo.dart';
import '../../../core/widgets/iryax_text_field.dart';
import '../../../core/widgets/security_footer.dart';
import '../controller/auth_controller.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 28,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
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
                        22,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              AppColors.border.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                          ),

                          _buildTopGradientLine(),

                          const SizedBox(height: 18),

                          const IryaxLogo(),

                          const SizedBox(height: 14),

                          _buildTitle(),

                          const SizedBox(height: 8),

                          const Text(
                            'Enter your registered email to reset password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 28),

                          Form(
                            key: controller.forgotPasswordFormKey,
                            child: IryaxTextField(
                              controller:
                                  controller.forgotEmailController,
                              hint: 'Email Address *',
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: controller.validateEmail,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Obx(
                            () => GradientButton(
                              text: 'Continue',
                              isLoading:
                                  controller.isForgotPasswordLoading.value,
                              onPressed: controller.submitForgotPassword,
                            ),
                          ),

                          const SizedBox(height: 26),

                          const SecurityFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Forgot Password',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTopGradientLine() {
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
}
