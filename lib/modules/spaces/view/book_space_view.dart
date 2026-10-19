import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/app/routes/app_routes.dart';

import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/service/booking_service.dart';
import 'package:iryax_spaces/modules/navigation/controller/navigation_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';

import '../../../app/themes/app_colors.dart';

class BookSpaceView extends StatefulWidget {
  const BookSpaceView({
    super.key,
  });

  @override
  State<BookSpaceView> createState() =>
      _BookSpaceViewState();
}

class _BookSpaceViewState
    extends State<BookSpaceView> {
  final formKey = GlobalKey<FormState>();

  final BookingService _bookingService =
  BookingService();

  final fullNameController =
  TextEditingController();

  final mobileController =
  TextEditingController();

  final startDateController =
  TextEditingController();

  final endDateController =
  TextEditingController();

  final startTimeController =
  TextEditingController();

  final endTimeController =
  TextEditingController();

  SpaceModel? space;

  final Set<String> selectedSeatIds = {};

  bool acceptedTerms = false;
  bool isSubmitting = false;

  String startPeriod = 'AM';
  String endPeriod = 'PM';

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments;

    if (arguments is SpaceModel) {
      space = arguments;
    }

    fullNameController.text =
        StorageService.userName;

    mobileController.text =
        StorageService.userMobile;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    mobileController.dispose();

    startDateController.dispose();
    endDateController.dispose();

    startTimeController.dispose();
    endTimeController.dispose();

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
                color: AppColors
                    .lightTextPrimary,
                size: 13,
              ),
              SizedBox(width: 6),
              Text(
                'Book Space',
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
          padding:
          const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            28,
          ),
          children: [
            _buildWorkspaceCard(),

            const SizedBox(
              height: 10,
            ),

            if (space!.seats.isNotEmpty)
              _buildSeatCard(),

            if (space!.seats.isNotEmpty)
              const SizedBox(
                height: 10,
              ),

            const Row(
              children: [
                Icon(
                  Icons
                      .verified_user_outlined,
                  color: AppColors
                      .dashboardGreen,
                  size: 12,
                ),
                SizedBox(width: 5),
                Text(
                  'Verified professional workspace',
                  style: TextStyle(
                    color: AppColors
                        .dashboardGreen,
                    fontSize: 7.5,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            _buildClientCredential(),

            const SizedBox(
              height: 10,
            ),

            _buildPayOnCounter(),

            const SizedBox(
              height: 10,
            ),

            _buildBookingSchedule(),

            const SizedBox(
              height: 10,
            ),

            if (_bookingSlots
                .isNotEmpty)
              _buildDailySchedule(),

            if (_bookingSlots
                .isNotEmpty)
              const SizedBox(
                height: 14,
              ),

            _buildTermsCard(),

            const SizedBox(
              height: 12,
            ),

            _buildPriceSummary(),

            const SizedBox(
              height: 10,
            ),

            SizedBox(
              height: 42,
              child: DecoratedBox(
                decoration:
                BoxDecoration(
                  gradient:
                  const LinearGradient(
                    colors: [
                      AppColors
                          .gradientBlueStart,
                      AppColors
                          .gradientPurpleEnd,
                    ],
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: TextButton(
                  onPressed:
                  isSubmitting
                      ? null
                      : _confirmBooking,
                  child:
                  isSubmitting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      Colors.white,
                    ),
                  )
                      : Text(
                    'Confirm Booking - ${_formatPrice(_totalPrice)}',
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize: 10,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SPACE
  // ============================================================

  Widget _buildWorkspaceCard() {
    final currentSpace =
    space!;

    final imageUrl =
    currentSpace.images
        .isNotEmpty
        ? _buildMediaUrl(
      currentSpace
          .images.first,
    )
        : '';

    return Container(
      clipBehavior:
      Clip.antiAlias,
      decoration: BoxDecoration(
        color:
        AppColors.lightSurface,
        borderRadius:
        BorderRadius.circular(
          12,
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
          Stack(
            children: [
              SizedBox(
                height: 165,
                width: double.infinity,
                child:
                imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit:
                  BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) {
                    return _imagePlaceholder();
                  },
                )
                    : _imagePlaceholder(),
              ),

              Positioned(
                left: 9,
                top: 9,
                child: Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,
                    borderRadius:
                    BorderRadius
                        .circular(
                      14,
                    ),
                  ),
                  child: Text(
                    currentSpace
                        .cabinType
                        .isEmpty
                        ? 'Standard'
                        : currentSpace
                        .cabinType,
                    style:
                    const TextStyle(
                      color: AppColors
                          .lightTextPrimary,
                      fontSize: 6.5,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 9,
                bottom: 9,
                child: Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.black
                        .withValues(
                      alpha: 0.65,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      8,
                    ),
                  ),
                  child: Text(
                    '◷ ${_displayTiming}',
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontSize: 6.5,
                      fontWeight:
                      FontWeight
                          .w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding:
            const EdgeInsets.all(
              10,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Expanded(
                      child: Text(
                        currentSpace
                            .name,
                        style:
                        const TextStyle(
                          color: AppColors
                              .lightTextPrimary,
                          fontSize: 11,
                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .end,
                      children: [
                        Text(
                          _formatPrice(
                            currentSpace
                                .price,
                          ),
                          style:
                          const TextStyle(
                            color: AppColors
                                .lightPrimary,
                            fontSize: 13,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                        const Text(
                          'per hour',
                          style:
                          TextStyle(
                            color: AppColors
                                .lightTextSecondary,
                            fontSize: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(
                  height: 7,
                ),

                _infoRow(
                  Icons
                      .location_on_outlined,
                  currentSpace
                      .address,
                ),

                const SizedBox(
                  height: 3,
                ),

                _infoRow(
                  Icons
                      .access_time_rounded,
                  'Open: $_displayTiming',
                  color:
                  AppColors
                      .dashboardGreen,
                ),

                const SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                      _smallStat(
                        Icons
                            .person_outline,
                        '${currentSpace.seatCount}',
                        'Capacity',
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child:
                      _smallStat(
                        Icons
                            .meeting_room_outlined,
                        currentSpace
                            .cabinType,
                        'Space',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                const Divider(
                  height: 1,
                  color: AppColors
                      .lightBorder,
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Amenities',
                  style:
                  TextStyle(
                    color: AppColors
                        .lightTextPrimary,
                    fontSize: 7.5,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                _buildAmenities(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    final data =
        space!.amenities;

    final items =
    <String>[];

    if (data.wifi) {
      items.add('Wifi');
    }

    if (data.parking) {
      items.add('Parking');
    }

    if (data.lockers) {
      items.add('Lockers');
    }

    if (data.comfortSeating) {
      items.add(
        'Comfort Seating',
      );
    }

    if (data.privateWashroom) {
      items.add(
        'Private Washroom',
      );
    }

    if (data.secureAccess) {
      items.add(
        'Secure Access',
      );
    }

    if (data.coffee) {
      items.add('Coffee');
    }

    if (data.ac) {
      items.add('AC');
    }

    if (data.tv) {
      items.add('TV');
    }

    if (data.printer) {
      items.add('Printer');
    }

    if (data.phone) {
      items.add('Phone');
    }

    if (data.gym) {
      items.add('Gym');
    }

    if (items.isEmpty) {
      return const Text(
        'No amenities listed.',
        style: TextStyle(
          color: AppColors
              .lightTextSecondary,
          fontSize: 7,
        ),
      );
    }

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: items
          .map(
        _amenityChip,
      )
          .toList(),
    );
  }

  // ============================================================
  // SEATS
  // ============================================================

  Widget _buildSeatCard() {
    final seats =
        space!.seats;

    return Container(
      padding:
      const EdgeInsets.all(
        11,
      ),
      decoration: BoxDecoration(
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
                  gradient:
                  const LinearGradient(
                    colors: [
                      AppColors
                          .gradientBlueStart,
                      AppColors
                          .gradientPurpleEnd,
                    ],
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    8,
                  ),
                ),
                child: const Icon(
                  Icons
                      .person_outline,
                  color:
                  Colors.white,
                  size: 15,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      'Select Seats',
                      style:
                      TextStyle(
                        color: AppColors
                            .lightTextPrimary,
                        fontSize: 10,
                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),
                    Text(
                      'Additional charge ₹100 per selected seat',
                      style:
                      TextStyle(
                        color: AppColors
                            .lightTextSecondary,
                        fontSize: 6.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children:
            seats.map(
                  (seat) {
                final selected =
                selectedSeatIds
                    .contains(
                  seat.id,
                );

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        selectedSeatIds
                            .remove(
                          seat.id,
                        );
                      } else {
                        selectedSeatIds
                            .add(
                          seat.id,
                        );
                      }
                    });
                  },
                  borderRadius:
                  BorderRadius
                      .circular(
                    8,
                  ),
                  child: Container(
                    width: 52,
                    height: 36,
                    alignment:
                    Alignment.center,
                    decoration:
                    BoxDecoration(
                      color: selected
                          ? AppColors
                          .lightPrimary
                          : AppColors
                          .lightBackground,
                      borderRadius:
                      BorderRadius
                          .circular(
                        8,
                      ),
                      border:
                      Border.all(
                        color: selected
                            ? AppColors
                            .lightPrimary
                            : AppColors
                            .lightBorder,
                      ),
                    ),
                    child: Text(
                      seat.number > 0
                          ? '${seat.number}'
                          : seat.name,
                      style:
                      TextStyle(
                        color: selected
                            ? Colors.white
                            : AppColors
                            .lightTextPrimary,
                        fontSize: 8,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            selectedSeatIds.isEmpty
                ? 'No seats selected. You can book without selecting seats.'
                : '${selectedSeatIds.length} seat(s) selected.',
            style:
            const TextStyle(
              color: AppColors
                  .lightTextSecondary,
              fontSize: 6.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLIENT
  // ============================================================

  Widget _buildClientCredential() {
    return _sectionCard(
      title:
      'CLIENT CREDENTIAL',
      icon:
      Icons.person_outline,
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _field(
              label:
              'FULL NAME',
              controller:
              fullNameController,
              hint:
              'e.g. John Doe',
              icon:
              Icons.person_outline,
              validator: (value) {
                if (value == null ||
                    value
                        .trim()
                        .isEmpty) {
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
  // PAYMENT
  // ============================================================

  Widget _buildPayOnCounter() {
    return Container(
      padding:
      const EdgeInsets.all(
        10,
      ),
      decoration: BoxDecoration(
        color:
        AppColors.softGreen,
        borderRadius:
        BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color: AppColors
              .dashboardGreen
              .withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons
                .payments_outlined,
            color: AppColors
                .dashboardGreen,
            size: 18,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  'Pay on Counter',
                  style:
                  TextStyle(
                    color: AppColors
                        .dashboardGreen,
                    fontSize: 9,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),
                Text(
                  'Pay cash when you arrive at the workspace',
                  style:
                  TextStyle(
                    color: AppColors
                        .dashboardGreen,
                    fontSize: 6.5,
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
  // SCHEDULE
  // ============================================================

  Widget _buildBookingSchedule() {
    return _sectionCard(
      title:
      'BOOKING SCHEDULE',
      icon: Icons
          .calendar_month_outlined,
      child: Column(
        children: [
          Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 9,
              vertical: 8,
            ),
            decoration:
            BoxDecoration(
              color:
              AppColors.softOrange,
              borderRadius:
              BorderRadius
                  .circular(
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
            children: [
              Expanded(
                child: _field(
                  label:
                  'START DATE',
                  controller:
                  startDateController,
                  hint:
                  'dd-mm-yyyy',
                  icon: Icons
                      .calendar_today_outlined,
                  readOnly: true,
                  onTap: () {
                    _pickDate(
                      startDateController,
                    );
                  },
                  validator:
                  _requiredValidator,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: _field(
                  label:
                  'END DATE',
                  controller:
                  endDateController,
                  hint:
                  'dd-mm-yyyy',
                  icon: Icons
                      .calendar_today_outlined,
                  readOnly: true,
                  onTap: () {
                    _pickDate(
                      endDateController,
                    );
                  },
                  validator:
                  _requiredValidator,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              Expanded(
                child: _field(
                  label:
                  'START TIME',
                  controller:
                  startTimeController,
                  hint: '--:--',
                  icon: Icons
                      .access_time_outlined,
                  readOnly: true,
                  onTap: () {
                    _pickTime(
                      startTimeController,
                      isStart: true,
                    );
                  },
                  validator:
                  _requiredValidator,
                ),
              ),

              const SizedBox(
                width: 6,
              ),

              _periodBox(
                startPeriod,
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: _field(
                  label:
                  'END TIME',
                  controller:
                  endTimeController,
                  hint: '--:--',
                  icon: Icons
                      .access_time_outlined,
                  readOnly: true,
                  onTap: () {
                    _pickTime(
                      endTimeController,
                      isStart: false,
                    );
                  },
                  validator:
                  _requiredValidator,
                ),
              ),

              const SizedBox(
                width: 6,
              ),

              _periodBox(
                endPeriod,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _periodBox(
      String value,
      ) {
    return Container(
      width: 48,
      height: 37,
      margin:
      const EdgeInsets.only(
        top: 18,
      ),
      alignment:
      Alignment.center,
      decoration: BoxDecoration(
        color:
        AppColors.lightSurface,
        borderRadius:
        BorderRadius.circular(
          8,
        ),
        border: Border.all(
          color:
          AppColors.lightBorder,
        ),
      ),
      child: Text(
        value,
        style:
        const TextStyle(
          color: AppColors
              .lightTextPrimary,
          fontSize: 8,
        ),
      ),
    );
  }

  // ============================================================
  // DAILY SCHEDULE
  // ============================================================

  Widget _buildDailySchedule() {
    return Container(
      padding:
      const EdgeInsets.all(
        10,
      ),
      decoration: BoxDecoration(
        color:
        const Color(0xFFF0F6FF),
        borderRadius:
        BorderRadius.circular(
          10,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Schedule',
            style:
            TextStyle(
              color:
              AppColors.lightPrimary,
              fontSize: 7,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          ..._bookingSlots.map(
                (slot) => Padding(
              padding:
              const EdgeInsets
                  .only(
                bottom: 6,
              ),
              child:
              _dailyScheduleItem(
                slot,
              ),
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                    'Total ',
                    style:
                    TextStyle(
                      color: AppColors
                          .lightTextSecondary,
                      fontSize: 6.5,
                    ),
                  ),
                  TextSpan(
                    text:
                    '${_totalHours.toStringAsFixed(2)} Hours',
                    style:
                    const TextStyle(
                      color: AppColors
                          .lightPrimary,
                      fontSize: 6.5,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                  TextSpan(
                    text:
                    ' across ${_bookingSlots.length} day(s)',
                    style:
                    const TextStyle(
                      color: AppColors
                          .lightTextSecondary,
                      fontSize: 6.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyScheduleItem(
      Map<String, dynamic> slot,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(
        8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          7,
        ),
        border: Border.all(
          color: AppColors
              .dashboardBlue
              .withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  slot['date']
                      ?.toString() ??
                      '',
                  style:
                  const TextStyle(
                    color: AppColors
                        .lightPrimary,
                    fontSize: 7,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '◷ ${_formatTime24(slot['startTime']?.toString() ?? '')} - ${_formatTime24(slot['endTime']?.toString() ?? '')}',
                  style:
                  const TextStyle(
                    color: AppColors
                        .lightTextSecondary,
                    fontSize: 6,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 6,
              vertical: 3,
            ),
            decoration:
            BoxDecoration(
              color:
              AppColors.softBlue,
              borderRadius:
              BorderRadius
                  .circular(
                12,
              ),
            ),
            child: Text(
              '${(slot['hours'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}h',
              style:
              const TextStyle(
                color: AppColors
                    .dashboardBlue,
                fontSize: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget _buildTermsCard() {
    return Container(
      padding:
      const EdgeInsets.all(
        11,
      ),
      decoration: BoxDecoration(
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
          const Row(
            children: [
              Icon(
                Icons
                    .description_outlined,
                color:
                AppColors.lightPrimary,
                size: 15,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Terms and Conditions',
                  style:
                  TextStyle(
                    color: AppColors
                        .lightTextPrimary,
                    fontSize: 10,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            '1. Booking confirmation is subject to availability.\n'
                '2. Cancellations must be made according to workspace policy.\n'
                '3. Users must follow workspace rules.\n'
                '4. Payment is to be made at the counter upon arrival.\n'
                '5. Additional selected seats are charged separately.',
            style:
            TextStyle(
              color: AppColors
                  .lightTextSecondary,
              fontSize: 7,
              height: 1.75,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Divider(
            height: 1,
            color:
            AppColors.lightBorder,
          ),

          const SizedBox(
            height: 7,
          ),

          InkWell(
            onTap: () {
              setState(() {
                acceptedTerms =
                !acceptedTerms;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  alignment:
                  Alignment.center,
                  decoration:
                  BoxDecoration(
                    color:
                    acceptedTerms
                        ? AppColors
                        .lightPrimary
                        : Colors
                        .transparent,
                    borderRadius:
                    BorderRadius
                        .circular(
                      3,
                    ),
                    border:
                    Border.all(
                      color:
                      acceptedTerms
                          ? AppColors
                          .lightPrimary
                          : AppColors
                          .lightTextSecondary,
                    ),
                  ),
                  child:
                  acceptedTerms
                      ? const Icon(
                    Icons
                        .check,
                    color: Colors
                        .white,
                    size: 10,
                  )
                      : null,
                ),

                const SizedBox(
                  width: 7,
                ),

                const Expanded(
                  child: Text(
                    'I have read and agree to the terms and conditions',
                    style:
                    TextStyle(
                      color: AppColors
                          .lightTextPrimary,
                      fontSize: 7,
                    ),
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
  // PRICE
  // ============================================================

  Widget _buildPriceSummary() {
    return Container(
      padding:
      const EdgeInsets.all(
        15,
      ),
      decoration: BoxDecoration(
        gradient:
        const LinearGradient(
          colors: [
            AppColors
                .gradientBlueStart,
            AppColors
                .gradientPurpleEnd,
          ],
        ),
        borderRadius:
        BorderRadius.circular(
          13,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style:
            TextStyle(
              color:
              Colors.white,
              fontSize: 10,
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          _priceRow(
            'Hours',
            '${_totalHours.toStringAsFixed(2)} h',
          ),

          _priceRow(
            'Subtotal',
            _formatPrice(
              _subtotal,
            ),
          ),

          _priceRow(
            'GST (18%)',
            _formatPrice(
              _gstAmount,
            ),
          ),

          _priceRow(
            'Extra Seats',
            _formatPrice(
              _extraCharge,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Container(
            height: 1,
            color:
            Colors.white
                .withValues(
              alpha: 0.3,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                    fontSize: 10,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),
              ),

              Text(
                _formatPrice(
                  _totalPrice,
                ),
                style:
                const TextStyle(
                  color:
                  Colors.white,
                  fontSize: 13,
                  fontWeight:
                  FontWeight
                      .w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // API SUBMIT
  // ============================================================

  Future<void> _confirmBooking() async {
    if (!(formKey.currentState
        ?.validate() ??
        false)) {
      return;
    }

    if (!acceptedTerms) {
      Get.snackbar(
        'Terms Required',
        'Please accept the terms and conditions.',
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return;
    }

    if (_bookingSlots.isEmpty ||
        _totalHours <= 0) {
      Get.snackbar(
        'Invalid Schedule',
        'Please select a valid booking schedule.',
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return;
    }

    if (StorageService.userId
        .trim()
        .isEmpty) {
      Get.snackbar(
        'Session Error',
        'User session not found. Please login again.',
        snackPosition:
        SnackPosition.BOTTOM,
      );

      return;
    }

    try {
      setState(() {
        isSubmitting = true;
      });

      final response =
      await _bookingService
          .createBooking(
        cabinId: space!.id,
        name:
        fullNameController.text
            .trim(),
        mobile:
        mobileController.text
            .trim(),
        email:
        StorageService.userEmail,
        startDate:
        _toApiDate(
          startDateController.text,
        ),
        startTime:
        _selectedStartTime24,
        endDate:
        _toApiDate(
          endDateController.text,
        ),
        endTime:
        _selectedEndTime24,
        selectedSeats:
        selectedSeatIds.toList(),
        extraCharge:
        _extraCharge,
        seatCount:
        selectedSeatIds.length,
        bookingSlots:
        _bookingSlots,
        totalPrice:
        _totalPrice,
      );

      if (!mounted) {
        return;
      }

      final message =
          response['message']?.toString() ??
              'Booking confirmed successfully.';

      if (Get.isRegistered<BookingsController>()) {
        final bookingsController =
        Get.find<BookingsController>();

        await bookingsController.loadBookings();
      }

      final navigationController =
      Get.find<NavigationController>();

      navigationController.changeTab(3);

      Get.until(
            (route) =>
        route.settings.name ==
            AppRoutes.dashboard,
      );

      Get.snackbar(
        'Booking Confirmed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(
          seconds: 4,
        ),
      );

      // Get.back(
      //   result: true,
      // );
    } catch (e) {
      if (!mounted) {
        return;
      }

      Get.snackbar(
        'Booking Failed',
        e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        ),
        snackPosition:
        SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting =
          false;
        });
      }
    }
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================

  double get _totalHours {
    return _bookingSlots.fold(
      0,
          (
          sum,
          slot,
          ) {
        return sum +
            ((slot['hours']
            as num?)
                ?.toDouble() ??
                0);
      },
    );
  }

  double get _subtotal {
    return space!.price *
        _totalHours;
  }

  double get _extraCharge {
    return selectedSeatIds.length *
        100.0;
  }

  double get _gstAmount {
    return (_subtotal +
        _extraCharge) *
        0.18;
  }

  double get _totalPrice {
    return _subtotal +
        _extraCharge +
        _gstAmount;
  }

  List<Map<String, dynamic>>
  get _bookingSlots {
    final startDate =
    _parseUiDate(
      startDateController.text,
    );

    final endDate =
    _parseUiDate(
      endDateController.text,
    );

    if (startDate == null ||
        endDate == null ||
        _selectedStartTime24
            .isEmpty ||
        _selectedEndTime24
            .isEmpty) {
      return [];
    }

    final startMinutes =
    _timeToMinutes(
      _selectedStartTime24,
    );

    final endMinutes =
    _timeToMinutes(
      _selectedEndTime24,
    );

    if (endMinutes <=
        startMinutes) {
      return [];
    }

    if (endDate.isBefore(
      startDate,
    )) {
      return [];
    }

    final hours =
        (endMinutes -
            startMinutes) /
            60.0;

    final slots =
    <Map<String, dynamic>>[];

    var currentDate =
        startDate;

    while (!currentDate
        .isAfter(
      endDate,
    )) {
      slots.add({
        'date':
        _dateToApi(
          currentDate,
        ),
        'startTime':
        _selectedStartTime24,
        'endTime':
        _selectedEndTime24,
        'hours':
        hours,
      });

      currentDate =
          currentDate.add(
            const Duration(
              days: 1,
            ),
          );
    }

    return slots;
  }

  // ============================================================
  // PICKERS
  // ============================================================

  Future<void> _pickDate(
      TextEditingController controller,
      ) async {
    final now =
    DateTime.now();

    final result =
    await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(
        now.year + 2,
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      controller.text =
      '${result.day.toString().padLeft(2, '0')}-'
          '${result.month.toString().padLeft(2, '0')}-'
          '${result.year}';
    });
  }

  Future<void> _pickTime(
      TextEditingController controller, {
        required bool isStart,
      }) async {
    final result =
    await showTimePicker(
      context: context,
      initialTime:
      TimeOfDay.now(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      controller.text =
      '${result.hourOfPeriod == 0 ? 12 : result.hourOfPeriod}'
          ':${result.minute.toString().padLeft(2, '0')}';

      if (isStart) {
        startPeriod =
        result.period ==
            DayPeriod.am
            ? 'AM'
            : 'PM';
      } else {
        endPeriod =
        result.period ==
            DayPeriod.am
            ? 'AM'
            : 'PM';
      }
    });
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String get _selectedStartTime24 {
    return _to24Hour(
      startTimeController.text,
      startPeriod,
    );
  }

  String get _selectedEndTime24 {
    return _to24Hour(
      endTimeController.text,
      endPeriod,
    );
  }

  String get _displayTiming {
    if (space!.is24x7) {
      return '24/7';
    }

    return '${_formatTime24(space!.openTime)} - ${_formatTime24(space!.closeTime)}';
  }

  String _to24Hour(
      String value,
      String period,
      ) {
    if (value.trim().isEmpty) {
      return '';
    }

    final parts =
    value.split(':');

    if (parts.length != 2) {
      return '';
    }

    var hour =
        int.tryParse(
          parts[0],
        ) ??
            0;

    final minute =
        int.tryParse(
          parts[1],
        ) ??
            0;

    if (period == 'PM' &&
        hour != 12) {
      hour += 12;
    }

    if (period == 'AM' &&
        hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  int _timeToMinutes(
      String value,
      ) {
    final parts =
    value.split(':');

    if (parts.length != 2) {
      return 0;
    }

    final hour =
        int.tryParse(
          parts[0],
        ) ??
            0;

    final minute =
        int.tryParse(
          parts[1],
        ) ??
            0;

    return hour * 60 +
        minute;
  }

  DateTime? _parseUiDate(
      String value,
      ) {
    final parts =
    value.split('-');

    if (parts.length != 3) {
      return null;
    }

    final day =
    int.tryParse(
      parts[0],
    );

    final month =
    int.tryParse(
      parts[1],
    );

    final year =
    int.tryParse(
      parts[2],
    );

    if (day == null ||
        month == null ||
        year == null) {
      return null;
    }

    return DateTime(
      year,
      month,
      day,
    );
  }

  String _toApiDate(
      String value,
      ) {
    final date =
    _parseUiDate(
      value,
    );

    if (date == null) {
      return '';
    }

    return _dateToApi(
      date,
    );
  }

  String _dateToApi(
      DateTime date,
      ) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime24(
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

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatPrice(
      double value,
      ) {
    return '₹${value.toStringAsFixed(2)}';
  }

  String _buildMediaUrl(
      String path,
      ) {
    if (path.trim().isEmpty) {
      return '';
    }

    if (path.startsWith(
      'http://',
    ) ||
        path.startsWith(
          'https://',
        )) {
      return path;
    }

    final normalized =
    path.replaceAll(
      '\\',
      '/',
    );

    return 'https://spaceapi.iryax.com/$normalized';
  }

  String? _requiredValidator(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  Widget _smallStat(
      IconData icon,
      String value,
      String label,
      ) {
    return Container(
      height: 70,
      decoration:
      BoxDecoration(
        color: AppColors
            .lightBackground,
        borderRadius:
        BorderRadius.circular(
          9,
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors
                .lightPrimary,
            size: 14,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              color: AppColors
                  .lightTextPrimary,
              fontSize: 10,
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
              fontSize: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amenityChip(
      String text,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.softPurple,
        borderRadius:
        BorderRadius.circular(
          6,
        ),
      ),
      child: Text(
        text,
        style:
        const TextStyle(
          color:
          AppColors.lightPrimary,
          fontSize: 6.5,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }

  Widget _priceRow(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
              const TextStyle(
                color:
                Colors.white70,
                fontSize: 7,
              ),
            ),
          ),
          Text(
            value,
            style:
            const TextStyle(
              color:
              Colors.white,
              fontSize: 7,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

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
                  BorderRadius
                      .circular(
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
                  FontWeight
                      .w800,
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
    String? Function(String?)? validator,
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
            prefixIcon: Icon(
              icon,
              size: 12,
              color: AppColors
                  .lightTextSecondary,
            ),
            prefixIconConstraints:
            const BoxConstraints(
              minWidth: 30,
            ),
            filled: true,
            fillColor:
            AppColors
                .lightBackground,
            isDense: true,
            contentPadding:
            const EdgeInsets
                .symmetric(
              horizontal: 8,
              vertical: 10,
            ),
            enabledBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius
                  .circular(
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
              BorderRadius
                  .circular(
                8,
              ),
              borderSide:
              const BorderSide(
                color: AppColors
                    .lightPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
      IconData icon,
      String text, {
        Color? color,
      }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 10,
          color: color ??
              AppColors
                  .lightTextSecondary,
        ),

        const SizedBox(
          width: 4,
        ),

        Expanded(
          child: Text(
            text,
            style:
            TextStyle(
              color: color ??
                  AppColors
                      .lightTextSecondary,
              fontSize: 6.8,
              fontWeight:
              color != null
                  ? FontWeight
                  .w600
                  : FontWeight
                  .normal,
            ),
          ),
        ),
      ],
    );
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
        size: 34,
      ),
    );
  }
}