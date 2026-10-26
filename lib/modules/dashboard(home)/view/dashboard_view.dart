import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/modules/dashboard(home)/controller/home_controller.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/service/invoice_pdf_service.dart';
import 'package:iryax_spaces/modules/navigation/controller/navigation_controller.dart';
import 'package:iryax_spaces/modules/spaces/controller/spaces_controller.dart';
const int _kRecentBookingsLimit = 3;

// ─────────────────────────────────────────────────────────
// Figma Design Tokens
// ─────────────────────────────────────────────────────────
class _DC {
  // Surfaces
  static const whisper       = Color(0xFFF6F6FA);
  static const white         = Color(0xFFFFFFFF);

  // Text
  static const steelGray     = Color(0xFF26204A);
  static const manatee       = Color(0xFF8A8A99);
  static const frenchGray    = Color(0xFFB4B4C2);

  // Primary accent
  static const royalBlue     = Color(0xFF26204A);
  static const governorBay   = Color(0xFF4338CA);

  // Borders
  static const athensGray    = Color(0xFFE7E7F0);

  // Stat icon backgrounds
  static const selagoPurple  = Color(0xFFEFEEFC);   // Total
  static const eggSour       = Color(0xFFFFF4DA);   // Pending
  static const selago2       = Color(0xFFE6F1FB);   // Confirmed
  static const ottoman       = Color(0xFFEAF9EE);   // Active
  static const selagoViolet  = Color(0xFFF1EAFB);   // Completed
  static const provPink      = Color(0xFFFDECEC);   // Cancelled

  // Stat icon text / icon colours
  static const govBayIcon    = Color(0xFF4338CA);
  static const vesuvius      = Color(0xFFB45309);
  static const funBlue       = Color(0xFF185FA5);
  static const jewel         = Color(0xFF16803C);
  static const purpleHeart   = Color(0xFF6D28D9);
  static const tallPoppy     = Color(0xFFC0392B);

  // Payment chip
  static const oldLace       = Color(0xFFFDF6E3);
  static const kuMera        = Color(0xFF8A6D1F);
}

// ─────────────────────────────────────────────────────────
// Text style helpers
// ─────────────────────────────────────────────────────────
TextStyle _roboto({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
  double? height,
  double letterSpacing = 0,
}) =>
    TextStyle(
      fontFamily: 'Roboto',
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );

TextStyle _inter({
  required double size,
  required Color color,
  FontWeight weight = FontWeight.w400,
  double? height,
}) =>
    TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
    );

