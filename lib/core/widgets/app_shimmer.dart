import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:iryax_spaces/app/themes/app_colors.dart';

/// Pure-Flutter shimmer box (no extra package). Matches dashboard style.
class AppShimmerBox extends StatefulWidget {
  const AppShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 10,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<AppShimmerBox> createState() => _AppShimmerBoxState();
}

class _AppShimmerBoxState extends State<AppShimmerBox>
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

/// Space listing cards shimmer (Spaces / Wishlist).
class SpaceListShimmer extends StatelessWidget {
  const SpaceListShimmer({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i == itemCount - 1 ? 0 : 12),
          child: const _SpaceCardShimmer(),
        ),
      ),
    );
  }
}

class _SpaceCardShimmer extends StatelessWidget {
  const _SpaceCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorderStrong, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmerBox(height: 195, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppShimmerBox(width: 180, height: 14),
                const SizedBox(height: 8),
                const AppShimmerBox(width: 140, height: 11),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    AppShimmerBox(width: 56, height: 20, borderRadius: 6),
                    SizedBox(width: 6),
                    AppShimmerBox(width: 56, height: 20, borderRadius: 6),
                    SizedBox(width: 6),
                    AppShimmerBox(width: 56, height: 20, borderRadius: 6),
                  ],
                ),
                const SizedBox(height: 12),
                const AppShimmerBox(width: double.infinity, height: 36, borderRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Booking / site-visit card list shimmer.
class BookingListShimmer extends StatelessWidget {
  const BookingListShimmer({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i == itemCount - 1 ? 0 : 12),
          child: const _BookingCardShimmer(),
        ),
      ),
    );
  }
}

class _BookingCardShimmer extends StatelessWidget {
  const _BookingCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmerBox(width: 200, height: 16),
          const SizedBox(height: 10),
          const AppShimmerBox(width: 260, height: 12),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.lightBorder),
          const SizedBox(height: 12),
          Row(children: const [
            AppShimmerBox(width: 80, height: 12),
            Spacer(),
            AppShimmerBox(width: 100, height: 12),
          ]),
          const SizedBox(height: 10),
          Row(children: const [
            AppShimmerBox(width: 60, height: 12),
            Spacer(),
            AppShimmerBox(width: 70, height: 22, borderRadius: 7),
            SizedBox(width: 6),
            AppShimmerBox(width: 50, height: 22, borderRadius: 7),
          ]),
          const SizedBox(height: 10),
          Row(children: const [
            AppShimmerBox(width: 60, height: 12),
            Spacer(),
            AppShimmerBox(width: 80, height: 14),
          ]),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: AppShimmerBox(height: 36, borderRadius: 10),
              ),
              SizedBox(width: 10),
              Expanded(
                child: AppShimmerBox(height: 36, borderRadius: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stats grid shimmer (dashboard 3×2).
class StatsGridShimmer extends StatelessWidget {
  const StatsGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card() => LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppShimmerBox(width: w * 0.42, height: 8),
                      const Spacer(),
                      const AppShimmerBox(width: 20, height: 20, borderRadius: 6),
                    ],
                  ),
                  const SizedBox(height: 2),
                  AppShimmerBox(width: w * 0.28, height: 14),
                  const SizedBox(height: 2),
                  AppShimmerBox(width: w * 0.6, height: 8),
                ],
              ),
            );
          },
        );

    Widget row() => Row(children: [
          Expanded(child: card()),
          const SizedBox(width: 6),
          Expanded(child: card()),
          const SizedBox(width: 6),
          Expanded(child: card()),
        ]);

    return Column(
      children: [
        row(),
        const SizedBox(height: 6),
        row(),
      ],
    );
  }
}

/// Notification list shimmer.
class NotificationListShimmer extends StatelessWidget {
  const NotificationListShimmer({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppShimmerBox(width: 40, height: 40, borderRadius: 12),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppShimmerBox(width: 180, height: 13),
                  SizedBox(height: 8),
                  AppShimmerBox(width: double.infinity, height: 11),
                  SizedBox(height: 6),
                  AppShimmerBox(width: 120, height: 11),
                  SizedBox(height: 8),
                  AppShimmerBox(width: 70, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile screen shimmer.
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 40),
      children: [
        Center(
          child: Column(
            children: const [
              AppShimmerBox(width: 88, height: 88, borderRadius: 44),
              SizedBox(height: 14),
              AppShimmerBox(width: 140, height: 16),
              SizedBox(height: 8),
              AppShimmerBox(width: 180, height: 12),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ...List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppShimmerBox(width: 100, height: 12),
                  SizedBox(height: 12),
                  AppShimmerBox(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  AppShimmerBox(width: 200, height: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Space details screen shimmer.
class SpaceDetailShimmer extends StatelessWidget {
  const SpaceDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const AppShimmerBox(height: 280, borderRadius: 0),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppShimmerBox(width: 220, height: 20),
              const SizedBox(height: 10),
              const AppShimmerBox(width: 160, height: 12),
              const SizedBox(height: 16),
              Row(
                children: const [
                  AppShimmerBox(width: 70, height: 28, borderRadius: 8),
                  SizedBox(width: 8),
                  AppShimmerBox(width: 70, height: 28, borderRadius: 8),
                  SizedBox(width: 8),
                  AppShimmerBox(width: 70, height: 28, borderRadius: 8),
                ],
              ),
              const SizedBox(height: 20),
              const AppShimmerBox(width: double.infinity, height: 12),
              const SizedBox(height: 8),
              const AppShimmerBox(width: double.infinity, height: 12),
              const SizedBox(height: 8),
              const AppShimmerBox(width: 220, height: 12),
              const SizedBox(height: 24),
              const AppShimmerBox(width: 120, height: 16),
              const SizedBox(height: 12),
              ...List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: AppShimmerBox(width: double.infinity, height: 48, borderRadius: 12),
                ),
              ),
              const SizedBox(height: 8),
              const AppShimmerBox(width: double.infinity, height: 48, borderRadius: 12),
            ],
          ),
        ),
      ],
    );
  }
}
