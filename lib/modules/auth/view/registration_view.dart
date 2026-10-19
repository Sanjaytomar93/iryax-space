import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/modules/auth/widget/registration_stepper.dart';

import '../../../app/themes/app_colors.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/iryax_brand_title.dart';
import '../../../core/widgets/iryax_logo.dart';
import '../../../core/widgets/iryax_text_field.dart';
import '../../../core/widgets/security_footer.dart';
import '../controller/auth_controller.dart';
import '../model/account_type.dart';

class RegistrationView extends GetView<AuthController> {
  const RegistrationView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(
              () {

                final type =
                    controller
                        .selectedAccountType
                        .value ??
                        AccountType.user;
            // final type = controller.selectedAccountType.value;
            //
            // if (type == null) {
            //   return const SizedBox.shrink();
            // }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 26,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      18,
                      12,
                      20,
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

                        const SizedBox(height: 14),

                        // _buildChangeAccountType(),
                        //
                        // const SizedBox(height: 10),
                        //
                        // _buildAccountTypeBadge(type),
                        //
                        // const SizedBox(height: 14),

                        const IryaxLogo(
                          size: 58,
                        ),

                        const SizedBox(height: 10),

                        const IryaxBrandTitle(),

                        const SizedBox(height: 3),

                        const Text(
                          'Create Your User Account',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 20),

                        RegistrationStepper(
                          currentStep:
                          controller.currentStep.value,
                          steps: _steps(type),
                        ),

                        const SizedBox(height: 22),

                        _buildCurrentStep(type),

                        const SizedBox(height: 22),

                        _buildSecureDivider(),

                        const SizedBox(height: 16),

                        _buildSignIn(),

                        const SizedBox(height: 12),

                        const SecurityFooter(),
                      ],
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

  List<String> _steps(AccountType type) {
    switch (type) {
      case AccountType.user:
        return [
          'Personal',
          'Complete',
        ];

      case AccountType.cabinOwner:
        return [
          'Personal',
          'Organization',
        ];

      case AccountType.medicalCabin:
        return [
          'Personal',
          'Organization',
          'Documents',
        ];
    }
  }

  Widget _buildCurrentStep(AccountType type) {
    final step = controller.currentStep.value;

    if (step == 1) {
      return _buildPersonalDetails(type);
    }

    if (type == AccountType.user && step == 2) {
      return _buildUserComplete();
    }

    if (type == AccountType.cabinOwner && step == 2) {
      return _buildOrganizationDetails(
        isMedical: false,
      );
    }

    if (type == AccountType.medicalCabin && step == 2) {
      return _buildOrganizationDetails(
        isMedical: true,
      );
    }

    return _buildDocuments();
  }

  Widget _buildPersonalDetails(AccountType type) {
    return Form(
      key: controller.personalFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('PERSONAL DETAILS'),

          const SizedBox(height: 14),

          IryaxTextField(
            controller: controller.fullNameController,
            hint: 'Full Name *',
            prefixIcon: Icons.person_outline,
            validator: (value) =>
                controller.validateRequired(value, 'Full name'),
          ),

          const SizedBox(height: 8),

          IryaxTextField(
            controller: controller.registerEmailController,
            hint: type == AccountType.medicalCabin
                ? 'Medical Email Address *'
                : 'Email Address *',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
          ),

          const SizedBox(height: 8),

          Obx(
                () => IryaxTextField(
              controller: controller.registerPasswordController,
              hint: 'Password *',
              prefixIcon: Icons.lock_outline,
              obscureText:
              !controller.isRegisterPasswordVisible.value,
              validator: controller.validatePassword,
              suffixIcon: IconButton(
                onPressed:
                controller.toggleRegisterPasswordVisibility,
                icon: Icon(
                  controller.isRegisterPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          IryaxTextField(
            controller: controller.mobileController,
            hint: 'Mobile Number *',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: controller.validateMobile,
          ),

          const SizedBox(height: 8),

          IryaxTextField(
            controller: controller.addressController,
            hint: type == AccountType.medicalCabin
                ? 'Clinic Address'
                : 'Address *',
            prefixIcon: Icons.location_on_outlined,
            validator: type == AccountType.medicalCabin
                ? null
                : (value) =>
                controller.validateRequired(value, 'Address'),
          ),

          const SizedBox(height: 16),

          GradientButton(
            text: 'Next',
            onPressed: controller.validateAndNextPersonalStep,
          ),
        ],
      ),
    );
  }

  Widget _buildUserComplete() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: const Column(
            children: [
              Text(
                'Complete your registration as a User',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _Benefit(
                      text: 'Book workspaces',
                    ),
                  ),
                  Expanded(
                    child: _Benefit(
                      text: 'Access medical chambers',
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _Benefit(
                      text: 'Flexible booking',
                    ),
                  ),
                  Expanded(
                    child: _Benefit(
                      text: '24/7 support',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _previousButton(),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: GradientButton(
                text: 'Register',
                onPressed: controller.register,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildOrganizationDetails({
    required bool isMedical,
  }) {
    return Form(
        key: controller.organizationFormKey,
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('ORGANIZATION DETAILS'),

        const SizedBox(height: 14),

        IryaxTextField(
          controller: controller.organizationController,
          hint: 'Organization / Clinic Name',
          prefixIcon: Icons.apartment_outlined,
          validator: (value) => controller.validateRequired(
            value,
            isMedical ? 'Clinic name' : 'Organization name',
          ),
        ),
        const SizedBox(height: 10),

        IryaxTextField(
          controller: controller.gstController,
          hint: isMedical
              ? 'GST Number (Optional)'
              : 'GST Number',
          prefixIcon: Icons.badge_outlined,
        ),

        const SizedBox(height: 10),

        IryaxTextField(
          controller: isMedical
              ? controller.dmhoController
              : controller.panController,
          hint: isMedical
              ? 'DMHO Registration Number (Optional)'
              : 'PAN Number',
          prefixIcon: Icons.credit_card_outlined,
        ),

        if (!isMedical) ...[
          const SizedBox(height: 10),

          Obx(
                () => _uploadBox(
              label: 'Upload PAN CARD',
              selectedFile: controller.panFile.value,
              onTap: () => controller.pickDocument(
                controller.panFile,
              ),
              onRemove: () => controller.removeDocument(
                controller.panFile,
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        if (isMedical)
          const Text(
            'Medical Registration: GST and DMHO number are optional but recommended for complete verification and practice setup.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _previousButton(),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: GradientButton(
                text: isMedical ? 'Next' : 'Register',
                onPressed: isMedical
                    ? controller.validateAndContinueOrganization
                    : controller.validateAndRegisterOrganization,
              ),
            ),
          ],
        ),
      ],
        ),
    );
  }

  Widget _buildDocuments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('MEDICAL DOCUMENTS'),

        const SizedBox(height: 14),

        Obx(
              () => _uploadBox(
            label: 'Upload AADHAR CARD',
            selectedFile: controller.aadhaarFile.value,
            onTap: () => controller.pickDocument(
              controller.aadhaarFile,
            ),
            onRemove: () => controller.removeDocument(
              controller.aadhaarFile,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Obx(
              () => _uploadBox(
            label: 'Upload PAN CARD',
            selectedFile: controller.panFile.value,
            onTap: () => controller.pickDocument(
              controller.panFile,
            ),
            onRemove: () => controller.removeDocument(
              controller.panFile,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Obx(
              () => _uploadBox(
            label: 'Upload MBBS Certificate',
            selectedFile: controller.mbbsFile.value,
            onTap: () => controller.pickDocument(
              controller.mbbsFile,
            ),
            onRemove: () => controller.removeDocument(
              controller.mbbsFile,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Obx(
              () => _uploadBox(
            label: 'Upload PMC Registration',
            selectedFile: controller.pmcFile.value,
            onTap: () => controller.pickDocument(
              controller.pmcFile,
            ),
            onRemove: () => controller.removeDocument(
              controller.pmcFile,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Obx(
              () => _uploadBox(
            label: 'NMR ID Card',
            selectedFile: controller.nmrFile.value,
            onTap: () => controller.pickDocument(
              controller.nmrFile,
            ),
            onRemove: () => controller.removeDocument(
              controller.nmrFile,
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Medical Verification: All documents are encrypted and securely stored. Uploading these documents helps in faster verification and approval.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _previousButton(),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: GradientButton(
                text: 'Register',
                onPressed: controller.registerMedicalUser,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _uploadBox({
    required String label,
    required String? selectedFile,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final hasFile =
        selectedFile != null && selectedFile.isNotEmpty;

    final fileName = hasFile
        ? selectedFile.split(RegExp(r'[\\/]')).last
        : label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasFile
                  ? Icons.check_circle_outline
                  : Icons.upload_outlined,
              color: hasFile
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 19,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasFile
                      ? AppColors.textPrimary
                      : AppColors.hint,
                  fontSize: 12,
                ),
              ),
            ),

            if (hasFile)
              GestureDetector(
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 17,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _previousButton() {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: controller.previousStep,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide.none,
          backgroundColor: AppColors.cardLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Previous',
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        const Icon(
          Icons.person_outline,
          color: AppColors.primary,
          size: 17,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Widget _buildChangeAccountType() {
  //   return GestureDetector(
  //     onTap: controller.changeAccountType,
  //     child: const Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(
  //           Icons.arrow_back,
  //           color: AppColors.textSecondary,
  //           size: 16,
  //         ),
  //         SizedBox(width: 7),
  //         Text(
  //           'Change Account Type',
  //           style: TextStyle(
  //             color: AppColors.textSecondary,
  //             fontSize: 12,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildAccountTypeBadge(AccountType type) {
  //   Color color;
  //
  //   switch (type) {
  //     case AccountType.user:
  //       color = AppColors.primary;
  //       break;
  //
  //     case AccountType.cabinOwner:
  //       color = AppColors.secondary;
  //       break;
  //
  //     case AccountType.medicalCabin:
  //       color = AppColors.purple;
  //       break;
  //   }
  //
  //   return Container(
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 14,
  //       vertical: 6,
  //     ),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(50),
  //       border: Border.all(
  //         color: color.withValues(alpha: 0.6),
  //       ),
  //       color: color.withValues(alpha: 0.08),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(
  //           Icons.person_outline,
  //           size: 14,
  //           color: color,
  //         ),
  //         const SizedBox(width: 6),
  //         Text(
  //           type.title,
  //           style: TextStyle(
  //             color: color,
  //             fontSize: 11,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildGradientLine() {
    return Container(
      width: 76,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
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
              fontSize: 9,
              letterSpacing: 1,
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

  Widget _buildSignIn() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        GestureDetector(
          onTap: () => Get.offAllNamed('/login'),
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

class _Benefit extends StatelessWidget {
  final String text;

  const _Benefit({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.primary,
          size: 18,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}