// ─────────────────────────────────────────────────────────
// Dashboard View
// ─────────────────────────────────────────────────────────
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  HomeController get _home {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>();
    }
    return Get.put(HomeController(), permanent: true);
  }

  BookingsController get _bookings {
    if (Get.isRegistered<BookingsController>()) {
      return Get.find<BookingsController>();
    }
    return Get.put(BookingsController(), permanent: true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _home.loadDashboard(),
      _bookings.loadBookings(),
    ]);

    if (_home.totalBookings.value == 0 && _bookings.bookings.isNotEmpty) {
      _home.syncWithBookings(_bookings.bookings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _DC.whisper,
      child: RefreshIndicator(
        color: _DC.royalBlue,
        backgroundColor: _DC.white,
        displacement: 40,
        strokeWidth: 2.5,
        onRefresh: _refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildStatsGrid(),
            const SizedBox(height: 14),
            _buildTypeCategories(),
            const SizedBox(height: 12),
            _buildFiltersCard(context),
            const SizedBox(height: 12),
            _buildBookingCount(),
            const SizedBox(height: 12),
            _buildBookingList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  HEADER  — greeting banner
  // ══════════════════════════════════════════════════════
  String _greetingForHour(int hour) {
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildHeader() {
    final name = StorageService.userName.trim();
    final now = DateTime.now();
    final displayName = name.isNotEmpty ? name : 'there';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Same brand colors as before (#26204A family)
          gradient: LinearGradient(
            begin: Alignment(-0.72, -0.7),
            end: Alignment(0.72, 0.7),
            colors: [
              Color(0xFF26204A),
              Color(0xFF3D3568),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Soft top-right glow
            Positioned(
              right: -70,
              top: -90,
              child: IgnorePointer(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4F4780).withValues(alpha: 0.9),
                        const Color(0xFF3D3568).withValues(alpha: 0.35),
                        const Color(0xFF26204A).withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // White 8% circle overlay (banner style)
            Positioned(
              right: -30,
              top: -32,
              child: IgnorePointer(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 26, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greetingForHour(now.hour),
                    style: _roboto(
                      size: 14,
                      color: _DC.white.withValues(alpha: 0.92),
                      weight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$displayName 👋',
                    style: _roboto(
                      size: 24,
                      color: _DC.white,
                      weight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Book premium workspaces, track visits, and manage every booking from one place.',
                    style: _roboto(
                      size: 11,
                      color: _DC.white.withValues(alpha: 0.9),
                      weight: FontWeight.w400,
                      height: 16 / 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  STATS GRID  — 2 rows × 3 columns
  // ══════════════════════════════════════════════════════
  Widget _buildStatsGrid() {
    return Obx(() {
      // ── Show shimmer while loading ──────────────────────
      if (_home.isLoading.value && _home.totalBookings.value == 0) {
        return _buildStatsShimmer();
      }

      if (_home.errorMessage.value != null &&
          _bookings.bookings.isEmpty &&
          !_home.isLoading.value) {
        return _statsError();
      }

      final total = _home.totalBookings.value > 0
          ? _home.totalBookings.value
          : _bookings.bookings.length;
      final pending = _home.totalBookings.value > 0
          ? _home.pendingBookings.value
          : _bookings.bookingCount(BookingStatus.pending);
      final confirmed = _home.totalBookings.value > 0
          ? _home.confirmedBookings.value
          : _bookings.bookingCount(BookingStatus.confirmed);
      final active = _home.totalBookings.value > 0
          ? _home.activeBookings.value
          : _bookings.bookingCount(BookingStatus.active);
      final completed = _home.totalBookings.value > 0
          ? _home.completedBookings.value
          : _bookings.bookingCount(BookingStatus.completed);
      final cancelled = _home.totalBookings.value > 0
          ? _home.cancelledBookings.value
          : _bookings.bookingCount(BookingStatus.cancelled);

      final sel = _bookings.selectedStatus.value;

      Widget row(List<Widget> cards) => Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(child: cards[i]),
              ],
            ],
          );

      return Column(
        children: [
          row([
            _statCard(
              title: 'TOTAL',
              value: '$total',
              subtitle: 'all reservations',
              icon: Icons.inbox_outlined,
              iconColor: _DC.govBayIcon,
              iconBg: _DC.selagoPurple,
              selected: sel == 'All Status',
              highlighted: true,
              onTap: () => _applyFilter('All Status'),
            ),
            _statCard(
              title: 'PENDING',
              value: '$pending',
              subtitle: 'awaiting confirmation',
              icon: Icons.access_time_rounded,
              iconColor: _DC.vesuvius,
              iconBg: _DC.eggSour,
              selected: sel == 'Pending',
              onTap: () => _applyFilter('Pending'),
            ),
            _statCard(
              title: 'CONFIRMED',
              value: '$confirmed',
              subtitle: 'approved reservations',
              icon: Icons.check_circle_outline,
              iconColor: _DC.funBlue,
              iconBg: _DC.selago2,
              selected: sel == 'Confirmed',
              onTap: () => _applyFilter('Confirmed'),
            ),
          ]),
          const SizedBox(height: 6),
          row([
            _statCard(
              title: 'ACTIVE',
              value: '$active',
              subtitle: 'active & confirmed',
              icon: Icons.home_outlined,
              iconColor: _DC.jewel,
              iconBg: _DC.ottoman,
              selected: sel == 'Active',
              onTap: () => _applyFilter('Active'),
            ),
            _statCard(
              title: 'COMPLETED',
              value: '$completed',
              subtitle: 'confirmed & paid',
              icon: Icons.check_circle_outline,
              iconColor: _DC.purpleHeart,
              iconBg: _DC.selagoViolet,
              selected: sel == 'Completed',
              onTap: () => _applyFilter('Completed'),
            ),
            _statCard(
              title: 'CANCELLED',
              value: '$cancelled',
              subtitle: 'cancelled reservations',
              icon: Icons.cancel_outlined,
              iconColor: _DC.tallPoppy,
              iconBg: _DC.provPink,
              selected: sel == 'Cancelled',
              onTap: () => _applyFilter('Cancelled'),
            ),
          ]),
        ],
      );
    });
  }

  Widget _statCard({
    required String     title,
    required String     value,
    required String     subtitle,
    required IconData   icon,
    required Color      iconColor,
    required Color      iconBg,
    required bool       selected,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final borderColor =
        selected ? iconColor : (highlighted ? _DC.royalBlue : _DC.athensGray);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: _DC.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: _roboto(
                      size: 8,
                      color: _DC.manatee,
                      weight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: iconColor, size: 11),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: _roboto(
                size: 14,
                color: _DC.steelGray,
                weight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _roboto(size: 8, color: _DC.manatee, height: 1.15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statsError() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DC.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _DC.athensGray),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: _DC.tallPoppy, size: 28),
          const SizedBox(height: 8),
          Text(
            _home.errorMessage.value ?? 'Unable to load dashboard.',
            textAlign: TextAlign.center,
            style: _roboto(size: 9, color: _DC.manatee),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: _DC.royalBlue,
                foregroundColor: _DC.white,
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsShimmer() => const StatsGridShimmer();

  Widget _buildBookingShimmer() => const BookingListShimmer();

  void _applyFilter(String status) {
    _bookings.clearDashboardFilters();
    if (status != 'All Status') _bookings.changeStatus(status);
  }

  // ══════════════════════════════════════════════════════
  //  TYPE CATEGORIES (circular chips + images)
  // ══════════════════════════════════════════════════════
  static const _typeCategories = <({
    String label,
    String bookingType,
    String spacesCategory,
    IconData icon,
    String? imageUrl,
  })>[
    (
      label: 'All',
      bookingType: 'All Types',
      spacesCategory: 'Co-Working',
      icon: Icons.apps_rounded,
      imageUrl: null,
    ),
    (
      label: 'Coworking',
      bookingType: 'Co-Working Space',
      spacesCategory: 'Co-Working',
      icon: Icons.business_center_outlined,
      imageUrl:
          'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=240&q=80',
    ),
    (
      label: 'Medical',
      bookingType: 'Medical Chamber',
      spacesCategory: 'Medical Chambers',
      icon: Icons.medical_services_outlined,
      imageUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=240&q=80',
    ),
    (
      label: 'Cafe',
      bookingType: 'Cafe & Dining',
      spacesCategory: 'Cafe & Dining',
      icon: Icons.restaurant_menu_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=240&q=80',
    ),
    (
      label: 'Meeting',
      bookingType: 'Meeting Room',
      spacesCategory: 'Meeting Rooms',
      icon: Icons.groups_outlined,
      imageUrl:
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=240&q=80',
    ),
    (
      label: 'Private',
      bookingType: 'Private Office',
      spacesCategory: 'Private Offices',
      icon: Icons.lock_outline_rounded,
      imageUrl:
          'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=240&q=80',
    ),
  ];

  void _openSpacesForCategory(String spacesCategory) {
    if (Get.isRegistered<SpacesController>()) {
      Get.find<SpacesController>().changeCategory(spacesCategory);
    }
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeTab(1);
    }
  }

  void _onTypeCategoryTap(({
    String label,
    String bookingType,
    String spacesCategory,
    IconData icon,
    String? imageUrl,
  }) item) {
    _bookings.changeType(item.bookingType);
    _openSpacesForCategory(item.spacesCategory);
  }

  Widget _buildTypeCategories() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      decoration: BoxDecoration(
        color: _DC.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _DC.athensGray),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0626204A),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _DC.selagoPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.category_outlined,
                    size: 15,
                    color: _DC.royalBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Browse by type',
                    style: _roboto(
                      size: 13.5,
                      color: _DC.steelGray,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openSpacesForCategory(
                    Get.isRegistered<SpacesController>()
                        ? Get.find<SpacesController>().selectedCategory.value
                        : 'Co-Working',
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explore',
                        style: _roboto(
                          size: 11.5,
                          color: _DC.royalBlue,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: _DC.royalBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 2.2,
                  decoration: BoxDecoration(
                    color: _DC.royalBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(height: 1, color: _DC.athensGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final selected = _bookings.selectedType.value;
            return SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(right: 12),
                itemCount: _typeCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  final item = _typeCategories[index];
                  final isSelected = selected == item.bookingType;
                  return GestureDetector(
                    onTap: () => _onTypeCategoryTap(item),
                    child: SizedBox(
                      width: 66,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 58,
                            height: 58,
                            padding: EdgeInsets.all(isSelected ? 2.8 : 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _DC.white,
                              border: Border.all(
                                color: isSelected
                                    ? _DC.royalBlue
                                    : _DC.athensGray,
                                width: isSelected ? 2.4 : 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? _DC.royalBlue.withValues(alpha: 0.18)
                                      : const Color(0x0A26204A),
                                  blurRadius: isSelected ? 10 : 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: item.imageUrl == null
                                  ? ColoredBox(
                                      color: isSelected
                                          ? _DC.selagoPurple
                                          : const Color(0xFFF1F0FD),
                                      child: Icon(
                                        item.icon,
                                        size: 24,
                                        color: _DC.royalBlue,
                                      ),
                                    )
                                  : Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          item.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              ColoredBox(
                                            color: _DC.selagoPurple,
                                            child: Icon(
                                              item.icon,
                                              size: 22,
                                              color: _DC.royalBlue,
                                            ),
                                          ),
                                          loadingBuilder:
                                              (context, child, progress) {
                                            if (progress == null) return child;
                                            return ColoredBox(
                                              color: _DC.selagoPurple,
                                              child: Icon(
                                                item.icon,
                                                size: 18,
                                                color: _DC.royalBlue
                                                    .withValues(alpha: 0.45),
                                              ),
                                            );
                                          },
                                        ),
                                        if (isSelected)
                                          ColoredBox(
                                            color: _DC.royalBlue
                                                .withValues(alpha: 0.12),
                                          ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: _roboto(
                              size: 10.5,
                              color: isSelected
                                  ? _DC.royalBlue
                                  : _DC.steelGray,
                              weight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  FILTERS — search + chip row (modern app style)
  // ══════════════════════════════════════════════════════
  Widget _buildFiltersCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: Obx(() {
            final status = _bookings.selectedStatus.value;
            final payment = _bookings.selectedPaymentStatus.value;
            final date = _bookings.selectedBookingDate.value;
            final hasFilters =
                _bookings.searchQuery.value.isNotEmpty ||
                status != 'All Status' ||
                payment != 'Payment Status' ||
                date != null ||
                _bookings.selectedType.value != 'All Types';

            final dateLabel = date == null
                ? 'Date'
                : '${date.day.toString().padLeft(2, '0')}/'
                    '${date.month.toString().padLeft(2, '0')}';

            return ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _filterChip(
                  label: dateLabel,
                  icon: Icons.calendar_today_outlined,
                  selected: date != null,
                  onTap: () => _pickBookingDate(context),
                  onClear: date != null
                      ? () => _bookings.changeBookingDate(null)
                      : null,
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: status == 'All Status' ? 'Status' : status,
                  icon: Icons.flag_outlined,
                  selected: status != 'All Status',
                  onTap: () => _showStatusSheet(context),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  label: payment == 'Payment Status' ? 'Payment' : payment,
                  icon: Icons.payments_outlined,
                  selected: payment != 'Payment Status',
                  onTap: () => _showPaymentSheet(context),
                ),
                if (hasFilters) ...[
                  const SizedBox(width: 8),
                  _filterChip(
                    label: 'Clear',
                    icon: Icons.close_rounded,
                    selected: false,
                    accent: true,
                    onTap: _bookings.clearDashboardFilters,
                  ),
                ],
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    VoidCallback? onClear,
    bool accent = false,
  }) {
    final bg = accent
        ? _DC.selagoPurple
        : selected
            ? _DC.royalBlue
            : _DC.white;
    final fg = accent
        ? _DC.royalBlue
        : selected
            ? _DC.white
            : _DC.steelGray;
    final border = accent
        ? _DC.royalBlue.withValues(alpha: 0.2)
        : selected
            ? _DC.royalBlue
            : _DC.athensGray;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: _roboto(
                  size: 12,
                  color: fg,
                  weight: FontWeight.w600,
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 14, color: fg),
                ),
              ] else if (!accent && !selected) ...[
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBookingDate(BuildContext context) async {
    final selected = _bookings.selectedBookingDate.value;
    final picked = await showDatePicker(
      context: context,
      initialDate: selected ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) _bookings.changeBookingDate(picked);
  }

  void _showStatusSheet(BuildContext context) {
    const items = [
      'All Status',
      'Pending',
      'Confirmed',
      'Active',
      'Completed',
      'Cancelled',
    ];
    _showFilterSheet(
      context: context,
      title: 'Status',
      items: items,
      selected: _bookings.selectedStatus.value,
      onSelect: _bookings.changeStatus,
    );
  }

  void _showPaymentSheet(BuildContext context) {
    const items = [
      'Payment Status',
      'Pending',
      'Paid',
      'Failed',
      'Refunded',
    ];
    _showFilterSheet(
      context: context,
      title: 'Payment Status',
      items: items,
      selected: _bookings.selectedPaymentStatus.value,
      onSelect: _bookings.changePaymentStatus,
      labelOf: (v) => v == 'Payment Status' ? 'All' : v,
    );
  }

  void _showFilterSheet({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelect,
    String Function(String)? labelOf,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _DC.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _DC.athensGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: _roboto(
                    size: 16,
                    color: _DC.steelGray,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...items.map((item) {
                  final isSelected = item == selected;
                  final label = labelOf?.call(item) ?? item;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      label,
                      style: _roboto(
                        size: 14,
                        color: isSelected ? _DC.royalBlue : _DC.steelGray,
                        weight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: _DC.royalBlue,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      onSelect(item);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 42,
      child: TextField(
        autofocus: false,
        controller: _bookings.searchController,
        onChanged: _bookings.updateSearch,
        style: _inter(size: 13, color: _DC.steelGray),
        decoration: InputDecoration(
          hintText: 'Search bookings...',
          hintStyle: _inter(size: 13, color: _DC.frenchGray),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18,
            color: _DC.manatee,
          ),
          filled: true,
          fillColor: _DC.white,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _DC.athensGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _DC.royalBlue),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  BOOKING COUNT  &  CLEAR FILTERS
  // ══════════════════════════════════════════════════════
  Widget _buildBookingCount() {
    return Obx(() {
      final shown = _bookings.filteredBookings.length;
      final total = _bookings.bookings.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _DC.selagoPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: _DC.royalBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Bookings',
                style: _roboto(
                  size: 14.5,
                  color: _DC.steelGray,
                  weight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              if (shown > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    'Showing $shown of $total bookings',
                    style: _roboto(
                      size: 11,
                      color: _DC.royalBlue,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 28,
                height: 2.5,
                decoration: BoxDecoration(
                  color: _DC.royalBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(height: 1, color: _DC.athensGray),
              ),
            ],
          ),
        ],
      );
    });
  }

  // ══════════════════════════════════════════════════════
  //  BOOKING LIST
  // ══════════════════════════════════════════════════════
  Widget _buildBookingList() {
    return Obx(() {
      if (_bookings.isLoadingBookings.value && _bookings.bookings.isEmpty) {
        return _buildBookingShimmer();
      }

      if (_bookings.bookingError.value != null &&
          _bookings.bookings.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                _bookings.bookingError.value ?? 'Unable to load bookings.',
                style: _roboto(size: 12, color: _DC.manatee),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _DC.royalBlue,
                  foregroundColor: _DC.white,
                ),
                child: const Text('Retry', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        );
      }

      final list = _bookings.filteredBookings;

      if (list.isEmpty) {
        return _buildEmptyState();
      }

      final visible = list.length > _kRecentBookingsLimit
          ? list.take(_kRecentBookingsLimit).toList()
          : list;
      final hasMore = list.length > _kRecentBookingsLimit;

      return Column(
        children: [
          ...visible.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _bookingCard(b),
            ),
          ),
          if (hasMore)
            GestureDetector(
              onTap: _openMyBookings,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _DC.selagoPurple,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _DC.royalBlue.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View all ${list.length} bookings',
                      style: _roboto(
                        size: 12.5,
                        color: _DC.royalBlue,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: _DC.royalBlue,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  void _openMyBookings() {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeTab(2);
    }
  }

  Widget _buildEmptyState() {
    final hasSearch = _bookings.searchQuery.value.trim().isNotEmpty;
    final hasFilters = hasSearch ||
        _bookings.selectedStatus.value != 'All Status' ||
        _bookings.selectedBookingStat.value != 'All' ||
        _bookings.selectedType.value != 'All Types' ||
        _bookings.selectedPaymentStatus.value != 'Payment Status' ||
        _bookings.selectedBookingDate.value != null;

    final String badgeText;
    final String title;
    final String subtitle;
    final IconData icon;

    if (hasSearch) {
      badgeText = 'SEARCH FILTER ACTIVE';
      title = 'No Matching Results';
      subtitle = 'We couldn\'t find any reservations matching "${_bookings.searchQuery.value.trim()}". Check for typos or clear your search.';
      icon = Icons.search_off_rounded;
    } else if (hasFilters) {
      badgeText = 'FILTERS APPLIED';
      title = 'No Bookings Match Filters';
      subtitle = 'No reservations match your selected criteria. Try adjusting status, space type, or date range.';
      icon = Icons.filter_alt_outlined;
    } else {
      badgeText = 'NO RESERVATIONS';
      title = 'No Bookings Found';
      subtitle = 'You do not have any active or previous bookings listed under your account at this moment.';
      icon = Icons.inbox_outlined;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
      decoration: BoxDecoration(
        color: _DC.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _DC.athensGray, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0626204A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant layered concentric illustration badge
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer halo ring
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DC.selagoPurple.withValues(alpha: 0.45),
                ),
              ),
              // Middle ring
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DC.selagoPurple,
                  border: Border.all(
                    color: _DC.royalBlue.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                ),
              ),
              // Inner core circle with icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _DC.white,
                  boxShadow: [
                    BoxShadow(
                      color: _DC.royalBlue.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: _DC.royalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Micro badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
            decoration: BoxDecoration(
              color: _DC.selagoPurple,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _DC.royalBlue.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              badgeText,
              style: _roboto(
                size: 9.5,
                color: _DC.governorBay,
                weight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: _roboto(
              size: 17,
              color: _DC.steelGray,
              weight: FontWeight.w700,
              height: 22 / 17,
            ),
          ),
          const SizedBox(height: 7),

          // Subtitle
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 285),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: _inter(
                size: 12.5,
                color: _DC.manatee,
                height: 1.5,
              ),
            ),
          ),

          // Clean minimalist reset pill (only when filtered, no explore / refresh buttons!)
          if (hasFilters) ...[
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _bookings.clearDashboardFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _DC.selagoPurple,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _DC.royalBlue.withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 13,
                      color: _DC.royalBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Reset Filters',
                      style: _roboto(
                        size: 11.5,
                        color: _DC.royalBlue,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  BOOKING CARD (EXACT STYLE MATCHING REFERENCE IMAGE)
  // ══════════════════════════════════════════════════════
  Widget _bookingCard(BookingModel booking) {
    final timeStr = () {
      if (booking.startTime.isNotEmpty && booking.endTime.isNotEmpty) {
        final dur = booking.duration.isNotEmpty ? ' (${booking.duration})' : '';
        return '(${booking.startTime} - ${booking.endTime}$dur)';
      } else if (booking.startTime.isNotEmpty) {
        final dur = booking.duration.isNotEmpty ? ' (${booking.duration})' : '';
        return '(${booking.startTime}$dur)';
      }
      return '(time TBD)';
    }();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _DC.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DC.athensGray, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Space name ──
          Text(
            booking.spaceName,
            style: _roboto(
              size: 15.5,
              color: _DC.steelGray,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

          // ── Location & Owner ──
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: _DC.manatee,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _roboto(size: 11.5, color: _DC.manatee),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: _DC.manatee,
                  ),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 140),
                    child: Text(
                      'Owner: ${booking.customerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _roboto(size: 11.5, color: _DC.manatee),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, thickness: 1, color: _DC.athensGray),
          const SizedBox(height: 10),

          // ── Date & Time ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Date & time',
                style: _roboto(
                  size: 11.5,
                  color: _DC.manatee,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${booking.startDate} $timeStr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: _roboto(
                    size: 11,
                    color: _DC.steelGray,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Status',
                style: _roboto(
                  size: 11.5,
                  color: _DC.manatee,
                  weight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _statusChip(booking),
              const SizedBox(width: 6),
              _paymentChip(booking),
            ],
          ),

          const SizedBox(height: 10),

          // ── Amount ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Amount',
                style: _roboto(
                  size: 11.5,
                  color: _DC.manatee,
                  weight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                booking.amount,
                style: _roboto(
                  size: 13.5,
                  color: _DC.governorBay,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── View | Invoice buttons ──
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  icon: Icons.visibility_outlined,
                  label: 'View',
                  color: _DC.governorBay,
                  onTap: () => _bookings.openBookingDetails(booking),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionBtn(
                  icon: Icons.download_outlined,
                  label: 'Invoice',
                  color: _DC.jewel,
                  onTap: () => InvoicePdfService.previewInvoice(booking),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: _DC.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _DC.athensGray, width: 1.1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: _inter(
                size: 12,
                color: color,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status chip ──
  Widget _statusChip(BookingModel booking) {
    Color bg, text;
    String label;

    switch (booking.status) {
      case BookingStatus.pending:
        bg = _DC.eggSour;
        text = _DC.vesuvius;
        label = 'Pending';
        break;
      case BookingStatus.confirmed:
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF047857);
        label = 'Confirmed';
        break;
      case BookingStatus.active:
        bg = _DC.ottoman;
        text = _DC.jewel;
        label = 'Active';
        break;
      case BookingStatus.completed:
        bg = _DC.selagoViolet;
        text = _DC.purpleHeart;
        label = 'Completed';
        break;
      case BookingStatus.cancelled:
        bg = _DC.provPink;
        text = _DC.tallPoppy;
        label = 'Cancelled';
        break;
    }

    return _chip(label: label, bg: bg, textColor: text);
  }

  // ── Payment chip ──
  Widget _paymentChip(BookingModel booking) {
    late final Color bg;
    late final Color text;
    late final String label;

    switch (booking.paymentStatus) {
      case PaymentStatus.paid:
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF047857);
        label = 'Paid';
        break;
      case PaymentStatus.failed:
        bg = _DC.provPink;
        text = _DC.tallPoppy;
        label = 'Failed';
        break;
      case PaymentStatus.refunded:
        bg = _DC.selago2;
        text = _DC.funBlue;
        label = 'Refunded';
        break;
      case PaymentStatus.pending:
        bg = const Color(0xFFFEF9C3);
        text = const Color(0xFF854D0E);
        label = 'Pending';
        break;
    }

    return _chip(label: label, bg: bg, textColor: text);
  }

  Widget _chip({
    required String label,
    required Color bg,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: _roboto(
          size: 10.5,
          color: textColor,
          weight: FontWeight.w700,
        ),
      ),
    );
  }

}