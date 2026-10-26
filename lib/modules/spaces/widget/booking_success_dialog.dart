import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/service/invoice_pdf_service.dart';

/// Impressive booking confirmation popup (app theme: #26204A).
class BookingSuccessDialog extends StatefulWidget {
  const BookingSuccessDialog({
    super.key,
    required this.onViewBooking,
    required this.spaceName,
    required this.location,
    required this.dateText,
    required this.timeText,
    required this.peopleText,
    required this.bookingId,
    required this.hourlyRateText,
    required this.totalAmountText,
    this.imageUrl = '',
    this.paymentLabel = 'Pay at Counter',
    this.booking,
    this.headerTitle = 'Booking Confirmed',
    this.congratsTitle = 'Congratulations!',
    this.congratsSubtitle = 'Your space has been successfully booked.',
    this.primaryActionLabel = 'View Booking',
    this.showInvoice = true,
    this.showPaymentAndTotal = true,
  });

  final VoidCallback onViewBooking;
  final String spaceName;
  final String location;
  final String dateText;
  final String timeText;
  final String peopleText;
  final String bookingId;
  final String hourlyRateText;
  final String totalAmountText;
  final String imageUrl;
  final String paymentLabel;
  final BookingModel? booking;
  final String headerTitle;
  final String congratsTitle;
  final String congratsSubtitle;
  final String primaryActionLabel;
  final bool showInvoice;
  final bool showPaymentAndTotal;

