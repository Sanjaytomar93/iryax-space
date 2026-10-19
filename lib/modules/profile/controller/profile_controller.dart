import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/profile/model/profile_model.dart';
import 'package:iryax_spaces/modules/profile/service/profile_service.dart';
import 'package:iryax_spaces/modules/profile/widget/edit_profile_dialog.dart';

class ProfileController
    extends GetxController {
  final ProfileService _profileService =
  ProfileService();

  final profile =
      const ProfileModel().obs;

  final isLoading = false.obs;
  final isSaving = false.obs;

  final errorMessage =
  RxnString();

  final nameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final mobileController =
  TextEditingController();

  final addressController =
  TextEditingController();

  final organizationController =
  TextEditingController();

  final gstController =
  TextEditingController();

  @override
  void onInit() {
    super.onInit();

    loadProfile();
  }

  String get initials {
    final name =
    profile.value.name.trim();

    if (name.isEmpty) {
      return 'U';
    }

    final parts = name
        .split(
      RegExp(r'\s+'),
    )
        .where(
          (item) =>
      item.isNotEmpty,
    )
        .toList();

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts.first[0]}'
        '${parts.last[0]}'
        .toUpperCase();
  }

  Future<void> loadProfile() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result =
      await _profileService
          .getProfile();

      profile.value = result;

      debugPrint(
        'PROFILE LOADED: '
            '${result.name} / '
            '${result.email}',
      );
    } catch (e) {
      errorMessage.value =
          _friendlyError(e);

      debugPrint(
        'PROFILE ERROR: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openEditProfile() {
    final data = profile.value;

    nameController.text =
        data.name;

    emailController.text =
        data.email;

    mobileController.text =
        data.mobile;

    addressController.text =
        data.address;

    organizationController.text =
        data.organization;

    gstController.text =
        data.gstNumber;

    Get.dialog(
      const EditProfileDialog(),
      barrierDismissible: false,
    );
  }

  Future<void> saveProfile() async {
    if (isSaving.value) {
      return;
    }

    final name =
    nameController.text.trim();

    final email =
    emailController.text.trim();

    final mobile =
    mobileController.text.trim();

    final address =
    addressController.text.trim();

    final organization =
    organizationController.text
        .trim();

    final gst =
    gstController.text.trim();

    if (name.isEmpty) {
      _showValidation(
        'Please enter your name.',
      );
      return;
    }

    if (email.isEmpty ||
        !GetUtils.isEmail(email)) {
      _showValidation(
        'Please enter a valid email address.',
      );
      return;
    }

    if (mobile.isEmpty) {
      _showValidation(
        'Please enter your mobile number.',
      );
      return;
    }

    try {
      isSaving.value = true;

      final updated =
      await _profileService
          .updateProfile(
        name: name,
        email: email,
        mobile: mobile,
        address: address,
        organization:
        organization,
        gstNumber: gst,
      );

      profile.value = updated;

      Get.back();

      Get.snackbar(
        'Profile Updated',
        'Profile details updated successfully.',
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        _friendlyError(e),
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void _showValidation(
      String message,
      ) {
    Get.snackbar(
      'Check Details',
      message,
      snackPosition:
      SnackPosition.BOTTOM,
    );
  }

  String _friendlyError(
      Object error,
      ) {
    final message =
    error.toString();

    final lower =
    message.toLowerCase();

    if (lower.contains(
      'socketfailed',
    ) ||
        lower.contains(
          'failed host lookup',
        ) ||
        lower.contains(
          'no address associated',
        )) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    if (lower.contains(
      'timeout',
    )) {
      return 'The request took too long. Please try again.';
    }

    return message.replaceFirst(
      'Exception: ',
      '',
    );
  }

  Future<void> logout() async {
    await StorageService.logout();

    Get.offAllNamed(
      AppRoutes.login,
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    organizationController.dispose();
    gstController.dispose();

    super.onClose();
  }
}