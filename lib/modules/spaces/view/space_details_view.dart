import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/core/widgets/detail_nav_bar.dart';
import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';
import 'package:iryax_spaces/modules/spaces/model/booked_slot_model.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/spaces/service/spaces_service.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_colors.dart';

class SpaceDetailsView extends StatefulWidget {
  const SpaceDetailsView({super.key});

  @override
  State<SpaceDetailsView> createState() => _SpaceDetailsViewState();
}

class _SpaceDetailsViewState extends State<SpaceDetailsView> {
  final SpacesService _spacesService = SpacesService();
  final ScrollController _scrollController = ScrollController();

  SpaceModel? space;

  List<BookedSlotModel> bookedSlots = [];

  bool isLoading = true;
  bool isBookedSlotsLoading = true;

  String? errorMessage;
  String? bookedSlotsError;

  int selectedImageIndex = 0;
  PageController? _galleryPageController;
  bool _showAllBookedSlots = false;

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments;

    if (arguments is SpaceModel) {
      space = arguments;

      _loadDetails(arguments.id);
    } else if (arguments is String && arguments.trim().isNotEmpty) {
      _loadDetails(arguments.trim());
    } else {
      isLoading = false;
      isBookedSlotsLoading = false;

      errorMessage = 'Space information is not available.';
    }
  }

  // ============================================================
  // API
  // ============================================================

  Future<void> _loadDetails(String cabinId) async {
    await Future.wait([_loadSpaceDetails(cabinId), _loadBookedSlots(cabinId)]);
  }

  Future<void> _loadSpaceDetails(String cabinId) async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final result = await _spacesService.getSpaceDetails(cabinId);

      if (!mounted) {
        return;
      }

      setState(() {
        space = result;

        selectedImageIndex = 0;
        _galleryPageController?.dispose();
        _galleryPageController = PageController(initialPage: 0);

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;

        errorMessage = _cleanError(e);
      });
    }
  }

  @override
  void dispose() {
    _galleryPageController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openRelatedSpace(SpaceModel item) {
    if (item.id == space?.id) return;

    setState(() {
      space = item;
      selectedImageIndex = 0;
      errorMessage = null;
      bookedSlots = [];
      bookedSlotsError = null;
      _showAllBookedSlots = false;
      _galleryPageController?.dispose();
      _galleryPageController = PageController(initialPage: 0);
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    _loadDetails(item.id);
  }

  Widget _cachedImage(
    String url, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      memCacheWidth: 900,
      placeholder: (_, __) => const AppShimmerBox(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 0,
      ),
      errorWidget: (_, __, ___) => _imagePlaceholder(),
    );
  }

  void _openImageViewer(List<String> images, int initialIndex) {
    if (images.isEmpty) return;
    final start = initialIndex.clamp(0, images.length - 1);
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _SpaceImageViewer(
          images: images,
          initialIndex: start,
          imageBuilder: (url) => _cachedImage(
            url,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _goToGalleryImage(int index, int total) {
    if (total <= 0) return;
    final next = index.clamp(0, total - 1);
    if (next == selectedImageIndex) return;
    setState(() => selectedImageIndex = next);
    if (_galleryPageController?.hasClients == true) {
      _galleryPageController!.animateToPage(
        next,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _loadBookedSlots(String cabinId) async {
    try {
      if (mounted) {
        setState(() {
          isBookedSlotsLoading = true;
          bookedSlotsError = null;
        });
      }

      final result = await _spacesService.getBookedSlots(cabinId);

      if (!mounted) {
        return;
      }

      setState(() {
        bookedSlots = result;
        _showAllBookedSlots = false;
        isBookedSlotsLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        bookedSlots.clear();
        _showAllBookedSlots = false;
        isBookedSlotsLoading = false;
        bookedSlotsError = _cleanError(e);
      });
    }
  }

  Future<void> _refresh() async {
    final currentSpace = space;

    if (currentSpace == null) {
      return;
    }

    await _loadDetails(currentSpace.id);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (space == null && isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: SpaceDetailShimmer(),
        ),
      );
    }

    if (space == null) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),

              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 42,
                          color: AppColors.dashboardRed,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          errorMessage ?? 'Unable to load space details.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
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
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Keep navigation visible while the space content scrolls.
            _buildTopBar(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.lightPrimary,
                onRefresh: _refresh,
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    if (isLoading)
                      const LinearProgressIndicator(
                        minHeight: 2,
                        color: AppColors.lightPrimary,
                      ),

                    _buildGallery(),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWorkspaceDetails(),

                          const SizedBox(height: 16),

                          _buildOperatingHours(),

                          const SizedBox(height: 16),

                          _buildAmenities(),

                          const SizedBox(height: 16),

                          _buildSpaceStatus(),

                          const SizedBox(height: 14),

                          _buildActions(),

                          const SizedBox(height: 16),

                          _buildBookedSlots(),

                          const SizedBox(height: 18),

                          _buildRelatedChambers(),

                          const SizedBox(height: 24),

                          const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_outlined,
                                  color: Color(0xFF26204A),
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'VERIFIED PROFESSIONAL WORKSPACE',
                                  style: TextStyle(
                                    color: Color(0xFF8A8A99),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),
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
    final title = space?.name.trim().isNotEmpty == true
        ? space!.name.trim()
        : 'Space Details';
    final address = space?.address.trim() ?? '';
    final type = space?.cabinType.trim() ?? '';
    final subtitle = address.isNotEmpty
        ? address
        : (type.isNotEmpty ? type : 'Manage your workspace');

    return DetailNavBar(title: title, subtitle: subtitle);
  }

  // ============================================================
  // GALLERY
  // ============================================================

  Widget _buildGallery() {
    final currentSpace = space!;

    final galleryImages =
        currentSpace.images
            .map(_buildMediaUrl)
            .where((url) => url.isNotEmpty)
            .toList();

    if (galleryImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 240,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _imagePlaceholder(),
                Positioned(
                  left: 14,
                  top: 14,
                  child: _categoryBadge(currentSpace),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (selectedImageIndex >= galleryImages.length) {
      selectedImageIndex = 0;
    }

    _galleryPageController ??=
        PageController(initialPage: selectedImageIndex);

    final multi = galleryImages.length > 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 250,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _galleryPageController,
                itemCount: galleryImages.length,
                onPageChanged: (index) {
                  setState(() => selectedImageIndex = index);
                },
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () => _openImageViewer(galleryImages, index),
                    child: _cachedImage(
                      galleryImages[index],
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
              ),

              // Soft bottom fade for dots / arrows contrast
              if (multi)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 72,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.45),
                        ],
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
                // Left arrow
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _galleryArrowBtn(
                      icon: Icons.chevron_left_rounded,
                      enabled: selectedImageIndex > 0,
                      onTap: () => _goToGalleryImage(
                        selectedImageIndex - 1,
                        galleryImages.length,
                      ),
                    ),
                  ),
                ),
                // Right arrow
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _galleryArrowBtn(
                      icon: Icons.chevron_right_rounded,
                      enabled:
                          selectedImageIndex < galleryImages.length - 1,
                      onTap: () => _goToGalleryImage(
                        selectedImageIndex + 1,
                        galleryImages.length,
                      ),
                    ),
                  ),
                ),
                // Center-bottom dots (max 3 visible)
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
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26204A).withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 26, color: AppColors.lightPrimary),
          ),
        ),
      ),
    );
  }

  /// Shows up to 3 center dots for multi-image gallery.
  Widget _galleryIndicator(int imageCount) {
    final indexes = _galleryDotIndexes(imageCount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
              width: indexes[i] == selectedImageIndex ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: indexes[i] == selectedImageIndex
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
    if (count <= 3) {
      return List<int>.generate(count, (i) => i);
    }
    if (selectedImageIndex <= 0) return const [0, 1, 2];
    if (selectedImageIndex >= count - 1) {
      return [count - 3, count - 2, count - 1];
    }
    return [
      selectedImageIndex - 1,
      selectedImageIndex,
      selectedImageIndex + 1,
    ];
  }

  Widget _categoryBadge(SpaceModel currentSpace) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _categoryName(currentSpace),
        style: TextStyle(
          color:
              currentSpace.isChamber
                  ? AppColors.dashboardRed
                  : AppColors.lightTextPrimary,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // WORKSPACE DETAILS
  // ============================================================

  Widget _buildWorkspaceDetails() {
    final currentSpace = space!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WORKSPACE DETAILS',
          style: TextStyle(
            color: Color(0xFF26204A), // Royal Blue
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          currentSpace.name.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF26204A), // Steel Gray
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F0FD), // Selago
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF26204A),
                size: 13,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  currentSpace.address.isNotEmpty
                      ? currentSpace.address
                      : 'Address not available',
                  style: const TextStyle(
                    color: Color(0xFF4338CA), // Governor bay
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Text(
          currentSpace.description.trim().isNotEmpty
              ? currentSpace.description
              : 'A premium corporate workspace designed for productivity, collaboration, and growth. Enjoy modern offices, meeting rooms, high-speed internet, business-ready amenities, secure access.',
          style: const TextStyle(
            color: Color(0xFF8A8A99), // Manatee
            fontSize: 11,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 12),

        _buildPriceChip(currentSpace.price),
      ],
    );
  }

  Widget _buildPriceChip(double price) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26204A), Color(0xFF3D3568)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HOURLY RATE',
                  style: TextStyle(
                    color: Color(0xFFC8C5E0),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _formatPrice(price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      const TextSpan(
                        text: ' / hr',
                        style: TextStyle(
                          color: Color(0xFFC8C5E0),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
  // OPERATING HOURS
  // ============================================================

  Widget _buildOperatingHours() {
    final currentSpace = space!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E7F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF4F2FF), Color(0xFFFFFFFF)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26204A), Color(0xFF4338CA)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.schedule_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPERATING HOURS',
                        style: TextStyle(
                          color: Color(0xFF26204A),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'When this space is available',
                        style: TextStyle(
                          color: Color(0xFF8A8A99),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: currentSpace.is24x7
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAFBF0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF16803C).withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.all_inclusive_rounded,
                          color: Color(0xFF16803C),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Open 24 Hours • 7 Days',
                          style: TextStyle(
                            color: Color(0xFF16803C),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildHourTile(
                          icon: Icons.wb_sunny_rounded,
                          iconColor: const Color(0xFFE5A100),
                          iconBg: const Color(0xFFFFF6DE),
                          label: 'OPENS',
                          value: _formatTime(currentSpace.openTime),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F0FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildHourTile(
                          icon: Icons.nightlight_round,
                          iconColor: const Color(0xFF4338CA),
                          iconBg: const Color(0xFFF1F0FD),
                          label: 'CLOSES',
                          value: _formatTime(currentSpace.closeTime),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E7F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 13, color: iconColor),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF8A8A99),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF26204A),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AMENITIES
  // ============================================================

  Widget _buildAmenities() {
    final currentSpace = space!;
    final data = currentSpace.amenities;

    final amenities = <({String name, IconData icon})>[];

    if (data.wifi) {
      amenities.add((name: 'High Speed Wi-Fi', icon: Icons.wifi_rounded));
    }
    if (data.lockers) {
      amenities.add((name: 'Secure Lockers', icon: Icons.lock_outline_rounded));
    }
    if (data.comfortSeating) {
      amenities.add((name: 'Comfort Seating', icon: Icons.chair_outlined));
    }
    if (data.privateWashroom) {
      amenities.add((name: 'Private Washroom', icon: Icons.wc_outlined));
    }
    if (data.secureAccess) {
      amenities.add((name: 'Secure Access', icon: Icons.lock_person_outlined));
    }
    if (data.coffee) {
      amenities.add((name: 'Coffee & Tea', icon: Icons.coffee_outlined));
    }
    if (data.ac) {
      amenities.add((name: 'Air Conditioning', icon: Icons.ac_unit_rounded));
    }
    if (data.tv) {
      amenities.add((name: 'Smart TV', icon: Icons.tv_outlined));
    }
    if (data.printer) {
      amenities.add((name: 'Printer Access', icon: Icons.print_outlined));
    }
    if (data.parking) {
      amenities.add((name: 'Parking', icon: Icons.local_parking_outlined));
    }
    if (data.phone) {
      amenities.add((name: 'Phone', icon: Icons.phone_outlined));
    }
    if (data.gym) {
      amenities.add((name: 'Gym', icon: Icons.fitness_center_outlined));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AMENITIES',
          style: TextStyle(
            color: Color(0xFF26204A),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 10),

        if (amenities.isEmpty)
          const Text(
            'No amenities listed.',
            style: TextStyle(color: Color(0xFF8A8A99), fontSize: 11),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: amenities.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (_, index) {
              final amenity = amenities[index];

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE7E7F0), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6FA), // soft whisper
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        amenity.icon,
                        color: const Color(0xFF8A8A99),
                        size: 15,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        amenity.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF26204A),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildSpaceStatus() {
    final currentSpace = space!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _statusItem(
            Icons.person_outline_rounded,
            '${currentSpace.seatCount} seats',
          ),
          const SizedBox(width: 14),
          _statusItem(
            Icons.shield_outlined,
            'Secured space',
          ),
          const SizedBox(width: 14),
          _statusItem(
            Icons.calendar_today_outlined,
            '${currentSpace.seatCount} available',
          ),
        ],
      ),
    );
  }

  Widget _statusItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF26204A), size: 14),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8A99),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions() {
    final currentSpace = space!;

    return Row(
      children: [
        // BOOK SPACE (Forest Green button)
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (!currentSpace.isActive) {
                  _showAppAlert(
                    title: 'Space Unavailable',
                    message:
                        'This space is currently inactive and not available for booking.',
                    isSuccess: false,
                  );
                  return;
                }
                Get.toNamed(
                  AppRoutes.bookSpace,
                  arguments: currentSpace,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16803C), // Jewel Forest Green
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'BOOK SPACE',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // SITE VISIT (White with border)
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                if (!currentSpace.isActive) {
                  _showAppAlert(
                    title: 'Space Unavailable',
                    message:
                        'This space is currently inactive and not accepting site visits.',
                    isSuccess: false,
                  );
                  return;
                }
                Get.toNamed(
                  AppRoutes.siteVisit,
                  arguments: currentSpace,
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE7E7F0), width: 1.2),
                foregroundColor: const Color(0xFF26204A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'SITE VISIT',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
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

  // ============================================================
  // BOOKED SLOTS
  // ============================================================

  Widget _buildBookedSlots() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E7F0), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEC), // Soft red
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFFEF4444),
                  size: 16,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Already Booked Slots',
                      style: TextStyle(
                        color: Color(0xFF26204A),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'These time slots are unavailable (Today & Future)',
                      style: TextStyle(
                        color: Color(0xFF8A8A99),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isBookedSlotsLoading)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEAEA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${bookedSlots.length} Bookings',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (isBookedSlotsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF26204A),
                ),
              ),
            )
          else if (bookedSlotsError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    bookedSlotsError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _loadBookedSlots(space!.id);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (bookedSlots.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No booked slots.',
                style: TextStyle(
                  color: Color(0xFF8A8A99),
                  fontSize: 11,
                ),
              ),
            )
          else ...[
            ..._visibleBookedSlots().map(
              (slot) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _bookedSlotCard(slot),
              ),
            ),
            if (bookedSlots.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAllBookedSlots = !_showAllBookedSlots;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F0FD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE7E7F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAllBookedSlots
                              ? 'Show less'
                              : 'View all ${bookedSlots.length} bookings',
                          style: const TextStyle(
                            color: Color(0xFF26204A),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showAllBookedSlots
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: const Color(0xFF26204A),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Latest first; 5 by default, full list when expanded.
  List<BookedSlotModel> _visibleBookedSlots() {
    final sorted = [...bookedSlots]..sort((a, b) {
      final aKey = '${a.startDate} ${a.startTime}';
      final bKey = '${b.startDate} ${b.startTime}';
      return bKey.compareTo(aKey);
    });
    if (_showAllBookedSlots || sorted.length <= 5) return sorted;
    return sorted.take(5).toList();
  }

  Widget _bookedSlotCard(BookedSlotModel slot) {
    final sameDate = slot.startDate == slot.endDate;

    final dateText =
        sameDate
            ? _formatDate(slot.startDate)
            : '${_formatDate(slot.startDate)} → ${_formatDate(slot.endDate)}';

    final timeText =
        '${_formatTime(slot.startTime)} → ${_formatTime(slot.endTime)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFFEF4444), width: 2.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 11,
                color: Color(0xFF8A8A99),
              ),
              const SizedBox(width: 5),
              const Text(
                'DATE  ',
                style: TextStyle(
                  color: Color(0xFF26204A),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  dateText,
                  style: const TextStyle(
                    color: Color(0xFF26204A),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 11,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 5),
              Text(
                timeText,
                style: const TextStyle(
                  color: Color(0xFF26204A),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'BOOKED BY',
                style: TextStyle(
                  color: Color(0xFF8A8A99),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    slot.name.isNotEmpty ? slot.name : 'User',
                    style: const TextStyle(
                      color: Color(0xFF26204A),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (slot.email.isNotEmpty)
                    Text(
                      slot.email,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RELATED CHAMBERS
  // ============================================================

  Widget _buildRelatedChambers() {
    if (!Get.isRegistered<SpacesController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<SpacesController>();

    final currentSpace = space!;

    final related =
        controller.spaces
            .where(
              (item) =>
                  item.id != currentSpace.id &&
                  item.isActive &&
                  item.isChamber == currentSpace.isChamber,
            )
            .take(5)
            .toList();

    if (related.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentSpace.isChamber ? 'RELATED CHAMBERS' : 'RELATED SPACES',
          style: const TextStyle(
            color: Color(0xFF26204A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 195,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final item = related[index];

              return _relatedCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _relatedCard(SpaceModel item) {
    final imageUrl =
        item.images.isNotEmpty ? _buildMediaUrl(item.images.first) : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openRelatedSpace(item),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 195,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7E7F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 105,
                    child:
                        imageUrl.isNotEmpty
                            ? _cachedImage(
                              imageUrl,
                              width: double.infinity,
                              height: 105,
                            )
                            : _imagePlaceholder(),
                  ),

                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _categoryName(item),
                      style: const TextStyle(
                        color: Color(0xFF26204A),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
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
                      color: Color(0xFF26204A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    item.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8A8A99),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: _formatPrice(item.price),
                          style: const TextStyle(
                            color: Color(0xFF26204A),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(
                          text: ' / hr',
                          style: TextStyle(
                            color: Color(0xFF8A8A99),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
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
  // HELPERS
  // ============================================================

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

  String _buildMediaUrl(String path) {
    final value = path.trim();

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final normalized = value.replaceAll('\\', '/');

    return 'https://spaceapi.iryax.com/$normalized';
  }

  String _categoryName(SpaceModel item) {
    if (item.isChamber) {
      return 'Medical Chamber';
    }

    if (item.isCafe) {
      return 'Cafe Workspace';
    }

    if (item.isExclusive) {
      return 'Private Office';
    }

    return 'Co-Working';
  }

  String _formatPrice(double price) {
    if (price % 1 != 0) {
      return '₹${price.toStringAsFixed(2)}';
    }

    final digits = price.toInt().abs().toString();
    if (digits.length <= 3) {
      return '₹$digits';
    }

    final head = digits.substring(0, digits.length - 3);
    final tail = digits.substring(digits.length - 3);
    final groups = <String>[];
    var rest = head;
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      groups.insert(0, rest);
    }

    final sign = price < 0 ? '-' : '';
    return '$sign₹${groups.join(',')},$tail';
  }

  String _formatTime(String value) {
    if (value.trim().isEmpty) {
      return '--';
    }

    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    final hour = int.tryParse(parts[0]);

    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return value;
    }

    final period = hour >= 12 ? 'PM' : 'AM';

    var formattedHour = hour % 12;

    if (formattedHour == 0) {
      formattedHour = 12;
    }

    return '$formattedHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

class _SpaceImageViewer extends StatefulWidget {
  const _SpaceImageViewer({
    required this.images,
    required this.initialIndex,
    required this.imageBuilder,
  });

  final List<String> images;
  final int initialIndex;
  final Widget Function(String url) imageBuilder;

  @override
  State<_SpaceImageViewer> createState() => _SpaceImageViewerState();
}

class _SpaceImageViewerState extends State<_SpaceImageViewer> {
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
                    child: widget.imageBuilder(widget.images[i]),
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

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
//
// import '../../../app/routes/app_routes.dart';
// import '../../../app/themes/app_colors.dart';
//
// class SpaceDetailsView extends StatefulWidget {
//   const SpaceDetailsView({
//     super.key,
//   });
//
//   @override
//   State<SpaceDetailsView> createState() => _SpaceDetailsViewState();
// }
//
// class _SpaceDetailsViewState extends State<SpaceDetailsView> {
//   late final SpaceModel space;
//
//   int selectedImageIndex = 1;
//
//   final List<String> galleryImages = const [
//     'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
//     'https://images.unsplash.com/photo-1497366811353-6870744d04b2',
//     'https://images.unsplash.com/photo-1497366216548-37526070297c',
//   ];
//
//   final List<_BookedSlot> bookedSlots = const [
//     _BookedSlot(
//       date: 'Thu, 13 Aug 2026',
//       time: '6:06 PM → 6:06 PM',
//       bookedBy: 'Rohith',
//       email: 'krishnnn2225@gmail.com',
//     ),
//     _BookedSlot(
//       date: 'Sat, 29 Aug 2026',
//       time: '9:00 AM → 8:00 PM',
//       bookedBy: 'sommy',
//       email: 'kumar@gmail.com',
//     ),
//     _BookedSlot(
//       date: 'Sun, 30 Aug 2026',
//       time: '5:40 PM → 8:40 PM',
//       bookedBy: 'tttytyyt',
//       email: 'kumar@gmail.com',
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     final arguments = Get.arguments;
//
//     if (arguments is SpaceModel) {
//       space = arguments;
//     } else {
//       space = const SpaceModel(
//         id: '1',
//         name: 'genz work space - Cabin-7',
//         category: 'Workspace',
//         location: 'Road No. 48, Ayyapa society, Madhapur Hyderabad.',
//         imageUrl:
//         'https://images.unsplash.com/photo-1497366754035-f200968a6e72',
//         price: '₹2100',
//         timing: '9:00 AM - 9:00 PM',
//         rating: 4.8,
//         reviews: 24,
//         seats: 5,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightBackground,
//       body: SafeArea(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             _buildTopBar(),
//             _buildGallery(),
//
//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 16,
//                 14,
//                 16,
//                 28,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildWorkspaceDetails(),
//
//                   const SizedBox(height: 16),
//
//                   _buildOperatingHours(),
//
//                   const SizedBox(height: 16),
//
//                   _buildAmenities(),
//
//                   const SizedBox(height: 16),
//
//                   _buildSpaceStatus(),
//
//                   const SizedBox(height: 14),
//
//                   _buildActions(),
//
//                   const SizedBox(height: 16),
//
//                   _buildBookedSlots(),
//
//                   const SizedBox(height: 18),
//
//                   _buildRelatedChambers(),
//
//                   const SizedBox(height: 24),
//
//                   const Center(
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.verified_user_outlined,
//                           color: AppColors.lightPrimary,
//                           size: 13,
//                         ),
//                         SizedBox(width: 6),
//                         Text(
//                           'VERIFIED PROFESSIONAL WORKSPACE',
//                           style: TextStyle(
//                             color: AppColors.lightTextSecondary,
//                             fontSize: 8,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 14),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // TOP BAR
//   // ============================================================
//
//   Widget _buildTopBar() {
//     return Container(
//       height: 52,
//       color: AppColors.lightSurface,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       alignment: Alignment.centerLeft,
//       child: InkWell(
//         onTap: Get.back,
//         borderRadius: BorderRadius.circular(8),
//         child: const Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: 4,
//             vertical: 8,
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 color: AppColors.lightTextPrimary,
//                 size: 14,
//               ),
//               SizedBox(width: 6),
//               Text(
//                 'Back',
//                 style: TextStyle(
//                   color: AppColors.lightTextPrimary,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ============================================================
//   // GALLERY
//   // ============================================================
//
//   Widget _buildGallery() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 260,
//           width: double.infinity,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               Image.network(
//                 galleryImages[selectedImageIndex],
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) {
//                   return Container(
//                     color: AppColors.softPurple,
//                     alignment: Alignment.center,
//                     child: const Icon(
//                       Icons.image_not_supported_outlined,
//                       color: AppColors.lightPrimary,
//                       size: 36,
//                     ),
//                   );
//                 },
//               ),
//
//               Positioned(
//                 left: 14,
//                 top: 14,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     space.category,
//                     style: const TextStyle(
//                       color: AppColors.lightTextPrimary,
//                       fontSize: 8,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ),
//
//               Positioned(
//                 right: 16,
//                 bottom: 14,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 9,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withValues(alpha: 0.65),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Text(
//                     '${selectedImageIndex + 1} / ${galleryImages.length}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 8,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         const SizedBox(height: 10),
//
//         SizedBox(
//           height: 52,
//           child: ListView.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             scrollDirection: Axis.horizontal,
//             itemCount: galleryImages.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 8),
//             itemBuilder: (_, index) {
//               final selected = selectedImageIndex == index;
//
//               return InkWell(
//                 onTap: () {
//                   setState(() {
//                     selectedImageIndex = index;
//                   });
//                 },
//                 borderRadius: BorderRadius.circular(7),
//                 child: Container(
//                   width: 64,
//                   padding: const EdgeInsets.all(2),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: selected
//                           ? AppColors.lightPrimary
//                           : AppColors.lightBorder,
//                       width: selected ? 1.5 : 1,
//                     ),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(5),
//                     child: Image.network(
//                       galleryImages[index],
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ============================================================
//   // WORKSPACE DETAILS
//   // ============================================================
//
//   Widget _buildWorkspaceDetails() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'WORKSPACE DETAILS',
//           style: TextStyle(
//             color: AppColors.lightPrimary,
//             fontSize: 8,
//             fontWeight: FontWeight.w800,
//             letterSpacing: 0.5,
//           ),
//         ),
//
//         const SizedBox(height: 8),
//
//         Text(
//           space.name.toUpperCase(),
//           style: const TextStyle(
//             color: AppColors.lightTextPrimary,
//             fontSize: 14,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//
//         const SizedBox(height: 10),
//
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(
//             horizontal: 10,
//             vertical: 9,
//           ),
//           decoration: BoxDecoration(
//             color: AppColors.softPurple,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               const Icon(
//                 Icons.location_on_outlined,
//                 color: AppColors.lightPrimary,
//                 size: 14,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   space.location,
//                   style: const TextStyle(
//                     color: AppColors.lightPrimary,
//                     fontSize: 8,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         const SizedBox(height: 12),
//
//         const Text(
//           'A premium corporate workspace designed for productivity, '
//               'collaboration, and growth. Enjoy modern offices, meeting rooms, '
//               'high-speed internet, business-ready amenities, secure access.',
//           style: TextStyle(
//             color: AppColors.lightTextSecondary,
//             fontSize: 9,
//             height: 1.55,
//           ),
//         ),
//
//         const SizedBox(height: 13),
//
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               space.price,
//               style: const TextStyle(
//                 color: AppColors.lightTextPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(width: 4),
//             const Padding(
//               padding: EdgeInsets.only(bottom: 2),
//               child: Text(
//                 '/ HOUR',
//                 style: TextStyle(
//                   color: AppColors.lightTextSecondary,
//                   fontSize: 8,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // ============================================================
//   // OPERATING HOURS
//   // ============================================================
//
//   Widget _buildOperatingHours() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.lightSurface,
//         borderRadius: BorderRadius.circular(11),
//         border: Border.all(
//           color: AppColors.lightBorder,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(
//                 Icons.access_time_rounded,
//                 color: AppColors.lightPrimary,
//                 size: 13,
//               ),
//               SizedBox(width: 6),
//               Text(
//                 'OPERATING HOURS',
//                 style: TextStyle(
//                   color: AppColors.lightTextPrimary,
//                   fontSize: 8,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 9),
//
//           const Row(
//             children: [
//               Text(
//                 '☀ 9:00 AM',
//                 style: TextStyle(
//                   color: AppColors.lightTextPrimary,
//                   fontSize: 9,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               Expanded(
//                 child: Center(
//                   child: Text(
//                     '→',
//                     style: TextStyle(
//                       color: AppColors.lightTextSecondary,
//                       fontSize: 10,
//                     ),
//                   ),
//                 ),
//               ),
//               Text(
//                 '🌙 9:00 PM',
//                 style: TextStyle(
//                   color: AppColors.lightTextPrimary,
//                   fontSize: 9,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ============================================================
//   // AMENITIES
//   // ============================================================
//
//   Widget _buildAmenities() {
//     const amenities = [
//       ('High Speed Wi-Fi', Icons.wifi_rounded),
//       ('Secure Lockers', Icons.lock_outline_rounded),
//       ('Comfort Seating', Icons.chair_outlined),
//       ('Private Washroom', Icons.desktop_windows_outlined),
//       ('Secure Access', Icons.lock_person_outlined),
//       ('Coffee & Tea', Icons.coffee_outlined),
//       ('Air Conditioning', Icons.ac_unit_rounded),
//       ('Smart TV', Icons.tv_outlined),
//       ('Printer Access', Icons.print_outlined),
//     ];
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'AMENITIES',
//           style: TextStyle(
//             color: AppColors.lightTextPrimary,
//             fontSize: 9,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//
//         const SizedBox(height: 9),
//
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: amenities.length,
//           gridDelegate:
//           const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 8,
//             mainAxisSpacing: 8,
//             childAspectRatio: 3.6,
//           ),
//           itemBuilder: (_, index) {
//             final amenity = amenities[index];
//
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 9),
//               decoration: BoxDecoration(
//                 color: AppColors.lightSurface,
//                 borderRadius: BorderRadius.circular(9),
//                 border: Border.all(
//                   color: AppColors.lightBorder,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 26,
//                     height: 26,
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: AppColors.lightBackground,
//                       borderRadius: BorderRadius.circular(7),
//                     ),
//                     child: Icon(
//                       amenity.$2,
//                       color: AppColors.lightTextSecondary,
//                       size: 13,
//                     ),
//                   ),
//                   const SizedBox(width: 7),
//                   Expanded(
//                     child: Text(
//                       amenity.$1,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: AppColors.lightTextPrimary,
//                         fontSize: 7.5,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//   // ============================================================
//   // STATUS
//   // ============================================================
//
//   Widget _buildSpaceStatus() {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         vertical: 10,
//       ),
//       decoration: const BoxDecoration(
//         border: Border(
//           top: BorderSide(
//             color: AppColors.lightBorder,
//           ),
//           bottom: BorderSide(
//             color: AppColors.lightBorder,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           _statusItem(
//             Icons.person_outline_rounded,
//             '${space.seats} seats',
//           ),
//           const SizedBox(width: 14),
//           _statusItem(
//             Icons.shield_outlined,
//             'Secured space',
//           ),
//           const SizedBox(width: 14),
//           _statusItem(
//             Icons.meeting_room_outlined,
//             '0 available',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _statusItem(
//       IconData icon,
//       String label,
//       ) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           color: AppColors.lightPrimary,
//           size: 13,
//         ),
//         const SizedBox(width: 5),
//         Text(
//           label,
//           style: const TextStyle(
//             color: AppColors.lightTextSecondary,
//             fontSize: 8,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ============================================================
//   // ACTIONS
//   // ============================================================
//
//   Widget _buildActions() {
//     return Row(
//       children: [
//         Expanded(
//           child: SizedBox(
//             height: 42,
//             child: ElevatedButton(
//               onPressed: () {
//                 Get.toNamed(
//                   AppRoutes.bookSpace,
//                   arguments: space,
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.dashboardGreen,
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//               ),
//               child: const Text(
//                 'BOOK SPACE',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//           ),
//         ),
//
//         const SizedBox(width: 9),
//
//         Expanded(
//           child: SizedBox(
//             height: 42,
//             child: OutlinedButton(
//               onPressed: () {
//                 Get.toNamed(
//                   AppRoutes.siteVisit,
//                   arguments: space,
//                 );
//               },
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(
//                   color: AppColors.lightBorder,
//                 ),
//                 foregroundColor: AppColors.lightTextPrimary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(9),
//                 ),
//               ),
//               child: const Text(
//                 'SITE VISIT',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ============================================================
//   // BOOKED SLOTS
//   // ============================================================
//
//   Widget _buildBookedSlots() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.lightSurface,
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(
//           color: AppColors.lightBorder,
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 30,
//                 height: 30,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: AppColors.softRed,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.access_time_rounded,
//                   color: AppColors.dashboardRed,
//                   size: 15,
//                 ),
//               ),
//
//               const SizedBox(width: 8),
//
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Already Booked Slots',
//                       style: TextStyle(
//                         color: AppColors.lightTextPrimary,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Text(
//                       'These time slots are unavailable (Today & Future)',
//                       style: TextStyle(
//                         color: AppColors.lightTextSecondary,
//                         fontSize: 7,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 8,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.softRed,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Text(
//                   '${bookedSlots.length} Bookings',
//                   style: const TextStyle(
//                     color: AppColors.dashboardRed,
//                     fontSize: 7,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 10),
//
//           ...bookedSlots.map(
//                 (slot) => Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: _bookedSlotCard(slot),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _bookedSlotCard(_BookedSlot slot) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(
//         10,
//         9,
//         10,
//         9,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.softRed,
//         borderRadius: BorderRadius.circular(9),
//         border: const Border(
//           left: BorderSide(
//             color: AppColors.dashboardRed,
//             width: 3,
//           ),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.calendar_today_outlined,
//                 size: 10,
//                 color: AppColors.lightTextSecondary,
//               ),
//               const SizedBox(width: 5),
//               const Text(
//                 'DATE',
//                 style: TextStyle(
//                   color: AppColors.lightTextPrimary,
//                   fontSize: 7,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 slot.date,
//                 style: const TextStyle(
//                   color: AppColors.lightTextPrimary,
//                   fontSize: 7.5,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 6),
//
//           Row(
//             children: [
//               const Icon(
//                 Icons.access_time_rounded,
//                 size: 10,
//                 color: AppColors.dashboardRed,
//               ),
//               const SizedBox(width: 5),
//               Text(
//                 slot.time,
//                 style: const TextStyle(
//                   color: AppColors.lightTextPrimary,
//                   fontSize: 7.5,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 8),
//
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               const Text(
//                 'BOOKED BY',
//                 style: TextStyle(
//                   color: AppColors.lightTextSecondary,
//                   fontSize: 6,
//                 ),
//               ),
//
//               const Spacer(),
//
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     slot.bookedBy,
//                     style: const TextStyle(
//                       color: AppColors.lightTextPrimary,
//                       fontSize: 7.5,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   Text(
//                     slot.email,
//                     style: const TextStyle(
//                       color: AppColors.dashboardRed,
//                       fontSize: 6.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ============================================================
//   // RELATED
//   // ============================================================
//
//   Widget _buildRelatedChambers() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'RELATED CHAMBERS',
//           style: TextStyle(
//             color: AppColors.lightTextPrimary,
//             fontSize: 12,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//
//         const SizedBox(height: 10),
//
//         SizedBox(
//           height: 180,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             children: [
//               _relatedCard(
//                 image:
//                 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d',
//                 name: 'Z FB BDN X - KYU JBM',
//                 location: 'Did ch kk vnndm',
//                 price: '₹652816',
//               ),
//
//               const SizedBox(width: 10),
//
//               _relatedCard(
//                 image:
//                 'https://images.unsplash.com/photo-1497366811353-6870744d04b2',
//                 name: 'DUE CABIN - TEST',
//                 location: 'Hyderabad',
//                 price: '₹50',
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _relatedCard({
//     required String image,
//     required String name,
//     required String location,
//     required String price,
//   }) {
//     return Container(
//       width: 190,
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         color: AppColors.lightSurface,
//         borderRadius: BorderRadius.circular(11),
//         border: Border.all(
//           color: AppColors.lightBorder,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             children: [
//               Image.network(
//                 image,
//                 width: double.infinity,
//                 height: 105,
//                 fit: BoxFit.cover,
//               ),
//
//               Positioned(
//                 left: 7,
//                 top: 7,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 7,
//                     vertical: 3,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Text(
//                     'Chamber',
//                     style: TextStyle(
//                       color: AppColors.lightTextPrimary,
//                       fontSize: 6,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: AppColors.lightTextPrimary,
//                     fontSize: 8,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//
//                 const SizedBox(height: 3),
//
//                 Text(
//                   location,
//                   style: const TextStyle(
//                     color: AppColors.lightTextSecondary,
//                     fontSize: 6.5,
//                   ),
//                 ),
//
//                 const SizedBox(height: 5),
//
//                 Text.rich(
//                   TextSpan(
//                     children: [
//                       TextSpan(
//                         text: price,
//                         style: const TextStyle(
//                           color: AppColors.lightTextPrimary,
//                           fontSize: 9,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       const TextSpan(
//                         text: ' / hr',
//                         style: TextStyle(
//                           color: AppColors.lightTextSecondary,
//                           fontSize: 6.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _BookedSlot {
//   final String date;
//   final String time;
//   final String bookedBy;
//   final String email;
//
//   const _BookedSlot({
//     required this.date,
//     required this.time,
//     required this.bookedBy,
//     required this.email,
//   });
// }