  static Future<void> show({
    required VoidCallback onViewBooking,
    required String spaceName,
    required String location,
    required String dateText,
    required String timeText,
    required String peopleText,
    required String bookingId,
    required String hourlyRateText,
    required String totalAmountText,
    String imageUrl = '',
    String paymentLabel = 'Pay at Counter',
    BookingModel? booking,
    String headerTitle = 'Booking Confirmed',
    String congratsTitle = 'Congratulations!',
    String congratsSubtitle = 'Your space has been successfully booked.',
    String primaryActionLabel = 'View Booking',
    bool showInvoice = true,
    bool showPaymentAndTotal = true,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Get.dialog(
      BookingSuccessDialog(
        onViewBooking: onViewBooking,
        spaceName: spaceName,
        location: location,
        dateText: dateText,
        timeText: timeText,
        peopleText: peopleText,
        bookingId: bookingId,
        hourlyRateText: hourlyRateText,
        totalAmountText: totalAmountText,
        imageUrl: imageUrl,
        paymentLabel: paymentLabel,
        booking: booking,
        headerTitle: headerTitle,
        congratsTitle: congratsTitle,
        congratsSubtitle: congratsSubtitle,
        primaryActionLabel: primaryActionLabel,
        showInvoice: showInvoice,
        showPaymentAndTotal: showPaymentAndTotal,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      useSafeArea: true,
    );
  }

  @override
  State<BookingSuccessDialog> createState() => _BookingSuccessDialogState();
}

class _BookingSuccessDialogState extends State<BookingSuccessDialog>
    with TickerProviderStateMixin {
  static const _navy = Color(0xFF26204A);
  static const _navySoft = Color(0xFF3D3568);
  static const _accent = Color(0xFF4338CA);
  static const _muted = Color(0xFF8A8A99);
  static const _border = Color(0xFFE7E7F0);
  static const _green = Color(0xFF16803C);
  static const _greenBg = Color(0xFFEAFBF0);

  late final AnimationController _entry;
  late final AnimationController _idle;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _badgeScale;
  late final Animation<double> _confettiBurst;
  late final Animation<double> _checkProgress;

  bool _closed = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _scaleAnim = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    );
    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _entry,
        curve: const Interval(0.05, 0.65, curve: Curves.linear),
      ),
    );
    _confettiBurst = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.1, 0.85, curve: Curves.easeOutCubic),
    );
    _checkProgress = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.32, 0.82, curve: Curves.easeOutCubic),
    );
    _entry.forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    _idle.dispose();
    super.dispose();
  }

  void _closeThen(VoidCallback action) {
    if (_closed) return;
    _closed = true;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    } else if (Get.isDialogOpen == true) {
      Get.back();
    }
    action();
  }

  Future<void> _downloadInvoice() async {
    final booking = widget.booking;
    if (booking == null || booking.id.isEmpty) {
      Get.snackbar(
        'Invoice',
        'Invoice My Bookings se download kar sakte ho.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      await InvoicePdfService.downloadInvoice(booking);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.88;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _closeThen(widget.onViewBooking);
      },
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 0,
            child: Container(
              constraints: BoxConstraints(maxWidth: 400, maxHeight: maxH),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FB),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _navy.withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                        child: Column(
                          children: [
                            _buildCelebration(),
                            const SizedBox(height: 12),
                            _buildDetailsCard(),
                            const SizedBox(height: 12),
                            _buildActions(),
                            const SizedBox(height: 14),
                            _buildWhatsNext(),
                            const SizedBox(height: 12),
                            _buildHelpCard(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _closeThen(widget.onViewBooking),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            color: _navy,
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Text(
              widget.headerTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _closeThen(widget.onViewBooking),
            icon: const Icon(Icons.close_rounded, size: 20),
            color: _muted,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildCelebration() {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_confettiBurst, _idle]),
                builder: (_, __) {
                  return CustomPaint(
                    size: const Size(150, 130),
                    painter: _ConfettiPainter(
                      burstProgress: _confettiBurst.value,
                      idleProgress: _idle.value,
                    ),
                  );
                },
              ),
              ScaleTransition(
                scale: _badgeScale,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_navy, _navySoft],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _navy.withValues(alpha: 0.28),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: _checkProgress,
                    builder: (_, __) {
                      return CustomPaint(
                        size: const Size(28, 28),
                        painter: _AnimatedCheckPainter(
                          progress: _checkProgress.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          widget.congratsTitle,
          style: const TextStyle(
            color: _navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.congratsSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: widget.imageUrl.isEmpty
                      ? Container(
                          color: const Color(0xFFF1F0FD),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: _navy,
                            size: 22,
                          ),
                        )
                      : Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF1F0FD),
                            child: const Icon(
                              Icons.apartment_rounded,
                              color: _navy,
                              size: 22,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.spaceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: _muted,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            widget.location.isEmpty
                                ? 'Location unavailable'
                                : widget.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _greenBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Confirmed',
                            style: TextStyle(
                              color: _green,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.hourlyRateText,
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 6),
          _detailRow(Icons.calendar_today_outlined, 'Date', widget.dateText),
          _detailRow(Icons.access_time_rounded, 'Time', widget.timeText),
          if (widget.peopleText.isNotEmpty)
            _detailRow(
              Icons.groups_outlined,
              'No. of People',
              widget.peopleText,
            ),
          _detailRow(
            Icons.receipt_long_outlined,
            'Booking ID',
            widget.bookingId.isEmpty ? '—' : '#${widget.bookingId}',
          ),
          if (widget.showPaymentAndTotal) ...[
            _detailRow(
              Icons.payments_outlined,
              'Payment',
              widget.paymentLabel,
            ),
            _detailRow(
              Icons.sell_outlined,
              'Total Amount',
              widget.totalAmountText,
              valueStyle: const TextStyle(
                color: _accent,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: _navy),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: valueStyle ??
                  const TextStyle(
                    color: _navy,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final viewBtn = SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: () => _closeThen(widget.onViewBooking),
        icon: const Icon(Icons.visibility_outlined, size: 15),
        label: Text(
          widget.primaryActionLabel,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _navy,
          side: const BorderSide(color: Color(0xFFD6D2EF)),
          backgroundColor: const Color(0xFFF1F0FD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );

    if (!widget.showInvoice) {
      return SizedBox(
        width: double.infinity,
        child: SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () => _closeThen(widget.onViewBooking),
            icon: const Icon(Icons.visibility_outlined, size: 15),
            label: Text(
              widget.primaryActionLabel,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: _navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: viewBtn),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _downloading ? null : _downloadInvoice,
              icon: _downloading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded, size: 15),
              label: const Text(
                'Download Invoice',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _navySoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsNext() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's Next?",
            style: TextStyle(
              color: _navy,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _step(
                icon: Icons.check_circle_rounded,
                label: 'Booking\nConfirmed',
                active: true,
              ),
              Expanded(child: _dottedLine()),
              _step(
                icon: Icons.mail_outline_rounded,
                label: 'Check\nDetails',
                active: false,
              ),
              Expanded(child: _dottedLine()),
              _step(
                icon: Icons.apartment_rounded,
                label: 'Visit &\nEnjoy',
                active: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _step({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? _navy : const Color(0xFFF1F0FD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: active ? Colors.white : _muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? _navy : _muted,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dottedLine() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final dots = (constraints.maxWidth / 6).floor().clamp(3, 12);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            dots,
            (i) => Container(
              width: 3,
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: _border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Get.snackbar(
            'Need Help?',
            'Support ke liye My Bookings ya Profile se contact karein.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _navy,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF4F2FF), Color(0xFFF1F0FD)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0DCF5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: _accent, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Need Help?',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: _muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCheckPainter extends CustomPainter {
  const _AnimatedCheckPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fullPath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.74)
      ..lineTo(size.width * 0.80, size.height * 0.28);

    if (progress >= 1.0) {
      canvas.drawPath(fullPath, paint);
      return;
    }

    final animatedPath = Path();
    for (final ui.PathMetric metric in fullPath.computeMetrics()) {
      animatedPath.addPath(
        metric.extractPath(0.0, metric.length * progress),
        Offset.zero,
      );
    }
    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(_AnimatedCheckPainter old) => old.progress != progress;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.burstProgress,
    required this.idleProgress,
  });

  final double burstProgress;
  final double idleProgress;

  static const _colors = [
    Color(0xFFFCD34D),
    Color(0xFF93C5FD),
    Color(0xFFFCA5A5),
    Color(0xFFB4A5D7),
    Color(0xFF6EE7B7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (burstProgress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..isAntiAlias = true;
    final rng = math.Random(42);

    for (var i = 0; i < 22; i++) {
      final angle = (i / 22) * math.pi * 2;
      final dist = 28.0 + (i % 5) * 8.0;
      final floatY =
          math.sin((idleProgress + i * 0.11) * 2 * math.pi) * 2.2;
      final p = center +
          Offset(
                math.cos(angle) * dist,
                math.sin(angle) * dist,
              ) *
              burstProgress +
          Offset(0, floatY);
      paint.color = _colors[i % _colors.length]
          .withValues(alpha: burstProgress.clamp(0.0, 1.0));

      if (i % 3 == 0) {
        canvas.drawCircle(p, 2.2 * burstProgress, paint);
      } else if (i % 3 == 1) {
        final r = 3.8 * burstProgress;
        final path = Path();
        for (var j = 0; j < 10; j++) {
          final rr = j.isEven ? r : r * 0.45;
          final a = j * math.pi / 5 + rng.nextDouble();
          final x = p.dx + rr * math.cos(a);
          final y = p.dy + rr * math.sin(a);
          if (j == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: p,
              width: 5 * burstProgress,
              height: 2.2 * burstProgress,
            ),
            const Radius.circular(1),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.burstProgress != burstProgress || old.idleProgress != idleProgress;
}
