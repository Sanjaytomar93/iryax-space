import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/core/services/storage_service.dart';
import 'package:iryax_spaces/modules/dashboard(home)/controller/home_controller.dart';
import 'package:iryax_spaces/modules/bookings/controller/bookings_controller.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/service/invoice_pdf_service.dart';

// ─────────────────────────────────────────────────────────
// Figma Design Tokens
// ─────────────────────────────────────────────────────────
class _DC {
  // Surfaces
  static const whisper       = Color(0xFFF6F6FA);
  static const white         = Color(0xFFFFFFFF);

  // Text
  static const steelGray     = Color(0xFF1E1B2E);
  static const manatee       = Color(0xFF8A8A99);
  static const frenchGray    = Color(0xFFB4B4C2);

  // Primary accent
  static const royalBlue     = Color(0xFF5B4FE9);
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
// Shimmer Effect Widget (pure Flutter, no extra package)
// ─────────────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 10,
  });
  final double width;
  final double height;
  final double borderRadius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = (_ctrl.value * 3) - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFF4F4FB),
                Color(0xFFEBEBF4),
              ],
              stops: [
                math.max(0.0, t - 0.3),
                math.max(0.0, math.min(1.0, t)),
                math.min(1.0, t + 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 8),
            _buildDateFilter(context),
            const SizedBox(height: 8),
            _buildStatusAndTypeRow(),
            const SizedBox(height: 8),
            _buildPaymentDropdown(),
            const SizedBox(height: 6),
            _buildBookingCount(),
            _buildClearFilters(),
            const SizedBox(height: 12),
            _buildBookingList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  HEADER  — "My Dashboard / Welcome back, kumar"
  // ══════════════════════════════════════════════════════
  Widget _buildHeader() {
    final name = StorageService.userName.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'My ',
                style: _roboto(
                  size: 22,
                  color: _DC.steelGray,
                  weight: FontWeight.w700,
                  height: 26 / 22,
                ),
              ),
              TextSpan(
                text: 'Dashboard',
                style: _roboto(
                  size: 22,
                  color: _DC.royalBlue,
                  weight: FontWeight.w700,
                  height: 26 / 22,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          name.isNotEmpty ? 'Welcome back, $name' : 'Welcome back',
          style: _roboto(size: 13, color: _DC.manatee, height: 15 / 13),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  //  STATS GRID  — 3 rows × 2 columns
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

      return Column(
        children: [
          // Row 1 — Total | Pending
          Row(children: [
            Expanded(
              child: _statCard(
                title:     'TOTAL',
                value:     '$total',
                subtitle:  'all reservations',
                icon:      Icons.inbox_outlined,
                iconColor: _DC.govBayIcon,
                iconBg:    _DC.selagoPurple,
                selected:  sel == 'All Status',
                highlighted: true,
                onTap:     () => _applyFilter('All Status'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _statCard(
                title:     'PENDING',
                value:     '$pending',
                subtitle:  'awaiting confirmation',
                icon:      Icons.access_time_rounded,
                iconColor: _DC.vesuvius,
                iconBg:    _DC.eggSour,
                selected:  sel == 'Pending',
                onTap:     () => _applyFilter('Pending'),
              ),
            ),
          ]),
          const SizedBox(height: 9),
          // Row 2 — Confirmed | Active
          Row(children: [
            Expanded(
              child: _statCard(
                title:     'CONFIRMED',
                value:     '$confirmed',
                subtitle:  'approved reservations',
                icon:      Icons.check_circle_outline,
                iconColor: _DC.funBlue,
                iconBg:    _DC.selago2,
                selected:  sel == 'Confirmed',
                onTap:     () => _applyFilter('Confirmed'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _statCard(
                title:     'ACTIVE',
                value:     '$active',
                subtitle:  'active & confirmed',
                icon:      Icons.home_outlined,
                iconColor: _DC.jewel,
                iconBg:    _DC.ottoman,
                selected:  sel == 'Active',
                onTap:     () => _applyFilter('Active'),
              ),
            ),
          ]),
          const SizedBox(height: 9),
          // Row 3 — Completed | Cancelled
          Row(children: [
            Expanded(
              child: _statCard(
                title:     'COMPLETED',
                value:     '$completed',
                subtitle:  'confirmed & paid',
                icon:      Icons.check_circle_outline,
                iconColor: _DC.purpleHeart,
                iconBg:    _DC.selagoViolet,
                selected:  sel == 'Completed',
                onTap:     () => _applyFilter('Completed'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _statCard(
                title:     'CANCELLED',
                value:     '$cancelled',
                subtitle:  'cancelled reservations',
                icon:      Icons.cancel_outlined,
                iconColor: _DC.tallPoppy,
                iconBg:    _DC.provPink,
                selected:  sel == 'Cancelled',
                onTap:     () => _applyFilter('Cancelled'),
              ),
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
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: _DC.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: _roboto(
                      size: 10,
                      color: _DC.manatee,
                      weight: FontWeight.w700,
                      height: 12 / 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Value
            Text(
              value,
              style: _roboto(
                size: 20,
                color: _DC.steelGray,
                weight: FontWeight.w700,
                height: 24 / 20,
              ),
            ),
            const SizedBox(height: 2),
            // Subtitle
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _roboto(size: 10, color: _DC.manatee, height: 12 / 10),
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

  // ── Shimmer placeholder for 3×2 stat grid ─────────────
  Widget _buildStatsShimmer() {
    Widget shimmerCard() => LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: _DC.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _DC.athensGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _ShimmerBox(width: w * 0.45, height: 10),
                      const Spacer(),
                      const _ShimmerBox(width: 26, height: 26, borderRadius: 8),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _ShimmerBox(width: w * 0.3, height: 20),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: w * 0.65, height: 10),
                ],
              ),
            );
          },
        );

    Widget shimmerRow() => Row(children: [
          Expanded(child: shimmerCard()),
          const SizedBox(width: 9),
          Expanded(child: shimmerCard()),
        ]);

    return Column(
      children: [
        shimmerRow(),
        const SizedBox(height: 9),
        shimmerRow(),
        const SizedBox(height: 9),
        shimmerRow(),
      ],
    );
  }

  // ── Shimmer placeholder for booking card list ──────────
  Widget _buildBookingShimmer() {
    Widget shimmerBookingCard() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _DC.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _DC.athensGray, width: 1.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ShimmerBox(width: 200, height: 16),
              const SizedBox(height: 10),
              const _ShimmerBox(width: 260, height: 12),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: _DC.athensGray),
              const SizedBox(height: 12),
              Row(children: const [
                _ShimmerBox(width: 80, height: 12),
                Spacer(),
                _ShimmerBox(width: 100, height: 12),
              ]),
              const SizedBox(height: 10),
              Row(children: const [
                _ShimmerBox(width: 60, height: 12),
                Spacer(),
                _ShimmerBox(width: 70, height: 22, borderRadius: 7),
                SizedBox(width: 6),
                _ShimmerBox(width: 50, height: 22, borderRadius: 7),
              ]),
              const SizedBox(height: 10),
              Row(children: const [
                _ShimmerBox(width: 60, height: 12),
                Spacer(),
                _ShimmerBox(width: 80, height: 14),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFEBEBF4),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFEBEBF4),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        );

    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: shimmerBookingCard(),
        ),
      ),
    );
  }

  void _applyFilter(String status) {
    _bookings.clearDashboardFilters();
    if (status != 'All Status') _bookings.changeStatus(status);
  }

  // ══════════════════════════════════════════════════════
  //  SEARCH BAR
  // ══════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return SizedBox(
      height: 39,
      child: TextField(
        controller: _bookings.searchController,
        onChanged: _bookings.updateSearch,
        style: _inter(size: 12.3, color: _DC.steelGray),
        decoration: InputDecoration(
          hintText: 'Search bookings...',
          hintStyle: _inter(size: 12.3, color: _DC.frenchGray),
          prefixIcon:
              const Icon(Icons.search_rounded, size: 15, color: _DC.frenchGray),
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
  //  DATE FILTER
  // ══════════════════════════════════════════════════════
  Widget _buildDateFilter(BuildContext context) {
    return Obx(() {
      final selected = _bookings.selectedBookingDate.value;
      final text = selected == null
          ? 'mm/dd/yyyy'
          : '${selected.month.toString().padLeft(2, '0')}/'
              '${selected.day.toString().padLeft(2, '0')}/'
              '${selected.year}';

      return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selected ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
          );
          if (picked != null) _bookings.changeBookingDate(picked);
        },
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _DC.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _DC.athensGray),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: _roboto(
                    size: 12,
                    color: _DC.steelGray,
                    height: 14 / 12,
                  ),
                ),
              ),
              if (selected != null)
                GestureDetector(
                  onTap: () => _bookings.changeBookingDate(null),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.close, size: 14, color: _DC.manatee),
                  ),
                ),
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: _DC.manatee),
            ],
          ),
        ),
      );
    });
  }

  // ══════════════════════════════════════════════════════
  //  STATUS + TYPE ROW
  // ══════════════════════════════════════════════════════
  Widget _buildStatusAndTypeRow() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _dropdown(
                value: _bookings.selectedStatus.value,
                items: const [
                  'All Status',
                  'Pending',
                  'Confirmed',
                  'Active',
                  'Completed',
                  'Cancelled',
                ],
                onChanged: (v) {
                  if (v != null) _bookings.changeStatus(v);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _dropdown(
                value: _bookings.selectedType.value,
                items: const [
                  'All Types',
                  'Co-Working Space',
                  'Medical Chamber',
                ],
                onChanged: (v) {
                  if (v != null) _bookings.changeType(v);
                },
              ),
            ),
          ],
        ));
  }

  // ══════════════════════════════════════════════════════
  //  PAYMENT STATUS DROPDOWN
  // ══════════════════════════════════════════════════════
  Widget _buildPaymentDropdown() {
    return Obx(() => _dropdown(
          value: _bookings.selectedPaymentStatus.value,
          items: const ['Payment Status', 'Paid', 'Pending'],
          onChanged: (v) {
            if (v != null) _bookings.changePaymentStatus(v);
          },
        ));
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: _DC.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _DC.athensGray),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 16, color: _DC.manatee),
          style: _roboto(
            size: 11.8,
            color: _DC.steelGray,
            height: 14 / 11.8,
          ),
          dropdownColor: _DC.white,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  BOOKING COUNT  &  CLEAR FILTERS
  // ══════════════════════════════════════════════════════
  Widget _buildBookingCount() {
    return Obx(() => Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Showing ${_bookings.filteredBookings.length}'
            ' of ${_bookings.bookings.length} bookings',
            style: _roboto(size: 11.8, color: _DC.manatee),
          ),
        ));
  }

  Widget _buildClearFilters() {
    return Obx(() {
      final hasFilters =
          _bookings.searchQuery.value.isNotEmpty ||
          _bookings.selectedStatus.value != 'All Status' ||
          _bookings.selectedType.value != 'All Types' ||
          _bookings.selectedPaymentStatus.value != 'Payment Status' ||
          _bookings.selectedBookingDate.value != null;

      if (!hasFilters) return const SizedBox.shrink();

      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: _bookings.clearDashboardFilters,
          icon: const Icon(Icons.refresh_rounded, size: 14),
          label: Text('Clear filters', style: _roboto(size: 11, color: _DC.royalBlue)),
        ),
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

      return Column(
        children: list
            .map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _bookingCard(b),
                ))
            .toList(),
      );
    });
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
            color: Color(0x061E1B2E),
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
                  Text(
                    'Owner: ${booking.customerName}',
                    style: _roboto(size: 11.5, color: _DC.manatee),
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
              const Spacer(),
              Text(
                booking.startDate,
                style: _roboto(
                  size: 11,
                  color: _DC.steelGray,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: _roboto(
                  size: 9.5,
                  color: _DC.manatee,
                  weight: FontWeight.w400,
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
        bg = _DC.selago2;
        text = _DC.funBlue;
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
    final isPaid = booking.paymentStatus == PaymentStatus.paid;
    return _chip(
      label: isPaid ? 'Paid' : 'pending',
      bg: isPaid ? _DC.ottoman : _DC.oldLace,
      textColor: isPaid ? _DC.jewel : _DC.kuMera,
    );
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
        borderRadius: BorderRadius.circular(7.5),
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