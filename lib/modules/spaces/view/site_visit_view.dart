import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/app/routes/app_routes.dart';

import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/bookings/service/booking_service.dart';
import 'package:iryax_spaces/modules/navigation/controller/navigation_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';

import '../../../app/themes/app_colors.dart';

class SiteVisitView extends StatefulWidget {
  const SiteVisitView({
    super.key,
  });

  @override
  State<SiteVisitView> createState() =>
      _SiteVisitViewState();
}

class _SiteVisitViewState extends State<SiteVisitView> {
  final formKey = GlobalKey<FormState>();

  final visitorNameController =
  TextEditingController();

  final mobileController =
  TextEditingController();

  final dateController =
  TextEditingController();

  final timeController =
  TextEditingController();

  final BookingService _bookingService =
  BookingService();

  bool isSubmitting = false;

  SpaceModel? space;

  String selectedPeriod = 'AM';

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments;

    if (arguments is SpaceModel) {
      space = arguments;
    }

    visitorNameController.text =
        StorageService.userName;

    mobileController.text =
        StorageService.userMobile;
  }

  @override
  void dispose() {
    visitorNameController.dispose();
    mobileController.dispose();
    dateController.dispose();
    timeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (space == null) {
      return Scaffold(
        backgroundColor:
        AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor:
          AppColors.lightSurface,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Space information not available.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
        AppColors.lightSurface,
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
        false,
        toolbarHeight: 50,
        titleSpacing: 14,
        title: InkWell(
          onTap: Get.back,
          child: const Row(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .arrow_back_ios_new_rounded,
                size: 13,
                color: AppColors
                    .lightTextPrimary,
              ),
              SizedBox(width: 6),
              Text(
                'Back',
                style: TextStyle(
                  color: AppColors
                      .lightTextPrimary,
                  fontSize: 11,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildImage(),

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                14,
                12,
                14,
                28,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildStats(),

                  const SizedBox(
                    height: 12,
                  ),

                  _buildVisitorCard(),

                  const SizedBox(
                    height: 10,
                  ),

                  _buildTimeSlotCard(),

                  const SizedBox(
                    height: 14,
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed:
                      isSubmitting
                          ? null
                          : _confirmVisit,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors
                            .dashboardGreen,
                        foregroundColor:
                        Colors.white,
                        elevation: 0,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            10,
                          ),
                        ),
                      ),
                      child:
                      isSubmitting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Confirm Visit',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  const Text(
                    'RELATED CHAMBERS',
                    style: TextStyle(
                      color: AppColors
                          .lightTextPrimary,
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _buildRelatedSpaces(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _buildImage() {
    final currentSpace = space!;

    final imageUrl =
    currentSpace.images.isNotEmpty
        ? _buildMediaUrl(
      currentSpace.images.first,
    )
        : '';

    return Stack(
      children: [
        SizedBox(
          height: 210,
          width: double.infinity,
          child: imageUrl.isNotEmpty
              ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) {
              return _imagePlaceholder();
            },
          )
              : _imagePlaceholder(),
        ),

        Positioned(
          left: 12,
          top: 12,
          child: Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration:
            BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),
            child: Text(
              _categoryName(
                currentSpace,
              ),
              style:
              const TextStyle(
                color: AppColors
                    .lightTextPrimary,
                fontSize: 7,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),

        if (currentSpace.images.length > 1)
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration:
              BoxDecoration(
                color: Colors.black
                    .withValues(
                  alpha: 0.65,
                ),
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                '1 / ${currentSpace.images.length}',
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 7,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final currentSpace = space!;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                currentSpace.name,
                style:
                const TextStyle(
                  color: AppColors
                      .lightTextPrimary,
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(
                    currentSpace.price,
                  ),
                  style:
                  const TextStyle(
                    color: AppColors
                        .lightPrimary,
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const Text(
                  'per hour',
                  style:
                  TextStyle(
                    color: AppColors
                        .lightTextSecondary,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 11,
              color: AppColors
                  .lightTextSecondary,
            ),

            const SizedBox(
              width: 4,
            ),

            Expanded(
              child: Text(
                currentSpace.address,
                style:
                const TextStyle(
                  color: AppColors
                      .lightTextSecondary,
                  fontSize: 7.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 5,
        ),

        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppColors
                  .dashboardGreen,
              size: 11,
            ),

            const SizedBox(
              width: 4,
            ),

            Text(
              'Open: $_displayTiming',
              style:
              const TextStyle(
                color: AppColors
                    .dashboardGreen,
                fontSize: 7.5,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats() {
    final currentSpace = space!;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon:
            Icons.person_outline,
            value:
            '${currentSpace.seatCount}',
            label:
            'Capacity',
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: _statCard(
            icon: Icons
                .card_giftcard_outlined,
            value: '₹0',
            label:
            'Visit Cost',
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      height: 82,
      decoration:
      BoxDecoration(
        color:
        AppColors.lightSurface,
        borderRadius:
        BorderRadius.circular(
          11,
        ),
        border: Border.all(
          color:
          AppColors.lightBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 17,
            color:
            AppColors.lightPrimary,
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            value,
            style:
            const TextStyle(
              color: AppColors
                  .lightTextPrimary,
              fontSize: 13,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          Text(
            label,
            style:
            const TextStyle(
              color: AppColors
                  .lightTextSecondary,
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VISITOR
  // ============================================================

  Widget _buildVisitorCard() {
    return _sectionCard(
      title:
      'VISITOR DETAILS',
      icon:
      Icons.person_outline_rounded,
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _field(
              label:
              'FULL NAME',
              controller:
              visitorNameController,
              hint:
              'e.g. John Doe',
              icon:
              Icons.person_outline,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Required';
                }

                return null;
              },
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: _field(
              label:
              'MOBILE NUMBER',
              controller:
              mobileController,
              hint:
              'e.g. 9876543210',
              icon:
              Icons.phone_outlined,
              keyboardType:
              TextInputType.phone,
              validator: (value) {
                final text =
                    value?.trim() ??
                        '';

                if (!RegExp(
                  r'^[6-9]\d{9}$',
                ).hasMatch(
                  text,
                )) {
                  return 'Invalid mobile';
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TIME SLOT
  // ============================================================

  Widget _buildTimeSlotCard() {
    return _sectionCard(
      title:
      'VISIT TIME SLOT',
      icon: Icons
          .calendar_month_outlined,
      child: Column(
        children: [
          Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration:
            BoxDecoration(
              color:
              AppColors.softOrange,
              borderRadius:
              BorderRadius.circular(
                8,
              ),
            ),
            child: Text(
              '◷ Available: $_displayTiming',
              style:
              const TextStyle(
                color: AppColors
                    .dashboardOrange,
                fontSize: 7.5,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _field(
                  label:
                  'START DATE',
                  controller:
                  dateController,
                  hint:
                  'dd-mm-yyyy',
                  icon: Icons
                      .calendar_today_outlined,
                  readOnly:
                  true,
                  onTap:
                  _pickDate,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Required';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: _field(
                  label:
                  'START TIME',
                  controller:
                  timeController,
                  hint:
                  '--:--',
                  icon: Icons
                      .access_time_outlined,
                  readOnly:
                  true,
                  onTap:
                  _pickTime,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Required';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(
                width: 7,
              ),

              SizedBox(
                width: 58,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      ' ',
                      style:
                      TextStyle(
                        fontSize: 6,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Container(
                      height: 37,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 7,
                      ),
                      decoration:
                      BoxDecoration(
                        color: AppColors
                            .lightSurface,
                        borderRadius:
                        BorderRadius.circular(
                          8,
                        ),
                        border:
                        Border.all(
                          color: AppColors
                              .lightBorder,
                        ),
                      ),
                      child:
                      DropdownButtonHideUnderline(
                        child:
                        DropdownButton<String>(
                          value:
                          selectedPeriod,
                          isExpanded:
                          true,
                          style:
                          const TextStyle(
                            color: AppColors
                                .lightTextPrimary,
                            fontSize: 8,
                          ),
                          items:
                          const [
                            DropdownMenuItem(
                              value:
                              'AM',
                              child:
                              Text('AM'),
                            ),
                            DropdownMenuItem(
                              value:
                              'PM',
                              child:
                              Text('PM'),
                            ),
                          ],
                          onChanged:
                              (value) {
                            if (value ==
                                null) {
                              return;
                            }

                            setState(
                                  () {
                                selectedPeriod =
                                    value;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COMMON UI
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(
        11,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.lightSurface,
        borderRadius:
        BorderRadius.circular(
          11,
        ),
        border: Border.all(
          color:
          AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment:
                Alignment.center,
                decoration:
                BoxDecoration(
                  color: AppColors
                      .lightPrimary,
                  borderRadius:
                  BorderRadius.circular(
                    8,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                  Colors.white,
                  size: 15,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                title,
                style:
                const TextStyle(
                  color: AppColors
                      .lightTextPrimary,
                  fontSize: 10,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          child,
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)?
    validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
          const TextStyle(
            color: AppColors
                .lightTextSecondary,
            fontSize: 6.5,
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        TextFormField(
          controller:
          controller,
          keyboardType:
          keyboardType,
          readOnly:
          readOnly,
          onTap:
          onTap,
          validator:
          validator,
          style:
          const TextStyle(
            color: AppColors
                .lightTextPrimary,
            fontSize: 8,
          ),
          decoration:
          InputDecoration(
            hintText:
            hint,
            hintStyle:
            const TextStyle(
              color: AppColors
                  .lightTextSecondary,
              fontSize: 7,
            ),
            prefixIcon:
            Icon(
              icon,
              size: 12,
              color: AppColors
                  .lightTextSecondary,
            ),
            prefixIconConstraints:
            const BoxConstraints(
              minWidth: 30,
            ),
            isDense:
            true,
            filled:
            true,
            fillColor:
            AppColors
                .lightBackground,
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                8,
              ),
              borderSide:
              const BorderSide(
                color: AppColors
                    .lightBorder,
              ),
            ),
            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                8,
              ),
              borderSide:
              const BorderSide(
                color: AppColors
                    .lightPrimary,
              ),
            ),
            errorBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                8,
              ),
              borderSide:
              const BorderSide(
                color: AppColors
                    .dashboardRed,
              ),
            ),
            focusedErrorBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                8,
              ),
              borderSide:
              const BorderSide(
                color: AppColors
                    .dashboardRed,
              ),
            ),
            errorStyle:
            const TextStyle(
              fontSize: 6,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RELATED
  // ============================================================

  Widget _buildRelatedSpaces() {
    return SizedBox(
      height: 155,
      child: ListView(
        scrollDirection:
        Axis.horizontal,
        children: [
          _relatedCard(
            image:
            'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d',
            title:
            'Z FB BDN X - KYU JBM',
            location:
            'Did ch kk vnndm',
            price:
            '₹652816',
          ),

          const SizedBox(
            width: 9,
          ),

          _relatedCard(
            image:
            'https://images.unsplash.com/photo-1497366811353-6870744d04b2',
            title:
            'DUE CABIN - TEST',
            location:
            'Hyderabad',
            price:
            '₹50',
          ),
        ],
      ),
    );
  }

  Widget _relatedCard({
    required String image,
    required String title,
    required String location,
    required String price,
  }) {
    return Container(
      width: 150,
      clipBehavior:
      Clip.antiAlias,
      decoration:
      BoxDecoration(
        color:
        AppColors.lightSurface,
        borderRadius:
        BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color:
          AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Image.network(
            image,
            width:
            double.infinity,
            height: 85,
            fit:
            BoxFit.cover,
            errorBuilder:
                (_, __, ___) {
              return Container(
                height: 85,
                color:
                AppColors.softPurple,
                alignment:
                Alignment.center,
                child:
                const Icon(
                  Icons
                      .image_not_supported_outlined,
                  color: AppColors
                      .lightPrimary,
                ),
              );
            },
          ),

          Padding(
            padding:
            const EdgeInsets.all(
              7,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color: AppColors
                        .lightTextPrimary,
                    fontSize: 7.5,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  location,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color: AppColors
                        .lightTextSecondary,
                    fontSize: 6.5,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '$price / hr',
                  style:
                  const TextStyle(
                    color: AppColors
                        .lightTextPrimary,
                    fontSize: 8,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PICKERS
  // ============================================================

  Future<void> _pickDate() async {
    final now =
    DateTime.now();

    final result =
    await showDatePicker(
      context:
      context,
      initialDate:
      now,
      firstDate:
      now,
      lastDate:
      DateTime(
        now.year + 2,
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      dateController.text =
      '${result.day.toString().padLeft(2, '0')}-'
          '${result.month.toString().padLeft(2, '0')}-'
          '${result.year}';
    });
  }

  Future<void> _pickTime() async {
    final result =
    await showTimePicker(
      context:
      context,
      initialTime:
      TimeOfDay.now(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      final displayHour =
      result.hourOfPeriod == 0
          ? 12
          : result.hourOfPeriod;

      timeController.text =
      '$displayHour:'
          '${result.minute.toString().padLeft(2, '0')}';

      selectedPeriod =
      result.period ==
          DayPeriod.am
          ? 'AM'
          : 'PM';
    });
  }

  // ============================================================
  // CONFIRM
  // ============================================================

  Future<void> _confirmVisit() async {
    // Prevent duplicate API calls
    if (isSubmitting) {
      return;
    }

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (space == null) {
      return;
    }

    if (StorageService.userId.trim().isEmpty) {
      Get.snackbar(
        'Session Error',
        'User session not found. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final startDate = _toApiDate(
      dateController.text,
    );

    final startTime = _to24Hour(
      timeController.text,
      selectedPeriod,
    );

    if (startDate.isEmpty || startTime.isEmpty) {
      Get.snackbar(
        'Invalid Visit Time',
        'Please select a valid date and time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      setState(() {
        isSubmitting = true;
      });

      final response =
      await _bookingService.createVisit(
        cabinId: space!.id,
        name: visitorNameController.text.trim(),
        mobile: mobileController.text.trim(),
        email: StorageService.userEmail,
        startDate: startDate,
        startTime: startTime,
      );

      if (!mounted) {
        return;
      }

      final message =
          response['message']?.toString() ??
              'Site visit scheduled successfully.';

      // First close Site Visit page
      // Get.back(
      //   result: true,
      // );


      final navigationController =
      Get.find<NavigationController>();

      navigationController.changeTab(3);

      Get.until(
            (route) =>
        route.settings.name ==
            AppRoutes.dashboard,
      );

      // Get.snackbar(
      //   'Visit Confirmed',
      //   message,
      //   snackPosition:
      //   SnackPosition.BOTTOM,
      // );

      // Then show success message on previous screen
      Get.snackbar(
        'Visit Confirmed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(
          seconds: 4,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      Get.snackbar(
        'Visit Failed',
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _toApiDate(
      String value,
      ) {
    final parts =
    value.split('-');

    if (parts.length != 3) {
      return '';
    }

    final day =
    int.tryParse(parts[0]);

    final month =
    int.tryParse(parts[1]);

    final year =
    int.tryParse(parts[2]);

    if (day == null ||
        month == null ||
        year == null) {
      return '';
    }

    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  String _to24Hour(
      String value,
      String period,
      ) {
    final parts =
    value.split(':');

    if (parts.length != 2) {
      return '';
    }

    var hour =
        int.tryParse(
          parts[0],
        ) ??
            -1;

    final minute =
        int.tryParse(
          parts[1],
        ) ??
            -1;

    if (hour < 0 ||
        minute < 0) {
      return '';
    }

    if (period == 'PM' &&
        hour != 12) {
      hour += 12;
    }

    if (period == 'AM' &&
        hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }



  String get _displayTiming {
    final currentSpace = space!;

    if (currentSpace.is24x7) {
      return '24/7';
    }

    return '${_formatTime(currentSpace.openTime)} - '
        '${_formatTime(currentSpace.closeTime)}';
  }

  String _categoryName(
      SpaceModel value,
      ) {
    if (value.isChamber) {
      return 'Medical Chamber';
    }

    if (value.isCafe) {
      return 'Cafe Workspace';
    }

    if (value.isExclusive) {
      return 'Private Office';
    }

    return 'Co-Working';
  }

  String _formatPrice(
      double value,
      ) {
    if (value % 1 == 0) {
      return '₹${value.toInt()}';
    }

    return '₹${value.toStringAsFixed(2)}';
  }

  String _formatTime(
      String value,
      ) {
    if (value.trim().isEmpty) {
      return '--';
    }

    final parts =
    value.split(':');

    if (parts.length < 2) {
      return value;
    }

    final hour =
    int.tryParse(
      parts[0],
    );

    final minute =
    int.tryParse(
      parts[1],
    );

    if (hour == null ||
        minute == null) {
      return value;
    }

    final period =
    hour >= 12
        ? 'PM'
        : 'AM';

    var displayHour =
        hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    return '$displayHour:'
        '${minute.toString().padLeft(2, '0')} '
        '$period';
  }

  String _buildMediaUrl(
      String path,
      ) {
    final value =
    path.trim();

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith(
      'http://',
    ) ||
        value.startsWith(
          'https://',
        )) {
      return value;
    }

    final normalized =
    value.replaceAll(
      '\\',
      '/',
    );

    return 'https://spaceapi.iryax.com/$normalized';
  }

  Widget _imagePlaceholder() {
    return Container(
      color:
      AppColors.softPurple,
      alignment:
      Alignment.center,
      child: const Icon(
        Icons
            .image_not_supported_outlined,
        color:
        AppColors.lightPrimary,
        size: 32,
      ),
    );
  }
}