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

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments;

    if (arguments is SpaceModel) {
      space = arguments;
    }

    visitorNameController.text = StorageService.userName;
    mobileController.text = StorageService.userMobile;
  }

  @override
  void dispose() {
    visitorNameController.dispose();
    mobileController.dispose();
    dateController.dispose();
    timeController.dispose();

    super.dispose();
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

    return Scaffold(
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
                              color: Color(0xFF1E1B2E),
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
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Container(
      height: 49,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: Get.back,
        behavior: HitTestBehavior.opaque,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back,
              color: Color(0xFF1E1B2E),
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF1E1B2E),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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

    if (galleryImages.isEmpty) {
      return SizedBox(
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
      );
    }

    if (_selectedImageIndex >= galleryImages.length) {
      _selectedImageIndex = 0;
    }

    return SizedBox(
      height: 230,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            galleryImages[_selectedImageIndex],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          ),

          // Category badge top-left
          Positioned(
            left: 12,
            top: 12,
            child: _categoryBadge(currentSpace),
          ),

          // Dots indicator bottom center
          if (galleryImages.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 34,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(galleryImages.length, (index) {
                    final selected = _selectedImageIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: selected ? 14 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(selected ? 4 : 2.5),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // Image counter pill bottom center
          if (galleryImages.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xB314121E), // rgba(20, 18, 30, 0.7)
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${_selectedImageIndex + 1} / ${galleryImages.length}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
          color: Color(0xFF1E1B2E),
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
                    color: Color(0xFF1E1B2E),
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
          Icon(icon, size: 16, color: const Color(0xFF5B4FE9)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Roboto',
              color: Color(0xFF1E1B2E),
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
                                color: Color(0xFF1E1B2E),
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
                                    color: Color(0xFF5B4FE9),
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
                                color: Color(0xFF1E1B2E),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xFF1E1B2E),
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
                                      color: Color(0xFF1E1B2E),
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
                                      color: Color(0xFF1E1B2E),
                                      fontSize: 11.3,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
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
    return SizedBox(
      height: 204,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _relatedCard(
            image:
                'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d',
            badge: 'Chamber',
            title: 'Z FB BDN X - KYU JBM',
            location: 'Did ch kk vnndm',
            price: '₹652816',
          ),
          const SizedBox(width: 12),
          _relatedCard(
            image:
                'https://images.unsplash.com/photo-1497366811353-6870744d04b2',
            badge: 'Chamber',
            title: 'DUE CABIN - TEST',
            location: 'Hyderabad',
            price: '₹50',
          ),
          const SizedBox(width: 12),
          _relatedCard(
            image:
                'https://images.unsplash.com/photo-1497215728101-856f4ea42174',
            badge: 'Chamber',
            title: 'NEW DOCTOR CABIN - CABIN B',
            location: 'Hyderabad',
            price: '₹300',
          ),
        ],
      ),
    );
  }

  Widget _relatedCard({
    required String image,
    required String badge,
    required String title,
    required String location,
    required String price,
  }) {
    return Container(
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
              Image.network(
                image,
                width: 200,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: AppColors.softPurple,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xF2FFFFFF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xFF1E1B2E),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xFF1E1B2E),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
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
                        color: Color(0xFF1E1B2E),
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
                  color: const Color(0xFF5B4FE9),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: Colors.white, size: 15),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xFF1E1B2E),
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
              color: Color(0xFF1E1B2E),
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
                borderSide: const BorderSide(color: Color(0xFF5B4FE9)),
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

    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B4FE9),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E1B2E),
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
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B4FE9),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1E1B2E),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: const Color(0xFFF1F0FD),
              hourMinuteTextColor: const Color(0xFF5B4FE9),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF5B4FE9);
                }
                return const Color(0xFFF1F0FD);
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFF5B4FE9);
              }),
              dayPeriodBorderSide: const BorderSide(color: Color(0xFFE7E7F0)),
              dialBackgroundColor: const Color(0xFFFAFAFC),
              dialHandColor: const Color(0xFF5B4FE9),
              dialTextColor: const Color(0xFF1E1B2E),
              entryModeIconColor: const Color(0xFF5B4FE9),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (result == null) return;

    setState(() {
      final displayHour =
          result.hourOfPeriod == 0 ? 12 : result.hourOfPeriod;

      timeController.text =
          '$displayHour:'
          '${result.minute.toString().padLeft(2, '0')}';

      selectedPeriod = result.period == DayPeriod.am ? 'AM' : 'PM';
    });
  }

  // ============================================================
  // CONFIRM VISIT API
  // ============================================================

  Future<void> _confirmVisit() async {
    if (isSubmitting) return;

    if (!(formKey.currentState?.validate() ?? false)) return;

    if (space == null) return;

    if (StorageService.userId.trim().isEmpty) {
      Get.snackbar(
        'Session Error',
        'User session not found. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final startDate = _toApiDate(dateController.text);
    final startTime = _to24Hour(timeController.text, selectedPeriod);

    if (startDate.isEmpty || startTime.isEmpty) {
      Get.snackbar(
        'Invalid Visit Time',
        'Please select a valid date and time.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      setState(() => isSubmitting = true);

      final response = await _bookingService.createVisit(
        cabinId: space!.id,
        name: visitorNameController.text.trim(),
        mobile: mobileController.text.trim(),
        email: StorageService.userEmail,
        startDate: startDate,
        startTime: startTime,
      );

      if (!mounted) return;

      final message = response['message']?.toString() ??
          'Site visit scheduled successfully.';

      final navigationController = Get.find<NavigationController>();
      navigationController.changeTab(3);

      Get.until(
        (route) => route.settings.name == AppRoutes.dashboard,
      );

      Get.snackbar(
        'Visit Confirmed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        'Visit Failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
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
