import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/core/widgets/detail_nav_bar.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/service/booking_service.dart';
import 'package:iryax_spaces/modules/navigation/controller/navigation_controller.dart';
import 'package:iryax_spaces/modules/notifications/controller/notification_controller.dart';
import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/spaces/widget/booking_success_dialog.dart';

// ─── Figma Exact Design Colors ───────────────────────────────────────────────
const _kPageBg       = Color(0xFFF6F6FA); // Whisper
const _kWhite        = Color(0xFFFFFFFF);
const _kSteelGray    = Color(0xFF26204A); // Heading & Primary text
const _kManatee      = Color(0xFF8A8A99); // Subtitle, Labels, Captions
const _kGovBay       = Color(0xFF4338CA); // ₹2100 Price, Amenity text
const _kJewel        = Color(0xFF16803C); // Open timing, Verified, Pay text
const _kRoyalBlue    = Color(0xFF26204A); // Icons, selected states
const _kAthensGray   = Color(0xFFE7E7F0); // Card border, dividers
const _kSelago       = Color(0xFFF1F0FD); // Amenity tag bg, Terms icon bg
const _kWhiteIce     = Color(0xFFEAFBF0); // Pay on counter card bg
const _kCruise       = Color(0xFFC8F0D7); // Pay on counter card border
const _kEucalyptus   = Color(0xFF1F7A4D); // Pay on counter sub text
const _kVarden       = Color(0xFFFFF7E0); // Available schedule banner bg
const _kBananaMania  = Color(0xFFFBE8B0); // Available schedule banner border
const _kVesuvius     = Color(0xFFB45309); // Available clock icon
const _kScheduleGold = Color(0xFF8A5B00); // Available text
const _kInputBg      = Color(0xFFFAFAFC); // Inputs, Seat default bg
const _kPlaceholder  = Color(0xFFB4B4C2); // French Gray for input hint
const _kStatBg       = Color(0xFFF5F5FA); // Capacity & Space box bg
const _kGradStart    = Color(0xFF26204A); // Confirm btn start
const _kGradEnd      = Color(0xFF3D3568); // Confirm btn end
// ─────────────────────────────────────────────────────────────────────────────

class BookSpaceView extends StatefulWidget {
  const BookSpaceView({super.key});

  @override
  State<BookSpaceView> createState() => _BookSpaceViewState();
}

class _BookSpaceViewState extends State<BookSpaceView> {
  final _formKey = GlobalKey<FormState>();
  final _bookingService = BookingService();

  final _fullNameController  = TextEditingController();
  final _mobileController    = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController   = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController   = TextEditingController();

  SpaceModel? space;
  final Set<String> _selectedSeatIds = {};
  bool _acceptedTerms = false;
  bool _termsExpanded = true;
  bool _isSubmitting  = false;
  String _startPeriod = 'AM';
  String _endPeriod   = 'PM';
  final _termsKey = GlobalKey();
  final _termsFieldKey = GlobalKey<FormFieldState<bool>>();

