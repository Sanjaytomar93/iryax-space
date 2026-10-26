import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/app/routes/app_routes.dart';

import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/core/widgets/detail_nav_bar.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/service/booking_service.dart';
import 'package:iryax_spaces/modules/navigation/controller/navigation_controller.dart';
import 'package:iryax_spaces/modules/notifications/controller/notification_controller.dart';
import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/spaces/widget/booking_success_dialog.dart';

import '../../../app/themes/app_colors.dart';

class SiteVisitView extends StatefulWidget {
  const SiteVisitView({
    super.key,
  });

  @override
  State<SiteVisitView> createState() => _SiteVisitViewState();
}

class _SiteVisitViewState extends State<SiteVisitView> {
  final formKey = GlobalKey<FormState>();

  final visitorNameController = TextEditingController();
  final mobileController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  final BookingService _bookingService = BookingService();

  bool isSubmitting = false;

  SpaceModel? space;

  String selectedPeriod = 'AM';

  int _selectedImageIndex = 0;
  PageController? _galleryPageController;

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments;

    if (arguments is SpaceModel) {
      space = arguments;
    }

    visitorNameController.text = StorageService.userName;
    mobileController.text = StorageService.userMobile;
    _galleryPageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _galleryPageController?.dispose();
    visitorNameController.dispose();
    mobileController.dispose();
    dateController.dispose();
    timeController.dispose();

