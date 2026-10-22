import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/core/services/storage_service.dart';

import '../../../app/routes/app_routes.dart';
import '../model/account_type.dart';
import '../service/auth_service.dart';
import '../widget/login_success_dialog.dart';

class AuthController extends GetxController {
  final AuthService _authService =
  AuthService();

  // ============================================================
  // LOGIN
  // ============================================================

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final loginFormKey =
  GlobalKey<FormState>();

  final isPasswordVisible =
      false.obs;

  final rememberMe =
      false.obs;

  final isLoginLoading =
      false.obs;

  // ============================================================
  // ACCOUNT TYPE
  // ============================================================

  final selectedAccountType =
  Rxn<AccountType>(
    AccountType.user,
  );

  // final selectedAccountType =
  // Rxn<AccountType>();

  // ============================================================
  // REGISTRATION
  // ============================================================

  final currentStep =
      1.obs;

  final isRegisterLoading =
      false.obs;

  // ============================================================
  // PERSONAL DETAILS
  // ============================================================

  final fullNameController =
  TextEditingController();

  final registerEmailController =
  TextEditingController();

  final registerPasswordController =
  TextEditingController();

  final mobileController =
  TextEditingController();

  final addressController =
  TextEditingController();

  // ============================================================
  // ORGANIZATION DETAILS
  // ============================================================

  final organizationController =
  TextEditingController();

  final gstController =
  TextEditingController();

  final panController =
  TextEditingController();

  final dmhoController =
  TextEditingController();

  // ============================================================
  // DOCUMENTS
  // ============================================================

  final aadhaarFile =
  RxnString();

  final panFile =
  RxnString();

  final mbbsFile =
  RxnString();

  final pmcFile =
  RxnString();

  final nmrFile =
  RxnString();

  final isRegisterPasswordVisible =
      false.obs;

  final personalFormKey =
  GlobalKey<FormState>();

  final organizationFormKey =
  GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();

