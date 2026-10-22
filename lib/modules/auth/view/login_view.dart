import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/iryax_logo.dart';
import '../../../core/widgets/iryax_text_field.dart';
import '../../../core/widgets/security_footer.dart';
import '../controller/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({
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
                          _buildTopGradientLine(),

                          const SizedBox(height: 18),

                          const IryaxLogo(),

                          const SizedBox(height: 14),

                          _buildTitle(),

                          const SizedBox(height: 5),

                          const Text(
                            'Welcome Back · How are you today?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 3),

                          const Text(
                            'Sign in to continue your journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 28),
                          Form(
                            key: controller.loginFormKey,
                            child: Column(
                              children: [
                                IryaxTextField(
                                  controller: controller.emailController,
                                  hint: 'Email Address *',
                                  prefixIcon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: controller.validateEmail,
                                ),

                                const SizedBox(height: 10),

                                Obx(
                                      () => IryaxTextField(
                                    controller: controller.passwordController,
                                    hint: 'Password *',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: !controller.isPasswordVisible.value,
                                    validator: controller.validatePassword,
                                    suffixIcon: IconButton(
                                      onPressed: controller.togglePasswordVisibility,
                                      icon: Icon(
                                        controller.isPasswordVisible.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textSecondary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          _buildRememberForgotRow(),

                          const SizedBox(height: 24),

                          Obx(
                            () => GradientButton(
                              text: 'Sign In',
                              isLoading: controller.isLoginLoading.value,
                              onPressed: controller.login,
                            ),
                          ),

                          const SizedBox(height: 26),

                          _buildSecureDivider(),

                          const SizedBox(height: 18),

                          _buildCreateAccount(),

                          const SizedBox(height: 14),

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

  Widget _buildRememberForgotRow() {
    return Row(
      children: [
        Obx(
              () => GestureDetector(
            onTap: controller.toggleRememberMe,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: controller.rememberMe.value
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: controller.rememberMe.value
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
              child: controller.rememberMe.value
                  ? const Icon(
                Icons.check,
                color: AppColors.background,
                size: 14,
              )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Remember me',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: controller.forgotPassword,
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'IRYAX',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(width: 6),
        Text(
          'Space',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccount() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        GestureDetector(
          onTap: controller.createAccount,
          child: const Text(
            'Create Account',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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

  Widget _buildSecureDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'SECURE REGISTRATION',
            style: TextStyle(
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ],
    );
  }
}