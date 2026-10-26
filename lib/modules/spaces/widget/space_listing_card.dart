import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/app/routes/app_routes.dart';
import 'package:iryax_spaces/app/themes/app_colors.dart';
import 'package:iryax_spaces/core/widgets/app_shimmer.dart';
import 'package:iryax_spaces/modules/spaces/model/space_model.dart';
import 'package:iryax_spaces/modules/wishlist/controller/wishlist_controller.dart';

class SpaceListingCard extends StatefulWidget {
  const SpaceListingCard({
    super.key,
    required this.space,
    this.topRightAction,
    this.showFavoriteButton = false,
    this.showSavedBadge = false,
    this.onDoubleTapLike,
  });

  final SpaceModel space;
  final Widget? topRightAction;
  final bool showFavoriteButton;
  final bool showSavedBadge;
  final VoidCallback? onDoubleTapLike;

  @override
  State<SpaceListingCard> createState() => _SpaceListingCardState();
}

class _SpaceListingCardState extends State<SpaceListingCard>
    with SingleTickerProviderStateMixin {
  bool _amenitiesExpanded = false;
  bool _showLikeBurst = false;
  late final AnimationController _likeCtrl;
  late final Animation<double> _likeScale;
  late final Animation<double> _likeOpacity;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 35,
      ),
    ]).animate(_likeCtrl);
    _likeOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 35),
    ]).animate(_likeCtrl);
    _likeCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showLikeBurst = false);
      }
    });
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SpaceListingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.space.id != widget.space.id) {
      _amenitiesExpanded = false;
    }
  }

  void _openDetails() {
    Get.toNamed(
      AppRoutes.spaceDetails,
      arguments: widget.space,
    );
  }

  void _onDoubleTapLike() {
    widget.onDoubleTapLike?.call();
    setState(() => _showLikeBurst = true);
    _likeCtrl
      ..reset()
      ..forward();
  }

  Widget _favoriteCircle() {
    return Obx(() {
      final c = Get.find<WishlistController>();
      // Force GetX dependency tracking.
      final fav = c.items.any((e) => e.id == widget.space.id);
      final updating = c.updatingIds.contains(widget.space.id);
      return Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: updating ? null : () => c.toggleFavorite(widget.space),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: Icon(
                fav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 14,
                color: fav
                    ? const Color(0xFFE4415B)
                    : const Color(0xFFB4B4C2),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final timing = _formatTiming(space);
    final location = space.location.trim();
    final amenities = _amenityIcons(space.amenities);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightBorderStrong,
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openDetails,
            onDoubleTap: _onDoubleTapLike,
            child: SizedBox(
              height: 195,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: ClipRect(child: _coverImage(space.imageUrl)),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x55000000),
                          Color(0x14000000),
                          Color(0x99000000),
                          Color(0xE6000000),
                        ],
                        stops: [0.0, 0.28, 0.58, 1.0],
                      ),
                    ),
                  ),
                  if (_showLikeBurst)
                    Center(
                      child: FadeTransition(
                        opacity: _likeOpacity,
                        child: ScaleTransition(
                          scale: _likeScale,
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFFE4415B),
                            size: 64,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _categoryBadge(space.category),
                            const Spacer(),
                            widget.showFavoriteButton
                                ? _favoriteCircle()
                                : (widget.topRightAction ??
                                    const SizedBox.shrink()),
                          ],
                        ),
                      const Spacer(),
                      if (widget.showSavedBadge) ...[
                        _savedBadge(),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        space.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        _infoRow(Icons.location_on_outlined, location),
                      ],
                      if (timing.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        _infoRow(Icons.access_time_rounded, timing),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _glassChip(
                            icon: Icons.person_outline,
                            label: '${space.seatCount} seats',
                          ),
                          const SizedBox(width: 6),
                          _ratingChip(space, onImage: true),
                          const Spacer(),
                          _priceBadge(space.formattedPrice),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 9),
            child: Column(
              children: [
                const Divider(height: 1, color: AppColors.lightBorder),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (amenities.isNotEmpty)
                      Expanded(child: _amenitiesSection(amenities))
                    else
                      const Spacer(),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 28,
                      child: ElevatedButton.icon(
                        onPressed: _openDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 11,
                        ),
                        label: const Text(
                          'View',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
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
    );
  }

  Widget _coverImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: AppColors.softPurple,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.lightPrimary,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      memCacheWidth: 800,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => const AppShimmerBox(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 0,
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.softPurple,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.lightPrimary,
        ),
      ),
    );
  }

  Widget _categoryBadge(String category) {
    final isMedical = category == 'Medical Chamber';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMedical ? AppColors.softPurple : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        category,
        style: TextStyle(
          color: isMedical
              ? AppColors.lightPrimary
              : AppColors.lightTextPrimary,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _savedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.softRed,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.dashboardRed.withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: AppColors.dashboardRed, size: 10),
          SizedBox(width: 4),
          Text(
            'Saved',
            style: TextStyle(
              color: AppColors.dashboardRed,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBadge(String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$price/hour',
        style: const TextStyle(
          color: AppColors.lightPrimary,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _ratingChip(SpaceModel space, {bool onImage = false}) {
    final rating = space.rating > 0 ? space.rating : 4.8;
    final reviews = space.reviews > 0 ? space.reviews : 24;
    final ratingText = rating == rating.roundToDouble()
        ? rating.toStringAsFixed(0)
        : rating.toStringAsFixed(1);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          color: onImage ? Colors.amberAccent : AppColors.dashboardOrange,
          size: 11,
        ),
        const SizedBox(width: 2),
        Text(
          ratingText,
          style: TextStyle(
            color: onImage ? Colors.white : AppColors.lightTextPrimary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '($reviews)',
          style: TextStyle(
            color: onImage
                ? Colors.white.withValues(alpha: 0.85)
                : AppColors.lightTextSecondary,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (onImage) {
      return _glassBox(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: content,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.dashboardOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: content,
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.92)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassChip({required IconData icon, required String label}) {
    return _glassBox(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amenitiesSection(List<IconData> icons) {
    final hasMore = icons.length > 3;
    final shown =
        (_amenitiesExpanded || !hasMore) ? icons : icons.take(3).toList();
    final extra = icons.length - 3;

    return Row(
      children: [
        const Text(
          'Amenities',
          style: TextStyle(
            color: AppColors.lightPrimary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < shown.length; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  _facilityIcon(shown[i]),
                ],
                if (hasMore) ...[
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => setState(
                      () => _amenitiesExpanded = !_amenitiesExpanded,
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softPurple,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.lightPrimary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        _amenitiesExpanded ? 'Less' : '+$extra',
                        style: const TextStyle(
                          color: AppColors.lightPrimary,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _facilityIcon(IconData icon) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.lightPrimary.withValues(alpha: 0.18),
        ),
      ),
      child: Icon(icon, size: 11, color: AppColors.lightPrimary),
    );
  }

  Widget _glassBox({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
        ),
      ),
      child: child,
    );
  }

  List<IconData> _amenityIcons(AmenitiesModel a) {
    final list = <IconData>[];
    if (a.wifi) list.add(Icons.wifi_rounded);
    if (a.lockers || a.secureAccess) list.add(Icons.lock_outline);
    if (a.tv) list.add(Icons.desktop_windows_outlined);
    if (a.parking) list.add(Icons.local_parking_rounded);
    if (a.ac) list.add(Icons.ac_unit_rounded);
    if (a.coffee) list.add(Icons.coffee_rounded);
    if (a.printer) list.add(Icons.print_outlined);
    if (a.comfortSeating) list.add(Icons.chair_alt_outlined);
    if (a.privateWashroom) list.add(Icons.wc_outlined);
    if (a.gym) list.add(Icons.fitness_center_rounded);
    if (a.phone) list.add(Icons.phone_outlined);
    return list;
  }

  String _formatTiming(SpaceModel space) {
    if (space.is24x7) return '24/7';
    final open = _formatClock(space.openTime);
    final close = _formatClock(space.closeTime);
    if (open.isEmpty && close.isEmpty) return '';
    if (open.isEmpty) return close;
    if (close.isEmpty) return open;
    return '$open - $close';
  }

  String _formatClock(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return '';
    if (raw.contains(RegExp(r'[AaPp][Mm]'))) return raw;
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = int.tryParse(parts[0]);
    final minute =
        int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
    if (hour == null || minute == null) return raw;
    final period = hour >= 12 ? 'PM' : 'AM';
    var h = hour % 12;
    if (h == 0) h = 12;
    return '$h:${minute.toString().padLeft(2, '0')} $period';
  }
}
