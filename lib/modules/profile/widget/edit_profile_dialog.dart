import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/modules/profile/controller/profile_controller.dart';

class EditProfileDialog extends GetView<ProfileController> {
  const EditProfileDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.dashboardBlue,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Update Your Personal and organization details',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(
              color: AppColors.lightBorder,
            ),

            const SizedBox(height: 12),

            const Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.dashboardBlue,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _field(
              controller.nameController,
              Icons.person_outline,
            ),

            const SizedBox(height: 9),

            _field(
              controller.emailController,
              Icons.email_outlined,
            ),

            const SizedBox(height: 9),

            _field(
              controller.mobileController,
              Icons.phone_outlined,
            ),

            const SizedBox(height: 9),

            _field(
              controller.addressController,
              Icons.location_on_outlined,
            ),

            const SizedBox(height: 20),

            const Row(
              children: [
                Icon(
                  Icons.apartment_outlined,
                  color: AppColors.dashboardOrange,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Organization Details',
                  style: TextStyle(
                    color: AppColors.lightTextSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _field(
              controller.organizationController,
              Icons.apartment_outlined,
            ),

            const SizedBox(height: 9),

            _field(
              controller.gstController,
              Icons.description_outlined,
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: Get.back,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.gradientBlueStart,
                            AppColors.gradientPurpleEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Obx(
                            () => TextButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.saveProfile,
                          child: controller.isSaving.value
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
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
    );
  }

  Widget _field(
      TextEditingController controller,
      IconData icon,
      ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: AppColors.lightTextSecondary,
          size: 18,
        ),
        filled: true,
        fillColor: AppColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(
            color: AppColors.lightPrimary,
          ),
        ),
      ),
    );
  }
}