    _restoreRegistration();
  }

  // ============================================================
  // RESTORE REGISTRATION
  // ============================================================

  void _restoreRegistration() {
    if (!StorageService.registrationInProgress) {
      return;
    }

    final savedType =
        StorageService.accountType;

    if (savedType != null) {
      selectedAccountType.value =
          AccountType.values.firstWhereOrNull(
                (type) =>
            type.name == savedType,
          );
    }

    currentStep.value =
        StorageService.registrationStep;

    fullNameController.text =
        StorageService.fullName;

    registerEmailController.text =
        StorageService.registrationEmail;

    mobileController.text =
        StorageService.mobile;

    addressController.text =
        StorageService.address;

    organizationController.text =
        StorageService.organizationName;

    gstController.text =
        StorageService.gst;

    panController.text =
        StorageService.pan;

    dmhoController.text =
        StorageService.dmho;
  }

  // ============================================================
  // VALIDATIONS
  // ============================================================

  String? validateEmail(
      String? value,
      ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Email address is required';
    }

    if (!GetUtils.isEmail(text)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? validatePassword(
      String? value,
      ) {
    final text =
        value ?? '';

    if (text.isEmpty) {
      return 'Password is required';
    }

    if (text.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? validateRequired(
      String? value,
      String fieldName,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? validateMobile(
      String? value,
      ) {
    final text =
        value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Mobile number is required';
    }

    if (!RegExp(
      r'^[6-9]\d{9}$',
    ).hasMatch(text)) {
      return 'Enter a valid 10 digit mobile number';
    }

    return null;
  }

  // ============================================================
  // LOGIN API
  // ============================================================

  Future<void> login() async {
    final isValid =
        loginFormKey.currentState
            ?.validate() ??
            false;

    if (!isValid ||
        isLoginLoading.value) {
      return;
    }

    try {
      isLoginLoading.value = true;

      final response =
      await _authService.login(
        email:
        emailController.text.trim(),
        password:
        passwordController.text,
      );

      if (response.token.isEmpty ||
          response.user.id.isEmpty) {
        throw Exception(
          'Invalid login response.',
        );
      }

      await StorageService.saveLoginSession(
        token: response.token,
        userId: response.user.id,
        name: response.user.name,
        email: response.user.email,
        mobile: response.user.mobile,
        address: response.user.address,
        role: response.user.role,
        isDoctor:
        response.user.isDoctor,
      );

      isLoginLoading.value = false;

      await LoginSuccessDialog.show(
        userName: response.user.name,
        role: response.user.role,
        onComplete: () {
          Get.offAllNamed(
            AppRoutes.dashboard,
          );
        },
      );
    } catch (e) {
      isLoginLoading.value = false;

      Get.snackbar(
        'Login Failed',
        _cleanError(e),
        snackPosition:
        SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // PERSONAL REGISTRATION
  // ============================================================

  Future<void>
  validateAndNextPersonalStep() async {
    final isValid =
        personalFormKey.currentState
            ?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    await StorageService.savePersonalDetails(
      fullName:
      fullNameController.text.trim(),
      email:
      registerEmailController.text.trim(),
      mobile:
      mobileController.text.trim(),
      address:
      addressController.text.trim(),
    );

    await nextStep();
  }

  // ============================================================
  // REGISTER API
  // ============================================================

  Future<void> register() async {
    if (isRegisterLoading.value) {
      return;
    }

    final accountType =
        selectedAccountType.value;

    if (accountType == null) {
      Get.snackbar(
        'Account Type Required',
        'Please select an account type.',
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return;
    }

    if (registerPasswordController
        .text
        .isEmpty) {
      Get.snackbar(
        'Password Required',
        'Please enter your password.',
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      isRegisterLoading.value = true;

      final message =
      await _authService.register(
        name:
        fullNameController.text.trim(),
        email:
        registerEmailController.text.trim(),
        password:
        registerPasswordController.text,
        mobile:
        mobileController.text.trim(),
        address:
        addressController.text.trim(),

        // Only field changing based
        // on selected account type.
        role: accountType.apiRole,
      );

      await StorageService
          .completeRegistration();

      clearRegistrationForm();


      Get.until(
            (route) =>
        route.settings.name ==
            AppRoutes.login,
      );

      // Get.offAllNamed(
      //   AppRoutes.login,
      // );

      Get.snackbar(
        'Registration Completed',
        message,
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        _cleanError(e),
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } finally {
      isRegisterLoading.value = false;
    }
  }

  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  void togglePasswordVisibility() {
    isPasswordVisible.value =
    !isPasswordVisible.value;
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible.value =
    !isRegisterPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value =
    !rememberMe.value;
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  void forgotPassword() {
    Get.snackbar(
      'Forgot Password',
      'Forgot password flow will be added later.',
      snackPosition:
      SnackPosition.BOTTOM,
    );
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> createAccount() async {
    selectedAccountType.value =
        AccountType.user;

    currentStep.value = 1;

    await StorageService
        .startRegistration(
      accountType:
      AccountType.user.name,
    );

    Get.toNamed(
      AppRoutes.registration,
    );
  }

  // void createAccount() {
  //   Get.toNamed(
  //     AppRoutes.accountType,
  //   );
  // }

  Future<void> selectAccountType(
      AccountType type,
      ) async {
    selectedAccountType.value =
        type;

    currentStep.value =
    1;

    await StorageService.startRegistration(
      accountType: type.name,
    );

    Get.toNamed(
      AppRoutes.registration,
    );
  }

  // Future<void>
  // changeAccountType() async {
  //   currentStep.value =
  //   1;
  //
  //   selectedAccountType.value =
  //   null;
  //
  //   await StorageService
  //       .clearRegistration();
  //
  //   Get.offNamed(
  //     AppRoutes.accountType,
  //   );
  // }

  // ============================================================
  // STEPS
  // ============================================================

  int get totalSteps {
    switch (selectedAccountType.value) {
      case AccountType.user:
        return 2;

      case AccountType.cabinOwner:
        return 2;

      case AccountType.medicalCabin:
        return 3;

      case null:
        return 1;
    }
  }

  Future<void> nextStep() async {
    if (currentStep.value <
        totalSteps) {
      currentStep.value++;

      await StorageService
          .saveRegistrationStep(
        currentStep.value,
      );
    }
  }

  Future<void> previousStep() async {
    if (currentStep.value > 1) {
      currentStep.value--;

      await StorageService
          .saveRegistrationStep(
        currentStep.value,
      );
    }
  }

  // ============================================================
  // ORGANIZATION
  // ============================================================

  Future<void>
  validateAndContinueOrganization() async {
    final isValid =
        organizationFormKey.currentState
            ?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    await StorageService.saveOrganization(
      name:
      organizationController.text.trim(),
      gst:
      gstController.text.trim(),
      pan:
      panController.text.trim(),
      dmho:
      dmhoController.text.trim(),
    );

    await nextStep();
  }

  Future<void>
  validateAndRegisterOrganization() async {
    final isValid =
        organizationFormKey.currentState
            ?.validate() ??
            false;

    if (!isValid) {
      return;
    }

    await StorageService.saveOrganization(
      name:
      organizationController.text.trim(),
      gst:
      gstController.text.trim(),
      pan:
      panController.text.trim(),
      dmho:
      dmhoController.text.trim(),
    );

    // Same Register API.
    await register();
  }

  // ============================================================
  // DOCUMENT PICKING
  // ============================================================

  Future<void> pickDocument(
      RxnString target,
      ) async {
    final result =
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
      ],
    );

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    target.value =
        result.files.single.path;
  }

  void removeDocument(
      RxnString target,
      ) {
    target.value = null;
  }

  // ============================================================
  // MEDICAL DOCUMENT VALIDATION
  // ============================================================

  bool validateMedicalDocuments() {
    if (aadhaarFile.value == null) {
      _documentError(
        'Aadhaar Required',
        'Please upload Aadhaar card',
      );

      return false;
    }

    if (panFile.value == null) {
      _documentError(
        'PAN Required',
        'Please upload PAN card',
      );

      return false;
    }

    if (mbbsFile.value == null) {
      _documentError(
        'MBBS Certificate Required',
        'Please upload MBBS certificate',
      );

      return false;
    }

    if (pmcFile.value == null) {
      _documentError(
        'PMC Registration Required',
        'Please upload PMC registration',
      );

      return false;
    }

    if (nmrFile.value == null) {
      _documentError(
        'NMR ID Required',
        'Please upload NMR ID card',
      );

      return false;
    }

    return true;
  }

  Future<void>
  registerMedicalUser() async {
    if (!validateMedicalDocuments()) {
      return;
    }

    // Same register API.
    // Documents are currently only UI/local because
    // the provided register API does not contain
    // document fields.
    await register();
  }

  void _documentError(
      String title,
      String message,
      ) {
    Get.snackbar(
      title,
      message,
      snackPosition:
      SnackPosition.BOTTOM,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _cleanError(
      Object error,
      ) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }

  void clearRegistrationForm() {

    selectedAccountType.value =
        AccountType.user;
    // selectedAccountType.value =
    // null;

    currentStep.value =
    1;

    fullNameController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    mobileController.clear();
    addressController.clear();

    organizationController.clear();
    gstController.clear();
    panController.clear();
    dmhoController.clear();

    aadhaarFile.value = null;
    panFile.value = null;
    mbbsFile.value = null;
    pmcFile.value = null;
    nmrFile.value = null;

    isRegisterPasswordVisible.value =
    false;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    fullNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    mobileController.dispose();
    addressController.dispose();

    organizationController.dispose();
    gstController.dispose();
    panController.dispose();
    dmhoController.dispose();

    super.onClose();
  }
}