  int _selectedImageIndex = 0;
  PageController? _galleryPageController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is SpaceModel) space = args;
    _fullNameController.text = StorageService.userName;
    _mobileController.text   = StorageService.userMobile;
    _galleryPageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _galleryPageController?.dispose();
    _fullNameController.dispose();
    _mobileController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
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
        pageBuilder: (_, __, ___) => _BookSpaceImageViewer(
          images: images,
          initialIndex: start,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (space == null) {
      return Scaffold(
        backgroundColor: _kPageBg,
        appBar: _buildFigmaAppBar(),
        body: const Center(child: Text('Space information not available.')),
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: _kPageBg,
        appBar: _buildFigmaAppBar(),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // 1. Image + Space Info card (Combined smoothly as in Figma)
                _buildWorkspaceCard(),

                const SizedBox(height: 12),

                // 2. Select Seats card (if seats exist)
                if (space!.effectiveSeats.isNotEmpty) ...[
                  _pad(_buildSelectSeatsCard()),
                  const SizedBox(height: 12),
                ],

                // 3. Verified professional workspace badge
                _pad(_buildVerifiedBadge()),

                const SizedBox(height: 14),

                // 4. Client Credential card
                _pad(_buildClientCredentialCard()),

                const SizedBox(height: 12),

                // 5. Pay on Counter card
                _pad(_buildPayOnCounterCard()),

                const SizedBox(height: 12),

                // 6. Booking Schedule card
                _pad(_buildBookingScheduleCard()),

                const SizedBox(height: 12),

                // 7. Daily Breakdown list (when dates are selected)
                if (_bookingSlots.isNotEmpty) ...[
                  _pad(_buildDailyBreakdown()),
                  const SizedBox(height: 12),
                ],

                // 8. Terms and Conditions card
                KeyedSubtree(key: _termsKey, child: _pad(_buildTermsCard())),

                const SizedBox(height: 14),

                // 9. Price Summary & Confirm Button
                _pad(_buildPriceSummaryCard()),

                const SizedBox(height: 14),

                _pad(_buildConfirmButton()),

                const SizedBox(height: 24),

                // 10. Related Spaces horizontal section
                _buildRelatedSpacesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pad(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: child);

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. APP BAR (Figma: pure white, top radius 20, back arrow + Book Space text)
  // ═══════════════════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildFigmaAppBar() {
    final spaceName = space?.name.trim() ?? '';
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: const BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          bottom: false,
          child: DetailNavBar(
            title: 'Book Space',
            subtitle: spaceName.isNotEmpty
                ? spaceName
                : 'Complete your booking',
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. WORKSPACE IMAGE & INFO CARD (Exact Figma Auto-layout)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWorkspaceCard() {
    final s = space!;
    final galleryImages = s.images
        .map(_mediaUrl)
        .where((url) => url.isNotEmpty)
        .toList();
    final multi = galleryImages.length > 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kAthensGray, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image gallery
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (galleryImages.isEmpty)
                    _imagePlaceholder()
                  else
                    PageView.builder(
                      controller: _galleryPageController,
                      itemCount: galleryImages.length,
                      onPageChanged: (index) {
                        setState(() => _selectedImageIndex = index);
                      },
                      itemBuilder: (_, index) {
                        return GestureDetector(
                          onTap: () =>
                              _openImageViewer(galleryImages, index),
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

                  // Soft dark overlay
                  IgnorePointer(
                    child: Container(color: Colors.black.withValues(alpha: 0.08)),
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

                  // Cabin type badge — top-left
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xF2FFFFFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.cabinType.isEmpty ? 'Standard' : s.cabinType,
                        style: const TextStyle(
                          color: _kSteelGray,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Timing badge — top-right (dots take bottom center)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xB814121E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: _kWhite,
                            size: 12,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _displayTiming,
                            style: const TextStyle(
                              color: _kWhite,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          enabled:
                              _selectedImageIndex < galleryImages.length - 1,
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
                      bottom: 12,
                      child: Center(
                        child: _galleryIndicator(galleryImages.length),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Card Content (padding: 14)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          s.name,
                          style: const TextStyle(
                            color: _kSteelGray,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatPrice(s.price),
                            style: const TextStyle(
                              color: _kGovBay,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                          const Text(
                            'per hour',
                            style: TextStyle(
                              color: _kManatee,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: _kManatee, size: 14),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          s.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _kManatee,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Open Timing (Green)
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: _kJewel, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        'Open: $_displayTiming',
                        style: const TextStyle(
                          color: _kJewel,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Capacity & Space Boxes
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          icon: Icons.person_outline,
                          value: '${s.seatCount}',
                          label: 'Capacity',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          icon: Icons.meeting_room_outlined,
                          value: s.cabinType.isEmpty ? '—' : s.cabinType,
                          label: 'Space',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Divider
                  const Divider(color: _kAthensGray, height: 1, thickness: 1),

                  const SizedBox(height: 8),

                  // Amenities Title
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      color: _kSteelGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Amenities list
                  _buildAmenitiesWrap(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _kStatBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: _kRoyalBlue, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _kSteelGray,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: _kManatee,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesWrap() {
    final a = space!.amenities;
    final items = <String>[];
    if (a.wifi) items.add('Wifi');
    if (a.lockers) items.add('Lockers');
    if (a.comfortSeating) items.add('ComfortSeating');
    if (a.privateWashroom) items.add('PrivateWashroom');
    if (a.secureAccess) items.add('SecureAccess');
    if (a.coffee) items.add('Coffee');
    if (a.ac) items.add('Ac');
    if (a.tv) items.add('Tv');
    if (a.printer) items.add('Printer');
    if (a.parking) items.add('Parking');
    if (a.phone) items.add('Phone');
    if (a.gym) items.add('Gym');

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items.map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: _kSelago,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            amenity,
            style: const TextStyle(
              color: _kGovBay,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. SELECT SEATS CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSelectSeatsCard() {
    final seats = space!.effectiveSeats;

    return _buildContainerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26204A), Color(0xFF3D3568)],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.people_outline, color: _kWhite, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Select Seats',
                    style: TextStyle(
                      color: _kSteelGray,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Choose additional seats (₹100/seat)',
                    style: TextStyle(
                      color: _kManatee,
                      fontSize: 10.3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Seat pills row
          if (seats.length <= 5)
            Row(
              children: seats.map((seat) {
                final isSelected = _selectedSeatIds.contains(seat.id);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSeatIds.remove(seat.id);
                        } else {
                          _selectedSeatIds.add(seat.id);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      height: 37,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? _kRoyalBlue : _kInputBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? _kRoyalBlue : _kAthensGray,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        seat.number > 0 ? '${seat.number}' : seat.name,
                        style: TextStyle(
                          color: isSelected ? _kWhite : _kSteelGray,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: seats.map((seat) {
                  final isSelected = _selectedSeatIds.contains(seat.id);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSeatIds.remove(seat.id);
                        } else {
                          _selectedSeatIds.add(seat.id);
                        }
                      });
                    },
                    child: Container(
                      width: 58,
                      height: 37,
                      margin: const EdgeInsets.only(right: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? _kRoyalBlue : _kInputBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? _kRoyalBlue : _kAthensGray,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        seat.number > 0 ? '${seat.number}' : seat.name,
                        style: TextStyle(
                          color: isSelected ? _kWhite : _kSteelGray,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              _selectedSeatIds.isEmpty
                  ? 'No seats selected. You can book without selecting seats.'
                  : '${_selectedSeatIds.length} seat(s) selected.',
              style: const TextStyle(
                color: _kManatee,
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. VERIFIED BADGE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVerifiedBadge() {
    return Row(
      children: const [
        Icon(Icons.verified_outlined, color: _kJewel, size: 14),
        SizedBox(width: 6),
        Text(
          'Verified professional workspace',
          style: TextStyle(
            color: _kJewel,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. CLIENT CREDENTIAL CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildClientCredentialCard() {
    return _buildContainerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with royal blue square icon
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _kRoyalBlue,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.person_outline, color: _kWhite, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'CLIENT CREDENTIAL',
                style: TextStyle(
                  color: _kSteelGray,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.35,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Two inputs: Full Name & Mobile Number
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'FULL NAME',
                  controller: _fullNameController,
                  hint: 'e.g. John Doe',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFormField(
                  label: 'MOBILE NUMBER',
                  controller: _mobileController,
                  hint: 'e.g. 9876543210',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v?.trim() ?? '')) {
                      return 'Invalid mobile';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. PAY ON COUNTER CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPayOnCounterCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kWhiteIce,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kCruise, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _kWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: _kJewel, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Pay on Counter',
                  style: TextStyle(
                    color: _kJewel,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Pay cash when you arrive at the workspace',
                  style: TextStyle(
                    color: _kEucalyptus,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. BOOKING SCHEDULE CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBookingScheduleCard() {
    return _buildContainerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _kRoyalBlue,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.calendar_month_outlined,
                    color: _kWhite, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'BOOKING SCHEDULE',
                style: TextStyle(
                  color: _kSteelGray,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.35,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Available Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _kVarden,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _kBananaMania, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: _kVesuvius, size: 14),
                const SizedBox(width: 6),
                const Text(
                  'Available: ',
                  style: TextStyle(
                    color: _kScheduleGold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _displayTiming,
                  style: const TextStyle(
                    color: _kScheduleGold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Start Date & End Date Row
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'START DATE',
                  controller: _startDateController,
                  hint: 'dd-mm-yyyy',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () => _pickDate(_startDateController),
                  validator: _requiredValidator,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFormField(
                  label: 'END DATE',
                  controller: _endDateController,
                  hint: 'dd-mm-yyyy',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: () => _pickDate(_endDateController),
                  validator: _requiredValidator,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Start Time & End Time Row with AM / PM toggle selectors
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'START TIME',
                  controller: _startTimeController,
                  hint: '--:--',
                  icon: Icons.access_time_rounded,
                  readOnly: true,
                  onTap: () => _pickTime(_startTimeController, isStart: true),
                  validator: _requiredValidator,
                ),
              ),
              const SizedBox(width: 8),
              _buildPeriodSelector(
                value: _startPeriod,
                onChanged: (v) => setState(() => _startPeriod = v),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildFormField(
                  label: 'END TIME',
                  controller: _endTimeController,
                  hint: '--:--',
                  icon: Icons.access_time_rounded,
                  readOnly: true,
                  onTap: () => _pickTime(_endTimeController, isStart: false),
                  validator: _requiredValidator,
                ),
              ),
              const SizedBox(width: 8),
              _buildPeriodSelector(
                value: _endPeriod,
                onChanged: (v) => setState(() => _endPeriod = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector({
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return InkWell(
      onTap: () {
        onChanged(value == 'AM' ? 'PM' : 'AM');
      },
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 64,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _kInputBg, // #FAFAFC
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _kAthensGray, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: _kSteelGray, // #26204A - Dark, crisp and visible
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(
              Icons.swap_vert_rounded,
              size: 16,
              color: _kManatee,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 8. DAILY BREAKDOWN (if multiple days or slots selected)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDailyBreakdown() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Schedule',
            style: TextStyle(
              color: _kRoyalBlue,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ..._bookingSlots.map((slot) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _kRoyalBlue.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot['date']?.toString() ?? '',
                              style: const TextStyle(
                                color: _kRoyalBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '◷ ${_formatTime24(slot['startTime']?.toString() ?? '')} - ${_formatTime24(slot['endTime']?.toString() ?? '')}',
                              style: const TextStyle(
                                color: _kManatee,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(slot['hours'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}h',
                          style: const TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 6),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Total ',
                    style: TextStyle(color: _kManatee, fontSize: 11),
                  ),
                  TextSpan(
                    text: '${_totalHours.toStringAsFixed(2)} Hours',
                    style: const TextStyle(
                      color: _kRoyalBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' across ${_bookingSlots.length} day(s)',
                    style: const TextStyle(color: _kManatee, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 9. TERMS AND CONDITIONS CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTermsCard() {
    return _buildContainerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _termsExpanded = !_termsExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _kSelago,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: _kGovBay, size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      color: _kSteelGray,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _termsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: _kManatee,
                  size: 20,
                ),
              ],
            ),
          ),

          if (_termsExpanded) ...[
            const SizedBox(height: 12),
            _buildTermItem('1.', 'Booking confirmation is subject to availability.'),
            _buildTermItem('2.', 'Cancellations must be made at least 24 hours before the scheduled time.'),
            _buildTermItem('3.', 'No-show bookings will be charged in full.'),
            _buildTermItem('4.', 'Users must adhere to workspace rules and regulations.'),
            _buildTermItem('5.', 'The management reserves the right to refuse entry.'),
            _buildTermItem('6.', 'Payment is to be made at the counter upon arrival.'),
            _buildTermItem('7.', 'Valid ID proof is required for check-in.'),
            _buildTermItem('8.', 'Additional time usage will be charged at the standard rate.'),
            const SizedBox(height: 6),
            const Divider(color: _kAthensGray, height: 16),
            const SizedBox(height: 6),
          ] else
            const SizedBox(height: 12),

          FormField<bool>(
            key: _termsFieldKey,
            initialValue: false,
            validator: (v) =>
                (v ?? false) ? null : 'Please accept the terms and conditions.',
            builder: (state) {
              final accepted = state.value ?? false;
              final hasError = state.hasError;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      final next = !accepted;
                      state.didChange(next);
                      setState(() => _acceptedTerms = next);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: accepted ? _kRoyalBlue : _kWhite,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: accepted
                                  ? _kRoyalBlue
                                  : (hasError
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF767676)),
                              width: 1.2,
                            ),
                          ),
                          child: accepted
                              ? const Icon(Icons.check,
                                  size: 12, color: _kWhite)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'I have read and agree to the terms and conditions',
                            style: TextStyle(
                              color: hasError
                                  ? const Color(0xFFDC2626)
                                  : _kSteelGray,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 14, color: Color(0xFFDC2626)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            state.errorText ??
                                'Please accept the terms and conditions.',
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: Text(
              num,
              style: const TextStyle(
                color: _kManatee,
                fontSize: 11.3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _kManatee,
                fontSize: 11.3,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 10. PRICE SUMMARY CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPriceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kGradStart, _kGradEnd],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Summary',
            style: TextStyle(
              color: _kWhite,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Hours', '${_totalHours.toStringAsFixed(2)} h'),
          _buildPriceRow('Subtotal', _formatPrice(_subtotal)),
          _buildPriceRow('GST (18%)', _formatPrice(_gstAmount)),
          _buildPriceRow('Extra Seats', _formatPrice(_extraCharge)),
          const SizedBox(height: 8),
          Container(height: 1, color: _kWhite.withOpacity(0.25)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    color: _kWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatPrice(_totalPrice),
                style: const TextStyle(
                  color: _kWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: _kWhite,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 11. CONFIRM BOOKING BUTTON
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildConfirmButton() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_kGradStart, _kGradEnd]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _kRoyalBlue.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextButton(
          onPressed: _isSubmitting ? null : _confirmBooking,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _kWhite),
                )
              : Text(
                  'Confirm Booking  •  ${_formatPrice(_totalPrice)}',
                  style: const TextStyle(
                    color: _kWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 12. RELATED SPACES SECTION (Horizontal List)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRelatedSpacesSection() {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Related Spaces',
            style: TextStyle(
              color: _kSteelGray,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 185,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => _buildRelatedCard(related[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedCard(SpaceModel item) {
    final imageUrl =
        item.images.isNotEmpty ? _mediaUrl(item.images.first) : '';
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
            color: _kWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kAthensGray, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                width: double.infinity,
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 100,
                        fadeInDuration: Duration.zero,
                        memCacheWidth: 400,
                        placeholder: (_, __) => const AppShimmerBox(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 0,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: _kSelago,
                          child: const Icon(
                            Icons.business,
                            color: _kRoyalBlue,
                            size: 30,
                          ),
                        ),
                      )
                    : Container(
                        color: _kSelago,
                        child: const Icon(
                          Icons.business,
                          color: _kRoyalBlue,
                          size: 30,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _kSteelGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _kManatee,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            color: _kGovBay,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          '/hr',
                          style: TextStyle(
                            color: _kManatee,
                            fontSize: 9.5,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // REUSABLE CARD CONTAINER & FORM FIELD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContainerCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kAthensGray, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildFormField({
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
            color: _kManatee,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          autofocus: false,
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          style: const TextStyle(
            color: _kSteelGray, // #26204A - Crisp dark text
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: _kPlaceholder,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, size: 15, color: _kRoyalBlue),
            prefixIconConstraints: const BoxConstraints(minWidth: 34),
            filled: true,
            fillColor: _kInputBg,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _kAthensGray, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _kRoyalBlue, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: _kSelago,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined,
          color: _kRoyalBlue, size: 40),
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
            child: Icon(icon, size: 24, color: _kRoyalBlue),
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
      borderColor: accent.withOpacity(0.35),
      borderWidth: 1,
      boxShadows: [
        BoxShadow(
          color: accent.withOpacity(0.18),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
      messageText: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _kWhite,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: _kSteelGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToTerms() {
    final ctx = _termsKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      alignment: 0.2,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUBMIT & API LOGIC
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _confirmBooking() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final formOk = _formKey.currentState?.validate() ?? false;

    if (!_acceptedTerms) {
      _termsFieldKey.currentState?.validate();
      _scrollToTerms();
      _showAppAlert(
        title: 'Terms Required',
        message: 'Please accept the terms and conditions to continue.',
        isSuccess: false,
      );
      return;
    }

    if (!formOk) return;

    if (_bookingSlots.isEmpty || _totalHours <= 0) {
      _showAppAlert(
        title: 'Invalid Schedule',
        message: 'Please select valid start & end dates and times.',
        isSuccess: false,
      );
      return;
    }

    if (_isStartDateTimeInPast()) {
      _showAppAlert(
        title: 'Invalid Time',
        message:
            'Selected start time has already passed. Please choose a future time.',
        isSuccess: false,
      );
      return;
    }

    if (StorageService.userId.trim().isEmpty) {
      _showAppAlert(
        title: 'Session Error',
        message: 'User session not found. Please log in again.',
        isSuccess: false,
      );
      return;
    }

    try {
      setState(() => _isSubmitting = true);

      final res = await _bookingService.createBooking(
        cabinId:       space!.id,
        name:          _fullNameController.text.trim(),
        mobile:        _mobileController.text.trim(),
        email:         StorageService.userEmail,
        startDate:     _toApiDate(_startDateController.text),
        startTime:     _selectedStartTime24,
        endDate:       _toApiDate(_endDateController.text),
        endTime:       _selectedEndTime24,
        selectedSeats: _selectedSeatIds.toList(),
        extraCharge:   _extraCharge,
        seatCount:     _selectedSeatIds.length,
        bookingSlots:  _bookingSlots,
        totalPrice:    _totalPrice,
      );

      if (!mounted) return;

      if (Get.isRegistered<BookingsController>()) {
        Get.find<BookingsController>().loadBookings();
      }

      FocusManager.instance.primaryFocus?.unfocus();

      final s = space!;
      final bookingId = _extractBookingId(res);
      final hoursLabel = _totalHours == _totalHours.roundToDouble()
          ? '${_totalHours.toInt()}h'
          : '${_totalHours.toStringAsFixed(1)}h';
      final peopleCount = _selectedSeatIds.isEmpty ? 1 : _selectedSeatIds.length;
      final gallery = s.images
          .map(_mediaUrl)
          .where((u) => u.isNotEmpty)
          .toList();
      final imageUrl = gallery.isEmpty ? '' : gallery.first;

      final bookingModel = BookingModel(
        id: bookingId,
        spaceName: s.name,
        location: s.address,
        spaceType: s.isChamber
            ? 'Medical Chamber'
            : s.isCafe
                ? 'Cafe & Dining'
                : 'Co-Working Space',
        startDate: _startDateController.text.trim(),
        startTime: _startTimeController.text.trim(),
        endDate: _endDateController.text.trim(),
        endTime: _endTimeController.text.trim(),
        duration: hoursLabel,
        days: '1',
        seats: peopleCount,
        amount: _formatPrice(_totalPrice),
        createdAt: DateTime.now().toIso8601String(),
        status: BookingStatus.confirmed,
        paymentStatus: PaymentStatus.pending,
        paymentMode: PaymentMode.cash,
        customerName: _fullNameController.text.trim(),
        customerEmail: StorageService.userEmail,
        customerMobile: _mobileController.text.trim(),
        totalHours: _totalHours,
        hourlyRate: s.price,
        capacity: s.capacity,
        extraCharge: _extraCharge,
        selectedSeats: _selectedSeatIds.toList(),
        bookingBasis: 'hourly',
      );

      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().refreshQuietly();
      }

      await BookingSuccessDialog.show(
        spaceName: s.name,
        location: s.address,
        dateText: _startDateController.text.trim(),
        timeText:
            '${_startTimeController.text.trim()} - ${_endTimeController.text.trim()} ($hoursLabel)',
        peopleText: peopleCount == 1 ? '1 Person' : '$peopleCount People',
        bookingId: bookingId.isEmpty
            ? 'IRYAX${DateTime.now().millisecondsSinceEpoch % 1000000}'
            : bookingId,
        hourlyRateText: '${_formatPrice(s.price)}/hr',
        totalAmountText: _formatPrice(_totalPrice),
        imageUrl: imageUrl,
        paymentLabel: 'Pay at Counter',
        booking: bookingModel,
        onViewBooking: () {
          if (Get.isRegistered<NavigationController>()) {
            Get.find<NavigationController>().changeTab(2);
          }
          Get.until((r) => r.settings.name == AppRoutes.dashboard);
        },
      );
    } catch (e) {
      if (!mounted) return;
      _showAppAlert(
        title: 'Booking Failed',
        message: e.toString().replaceFirst('Exception: ', ''),
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CALCULATIONS & HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  double get _totalHours => _bookingSlots.fold(
      0, (s, sl) => s + ((sl['hours'] as num?)?.toDouble() ?? 0));
  double get _subtotal    => space!.price * _totalHours;
  double get _extraCharge => _selectedSeatIds.length * 100.0;
  double get _gstAmount   => (_subtotal + _extraCharge) * 0.18;
  double get _totalPrice  => _subtotal + _extraCharge + _gstAmount;

  List<Map<String, dynamic>> get _bookingSlots {
    final sd = _parseUiDate(_startDateController.text);
    final ed = _parseUiDate(_endDateController.text);
    if (sd == null || ed == null || _selectedStartTime24.isEmpty || _selectedEndTime24.isEmpty) {
      return [];
    }
    final sm = _timeToMinutes(_selectedStartTime24);
    final em = _timeToMinutes(_selectedEndTime24);
    if (em <= sm || ed.isBefore(sd)) return [];

    final hours = (em - sm) / 60.0;
    final slots = <Map<String, dynamic>>[];
    var cur = sd;
    while (!cur.isAfter(ed)) {
      slots.add({
        'date':      _dateToApi(cur),
        'startTime': _selectedStartTime24,
        'endTime':   _selectedEndTime24,
        'hours':     hours,
      });
      cur = cur.add(const Duration(days: 1));
    }
    return slots;
  }

  String get _selectedStartTime24 => _to24Hour(_startTimeController.text, _startPeriod);
  String get _selectedEndTime24   => _to24Hour(_endTimeController.text,   _endPeriod);

  String get _displayTiming {
    if (space!.is24x7) return '24/7';
    return '${_formatTime24(space!.openTime)} - ${_formatTime24(space!.closeTime)}';
  }

  Future<void> _pickDate(TextEditingController c) async {
    final now = DateTime.now();
    final r = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kRoyalBlue, // #26204A header & selected day
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _kSteelGray,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (r == null) return;
    setState(() => c.text =
        '${r.day.toString().padLeft(2, '0')}-${r.month.toString().padLeft(2, '0')}-${r.year}');
    if (_isStartDateTimeInPast()) {
      _showAppAlert(
        title: 'Invalid Time',
        message:
            'Selected start time has already passed for this date. Please choose a future time.',
        isSuccess: false,
      );
    }
  }

  Future<void> _pickTime(TextEditingController c, {required bool isStart}) async {
    final r = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _kRoyalBlue, // #26204A dial hand & active elements
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _kSteelGray,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: Color(0xFFF1F0FD), // Selago soft purple background for time digits
              hourMinuteTextColor: _kRoyalBlue,
              dayPeriodColor: Color(0xFFF1F0FD),
              dayPeriodTextColor: _kRoyalBlue,
              dialBackgroundColor: Color(0xFFFAFAFC),
              dialHandColor: _kRoyalBlue,
              dialTextColor: _kSteelGray,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (r == null) return;

    final timeText =
        '${r.hourOfPeriod == 0 ? 12 : r.hourOfPeriod}:${r.minute.toString().padLeft(2, '0')}';
    final period = r.period == DayPeriod.am ? 'AM' : 'PM';

    if (isStart &&
        _isDateTimeInPast(
          _startDateController.text,
          _to24Hour(timeText, period),
        )) {
      _showAppAlert(
        title: 'Invalid Time',
        message:
            'Selected start time has already passed. Please choose a future time.',
        isSuccess: false,
      );
      return;
    }

    setState(() {
      c.text = timeText;
      if (isStart) {
        _startPeriod = period;
      } else {
        _endPeriod = period;
      }
    });
  }

  bool _isStartDateTimeInPast() =>
      _isDateTimeInPast(_startDateController.text, _selectedStartTime24);

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

  String _to24Hour(String value, String period) {
    if (value.trim().isEmpty) return '';
    final parts = value.split(':');
    if (parts.length != 2) return '';
    var hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  int _timeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  DateTime? _parseUiDate(String value) {
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  String _toApiDate(String value) {
    final date = _parseUiDate(value);
    return date == null ? '' : _dateToApi(date);
  }

  String _dateToApi(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTime24(String value) {
    if (value.trim().isEmpty) return '--';
    final parts = value.split(':');
    if (parts.length < 2) return value;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;
    final period = hour >= 12 ? 'PM' : 'AM';
    var dh = hour % 12;
    if (dh == 0) dh = 12;
    return '$dh:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatPrice(double v) =>
      '₹${v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2)}';

  String _mediaUrl(String path) {
    if (path.trim().isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return 'https://spaceapi.iryax.com/${path.replaceAll('\\', '/')}';
  }

  String _extractBookingId(Map<String, dynamic> res) {
    dynamic raw = res['data'] ?? res['booking'] ?? res;
    if (raw is Map) {
      final id = raw['_id']?.toString() ??
          raw['id']?.toString() ??
          raw['bookingId']?.toString() ??
          '';
      if (id.isNotEmpty) return id;
    }
    return res['_id']?.toString() ??
        res['id']?.toString() ??
        res['bookingId']?.toString() ??
        '';
  }

  String? _requiredValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

class _BookSpaceImageViewer extends StatefulWidget {
  const _BookSpaceImageViewer({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_BookSpaceImageViewer> createState() => _BookSpaceImageViewerState();
}

class _BookSpaceImageViewerState extends State<_BookSpaceImageViewer> {
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