    super.dispose();
  }

  void _goToGalleryImage(int index, int total) {
    if (total <= 0) return;
    final next = index.clamp(0, total - 1);
    if (next == _selectedImageIndex) return;
    setState(() => _selectedImageIndex = next);
    if (_galleryPageController?.hasClients == true) {
      _galleryPageController!.animateToPage(
        next,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openImageViewer(List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    final start = initialIndex.clamp(0, images.length - 1);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _SiteVisitImageViewer(
          images: images,
          initialIndex: start,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (space == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F6FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Expanded(
                child: Center(
                  child: Text(
                    'Space information not available.',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFF8A8A99),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Form(
                  key: formKey,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildGallery(),

                      // White container for Space Info & Capacity/Visit Cost stats
                      _buildHeaderContainer(),

                      // Cards & Actions section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildVisitorCard(),

                            const SizedBox(height: 14),

                            _buildTimeSlotCard(),

                            const SizedBox(height: 18),

                            _buildConfirmButton(),

                            const SizedBox(height: 24),

                            const Text(
                              'RELATED CHAMBERS',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xFF26204A),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.32,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildRelatedSpaces(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    final spaceName = space?.name.trim() ?? '';
    return DetailNavBar(
      title: 'Site Visit',
      subtitle: spaceName.isNotEmpty
          ? spaceName
          : 'Schedule your site visit',
    );
  }

  // ============================================================
  // GALLERY
  // ============================================================

  Widget _buildGallery() {
    final currentSpace = space!;

    final galleryImages = currentSpace.images
        .map(_buildMediaUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    final multi = galleryImages.length > 1;

    if (galleryImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 230,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _imagePlaceholder(),
                Positioned(
                  left: 12,
                  top: 12,
                  child: _categoryBadge(currentSpace),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 240,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _galleryPageController,
                itemCount: galleryImages.length,
                onPageChanged: (index) {
                  setState(() => _selectedImageIndex = index);
                },
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () => _openImageViewer(galleryImages, index),
                    child: CachedNetworkImage(
                      imageUrl: galleryImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      memCacheWidth: 900,
                      placeholder: (_, __) => const AppShimmerBox(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 0,
                      ),
                      errorWidget: (_, __, ___) => _imagePlaceholder(),
                    ),
                  );
                },
              ),

              if (multi)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 64,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.42),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              Positioned(
                left: 12,
                top: 12,
                child: _categoryBadge(currentSpace),
              ),

              if (multi) ...[
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _galleryArrowBtn(
                      icon: Icons.chevron_left_rounded,
                      enabled: _selectedImageIndex > 0,
                      onTap: () => _goToGalleryImage(
                        _selectedImageIndex - 1,
                        galleryImages.length,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _galleryArrowBtn(
                      icon: Icons.chevron_right_rounded,
                      enabled: _selectedImageIndex < galleryImages.length - 1,
                      onTap: () => _goToGalleryImage(
                        _selectedImageIndex + 1,
                        galleryImages.length,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14,
                  child: Center(
                    child: _galleryIndicator(galleryImages.length),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _galleryArrowBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: enabled ? 1 : 0.35,
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26204A).withValues(alpha: 0.16),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 24, color: AppColors.lightPrimary),
          ),
        ),
      ),
    );
  }

  Widget _galleryIndicator(int imageCount) {
    final indexes = _galleryDotIndexes(imageCount);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < indexes.length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: indexes[i] == _selectedImageIndex ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: indexes[i] == _selectedImageIndex
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<int> _galleryDotIndexes(int count) {
    if (count <= 3) return List<int>.generate(count, (i) => i);
    if (_selectedImageIndex <= 0) return const [0, 1, 2];
    if (_selectedImageIndex >= count - 1) {
      return [count - 3, count - 2, count - 1];
    }
    return [
      _selectedImageIndex - 1,
      _selectedImageIndex,
      _selectedImageIndex + 1,
    ];
  }

  Widget _categoryBadge(SpaceModel currentSpace) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xF2FFFFFF), // rgba(255, 255, 255, 0.95)
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _categoryName(currentSpace),
        style: const TextStyle(
          fontFamily: 'Roboto',
          color: Color(0xFF26204A),
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // HEADER CONTAINER (Space details + Capacity / Visit Cost)
  // ============================================================

  Widget _buildHeaderContainer() {
    final currentSpace = space!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  currentSpace.name,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xFF26204A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(currentSpace.price),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFF4338CA), // Governor Bay
                      fontSize: 16.9,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'per hour',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFF8A8A99),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Address row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Color(0xFF8A8A99),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  currentSpace.address.isNotEmpty
                      ? currentSpace.address
                      : 'Address not available',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xFF8A8A99),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Timing row
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 12,
                color: Color(0xFF16803C), // Jewel
              ),
              const SizedBox(width: 5),
              Text(
                'Open: $_displayTiming',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xFF16803C), // Jewel
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Capacity & Visit Cost stats
          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.person_outline_rounded,
                  value: '${currentSpace.seatCount}',
                  label: 'Capacity',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statCard(
                  icon: Icons.card_giftcard_outlined,
                  value: '0',
                  label: 'Visit Cost',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FA), // Whisper
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF26204A)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: Color(0xFF26204A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: Color(0xFF8A8A99),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VISITOR DETAILS CARD
  // ============================================================

  Widget _buildVisitorCard() {
    return _sectionCard(
      title: 'VISITOR DETAILS',
      icon: Icons.person_outline_rounded,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _field(
              label: 'FULL NAME',
              controller: visitorNameController,
              hint: 'e.g. John Doe',
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _field(
              label: 'MOBILE NUMBER',
              controller: mobileController,
              hint: 'e.g. 9876543210',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(text)) {
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
  // VISIT TIME SLOT CARD
  // ============================================================

  Widget _buildTimeSlotCard() {
    return _sectionCard(
      title: 'VISIT TIME SLOT',
      icon: Icons.calendar_month_outlined,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      child: Column(
        children: [
          // Availability banner
          Container(
            height: 33,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E0), // Varden
              border: Border.all(color: const Color(0xFFFBE8B0)), // Banana Mania
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFFB45309), // Vesuvius
                  size: 13,
                ),
                const SizedBox(width: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A5B00), // Brown
                    ),
                    children: [
                      const TextSpan(text: 'Available:  '),
                      TextSpan(text: _displayTiming),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Date and Time Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Start Date
              Expanded(
                child: _field(
                  label: 'START DATE',
                  controller: dateController,
                  hint: 'dd-mm-yyyy',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickDate,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 10),

              // Start Time (Time + AM/PM options)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'START TIME',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xFF8A8A99),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Time Input
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: timeController,
                              readOnly: true,
                              onTap: _pickTime,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xFF26204A),
                                fontSize: 12.5,
                              ),
                              decoration: InputDecoration(
                                hintText: '--:--',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color(0xFFB4B4C2),
                                  fontSize: 12.5,
                                ),
                                prefixIcon: const Icon(
                                  Icons.access_time_outlined,
                                  size: 13,
                                  color: Color(0xFFB4B4C2),
                                ),
                                prefixIconConstraints:
                                    const BoxConstraints(minWidth: 30),
                                isDense: true,
                                filled: true,
                                fillColor: const Color(0xFFFAFAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE7E7F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF26204A),
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                    color: AppColors.dashboardRed,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: const BorderSide(
                                    color: AppColors.dashboardRed,
                                  ),
                                ),
                                errorStyle: const TextStyle(fontSize: 8),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        // AM/PM Options Box
                        Container(
                          width: 64,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFC),
                            border: Border.all(color: const Color(0xFFE7E7F0)),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPeriod,
                              dropdownColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: Color(0xFF26204A),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xFF26204A),
                                fontSize: 11.3,
                                fontWeight: FontWeight.w400,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'AM',
                                  child: Text(
                                    'AM',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      color: Color(0xFF26204A),
                                      fontSize: 11.3,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'PM',
                                  child: Text(
                                    'PM',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      color: Color(0xFF26204A),
                                      fontSize: 11.3,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                if (dateController.text.isNotEmpty &&
                                    timeController.text.isNotEmpty &&
                                    _isDateTimeInPast(
                                      dateController.text,
                                      _to24Hour(timeController.text, value),
                                    )) {
                                  _showAppAlert(
                                    title: 'Invalid Time',
                                    message:
                                        'Selected visit time has already passed. Please choose a future time.',
                                    isSuccess: false,
                                  );
                                  return;
                                }
                                setState(() => selectedPeriod = value);
                              },
                            ),
                          ),
                        ),
                      ],
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
  // CONFIRM BUTTON
  // ============================================================

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _confirmVisit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16803C), // Jewel Forest Green
          foregroundColor: const Color(0xFFFBFBFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Confirm Visit',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // RELATED CHAMBERS
  // ============================================================

  Widget _buildRelatedSpaces() {
    if (!Get.isRegistered<SpacesController>() || space == null) {
      return const SizedBox.shrink();
    }

    final current = space!;
    final related = Get.find<SpacesController>()
        .spaces
        .where(
          (item) =>
              item.id != current.id &&
              item.isActive &&
              item.isChamber == current.isChamber,
        )
        .take(5)
        .toList();

    if (related.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 204,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: related.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => _relatedCard(related[index]),
      ),
    );
  }

  Widget _relatedCard(SpaceModel item) {
    final image = item.images.isNotEmpty ? _buildMediaUrl(item.images.first) : '';
    final badge = item.isChamber
        ? 'Chamber'
        : item.isCafe
            ? 'Cafe'
            : item.isExclusive
                ? 'Private'
                : 'Co-Working';
    final price = item.price % 1 == 0
        ? '₹${item.price.toStringAsFixed(0)}'
        : '₹${item.price.toStringAsFixed(2)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.offNamed(
            AppRoutes.spaceDetails,
            arguments: item,
            preventDuplicates: false,
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 200,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7E7F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: image,
                          width: 200,
                          height: 110,
                          fit: BoxFit.cover,
                          fadeInDuration: Duration.zero,
                          memCacheWidth: 400,
                          placeholder: (_, __) => const AppShimmerBox(
                            width: double.infinity,
                            height: 110,
                            borderRadius: 0,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 110,
                            color: AppColors.softPurple,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                        )
                      : Container(
                          height: 110,
                          color: AppColors.softPurple,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xF2FFFFFF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: Color(0xFF26204A),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xFF26204A),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xFF8A8A99),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xFF26204A),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '/ hr',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xFF8A8A99),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMMON UI HELPERS
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF26204A),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xFF26204A),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.39,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xFF8A8A99),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: Color(0xFF26204A),
              fontSize: 12.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Roboto',
                color: Color(0xFFB4B4C2),
                fontSize: 12.5,
              ),
              prefixIcon: Icon(
                icon,
                size: 13,
                color: const Color(0xFFB4B4C2),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 32),
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFFAFAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 11,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Color(0xFFE7E7F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Color(0xFF26204A)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: AppColors.dashboardRed),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: AppColors.dashboardRed),
              ),
              errorStyle: const TextStyle(fontSize: 8),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE / TIME PICKERS
  // ============================================================

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF26204A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF26204A),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (result == null) return;

    setState(() {
      dateController.text =
          '${result.day.toString().padLeft(2, '0')}-'
          '${result.month.toString().padLeft(2, '0')}-'
          '${result.year}';
    });

    if (timeController.text.isNotEmpty && _isVisitDateTimeInPast()) {
      _showAppAlert(
        title: 'Invalid Time',
        message:
            'Selected visit time has already passed for this date. Please choose a future time.',
        isSuccess: false,
      );
    }
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF26204A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF26204A),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: const Color(0xFFF1F0FD),
              hourMinuteTextColor: const Color(0xFF26204A),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF26204A);
                }
                return const Color(0xFFF1F0FD);
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFF26204A);
              }),
              dayPeriodBorderSide: const BorderSide(color: Color(0xFFE7E7F0)),
              dialBackgroundColor: const Color(0xFFFAFAFC),
              dialHandColor: const Color(0xFF26204A),
              dialTextColor: const Color(0xFF26204A),
              entryModeIconColor: const Color(0xFF26204A),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (result == null) return;

    final displayHour =
        result.hourOfPeriod == 0 ? 12 : result.hourOfPeriod;
    final timeText =
        '$displayHour:${result.minute.toString().padLeft(2, '0')}';
    final period = result.period == DayPeriod.am ? 'AM' : 'PM';

    if (dateController.text.isNotEmpty &&
        _isDateTimeInPast(
          dateController.text,
          _to24Hour(timeText, period),
        )) {
      _showAppAlert(
        title: 'Invalid Time',
        message:
            'Selected visit time has already passed. Please choose a future time.',
        isSuccess: false,
      );
      return;
    }

    setState(() {
      timeController.text = timeText;
      selectedPeriod = period;
    });
  }

  // ============================================================
  // CONFIRM VISIT API
  // ============================================================

  Future<void> _confirmVisit() async {
    if (isSubmitting) return;
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) return;

    if (space == null) return;

    if (StorageService.userId.trim().isEmpty) {
      _showAppAlert(
        title: 'Session Error',
        message: 'User session not found. Please login again.',
        isSuccess: false,
      );
      return;
    }

    final startDate = _toApiDate(dateController.text);
    final startTime = _to24Hour(timeController.text, selectedPeriod);

    if (startDate.isEmpty || startTime.isEmpty) {
      _showAppAlert(
        title: 'Invalid Visit Time',
        message: 'Please select a valid date and time.',
        isSuccess: false,
      );
      return;
    }

    if (_isVisitDateTimeInPast()) {
      _showAppAlert(
        title: 'Invalid Time',
        message:
            'Selected visit time has already passed. Please choose a future time.',
        isSuccess: false,
      );
      return;
    }

    try {
      setState(() => isSubmitting = true);

      await _bookingService.createVisit(
        cabinId: space!.id,
        name: visitorNameController.text.trim(),
        mobile: mobileController.text.trim(),
        email: StorageService.userEmail,
        startDate: startDate,
        startTime: startTime,
      );

      if (!mounted) return;

      if (Get.isRegistered<BookingsController>()) {
        final bc = Get.find<BookingsController>();
        bc.changeBookingTab(1);
        bc.loadSiteVisits();
      }

      FocusManager.instance.primaryFocus?.unfocus();

      final s = space!;
      final gallery = s.images
          .map(_buildMediaUrl)
          .where((u) => u.isNotEmpty)
          .toList();

      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().refreshQuietly();
      }

      await BookingSuccessDialog.show(
        headerTitle: 'Visit Scheduled',
        congratsTitle: 'Visit Scheduled!',
        congratsSubtitle:
            'You successfully scheduled your site visit. Enjoy our service!',
        spaceName: s.name,
        location: s.address,
        dateText: dateController.text.trim(),
        timeText: '${timeController.text.trim()} $selectedPeriod',
        peopleText: '',
        bookingId: 'VISIT${DateTime.now().millisecondsSinceEpoch % 1000000}',
        hourlyRateText: _formatPrice(s.price),
        totalAmountText: '',
        imageUrl: gallery.isEmpty ? '' : gallery.first,
        primaryActionLabel: 'View Visits',
        showInvoice: false,
        showPaymentAndTotal: false,
        onViewBooking: () {
          if (Get.isRegistered<BookingsController>()) {
            final bc = Get.find<BookingsController>();
            bc.changeBookingTab(1);
          }
          if (Get.isRegistered<NavigationController>()) {
            Get.find<NavigationController>().changeTab(2);
          }
          Get.until((route) => route.settings.name == AppRoutes.dashboard);
        },
      );
    } catch (e) {
      if (!mounted) return;

      _showAppAlert(
        title: 'Visit Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showAppAlert({
    required String title,
    required String message,
    bool isSuccess = false,
  }) {
    final accent =
        isSuccess ? const Color(0xFF16803C) : const Color(0xFFDC2626);
    final softBg =
        isSuccess ? const Color(0xFFEAFBF0) : const Color(0xFFFFF1F2);

    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: softBg,
      borderRadius: 14,
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 420),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      borderColor: accent.withValues(alpha: 0.35),
      borderWidth: 1,
      boxShadows: [
        BoxShadow(
          color: const Color(0xFF26204A).withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
          color: accent,
          size: 18,
        ),
      ),
      titleText: Text(
        title,
        style: TextStyle(
          color: accent,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF26204A),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _isVisitDateTimeInPast() {
    final t24 = _to24Hour(timeController.text, selectedPeriod);
    return _isDateTimeInPast(dateController.text, t24);
  }

  bool _isDateTimeInPast(String uiDate, String time24) {
    final date = _parseUiDate(uiDate);
    if (date == null || time24.isEmpty) return false;
    final parts = time24.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    final selected = DateTime(date.year, date.month, date.day, hour, minute);
    return !selected.isAfter(DateTime.now());
  }

  DateTime? _parseUiDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _toApiDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return '';

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) return '';

    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }

  String _to24Hour(String value, String period) {
    final parts = value.split(':');
    if (parts.length != 2) return '';

    var hour = int.tryParse(parts[0]) ?? -1;
    final minute = int.tryParse(parts[1]) ?? -1;

    if (hour < 0 || minute < 0) return '';

    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  String get _displayTiming {
    final currentSpace = space!;

    if (currentSpace.is24x7) return '24/7';

    return '${_formatTime(currentSpace.openTime)} - '
        '${_formatTime(currentSpace.closeTime)}';
  }

  String _categoryName(SpaceModel value) {
    if (value.isChamber) return 'Chamber';
    if (value.isCafe) return 'Cafe Workspace';
    if (value.isExclusive) return 'Private Office';
    return 'Workspace';
  }

  String _formatPrice(double value) {
    if (value % 1 == 0) return '₹${value.toInt()}';
    return '₹${value.toStringAsFixed(2)}';
  }

  String _formatTime(String value) {
    if (value.trim().isEmpty) return '--';

    final parts = value.split(':');
    if (parts.length < 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return value;

    final period = hour >= 12 ? 'PM' : 'AM';
    var displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _buildMediaUrl(String path) {
    final value = path.trim();
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final normalized = value.replaceAll('\\', '/');
    return 'https://spaceapi.iryax.com/$normalized';
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.softPurple,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.lightPrimary,
        size: 36,
      ),
    );
  }
}

class _SiteVisitImageViewer extends StatefulWidget {
  const _SiteVisitImageViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_SiteVisitImageViewer> createState() => _SiteVisitImageViewerState();
}

class _SiteVisitImageViewerState extends State<_SiteVisitImageViewer> {
  late int _index;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.images[i],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white70,
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.white.withValues(alpha: 0.14),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 18,
                child: Text(
                  '${_index + 1} / ${widget.images.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
