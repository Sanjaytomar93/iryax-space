import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/profile/controller/profile_controller.dart';

class EditProfileDialog extends GetView<ProfileController> {
  const EditProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 32,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.lightPrimary.withValues(alpha: 0.15),
                          const Color(0xFF3D3568).withValues(alpha: 0.20),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.lightPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: AppColors.lightTextPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Keep your account information accurate',
                          style: TextStyle(
                            color: AppColors.lightTextSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.lightTextSecondary,
                      size: 20,
                    ),
                    splashRadius: 18,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.lightBorder, height: 1),
              const SizedBox(height: 16),

              // Section: Personal Information
              _buildSectionHeader(
                icon: Icons.person_rounded,
                title: 'PERSONAL DETAILS',
                badgeColor: AppColors.softPurple,
                iconColor: AppColors.lightPrimary,
              ),
              const SizedBox(height: 12),

              _buildInputField(
                controller: controller.nameController,
                label: 'Full Name',
                hint: 'e.g. Dr. Jane Doe',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 10),

              _buildInputField(
                controller: controller.emailController,
                label: 'Email Address',
                hint: 'name@example.com',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),

              _buildInputField(
                controller: controller.mobileController,
                label: 'Mobile Number',
                hint: '+91 98765 43210',
                icon: Icons.phone_iphone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),

              _buildInputField(
                controller: controller.addressController,
                label: 'Full Address',
                hint: 'City, State, Country',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 20),

              // Section: Organization Details
              _buildSectionHeader(
                icon: Icons.business_rounded,
                title: 'ORGANIZATION & BUSINESS',
                badgeColor: AppColors.softOrange,
                iconColor: AppColors.dashboardOrange,
              ),
              const SizedBox(height: 12),

              _buildInputField(
                controller: controller.organizationController,
                label: 'Organization / Clinic Name',
                hint: 'e.g. Apex Health Clinic',
                icon: Icons.apartment_rounded,
              ),
              const SizedBox(height: 10),

              _buildInputField(
                controller: controller.gstController,
                label: 'GST Number',
                hint: '22AAAAA0000A1Z5 (optional)',
                icon: Icons.receipt_long_outlined,
                textCapitalization: TextCapitalization.characters,
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: AppColors.lightBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gradientBlueStart,
                              AppColors.gradientPurpleEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightPrimary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : controller.saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 7),
                                      Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color badgeColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.lightTextPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textCapitalization: textCapitalization,
          style: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.lightHint,
              fontSize: 12.5,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.lightTextSecondary,
              size: 18,
            ),
            filled: true,
            fillColor: AppColors.lightBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.lightPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
