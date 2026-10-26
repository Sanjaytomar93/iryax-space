import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iryax_spaces/modules/bookings/model/booking_model.dart';
import 'package:iryax_spaces/modules/bookings/service/invoice_pdf_service.dart';
class SpaceBookingDetailsDialog extends StatelessWidget {
  const SpaceBookingDetailsDialog({super.key, required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hours = _fmtHours(
      booking.totalHours > 0
          ? booking.totalHours
          : double.tryParse(booking.duration.replaceAll(RegExp(r'[^\d.]'), '')),
    );
    final days = booking.totalDays > 0 ? booking.totalDays : 1;
    final daily = _fmtHours(
      booking.dailyHours > 0 ? booking.dailyHours : booking.totalHours,
    );
    final rate = booking.hourlyRate;
    final subtotal = booking.subtotalAmount;
    final seatCharge = booking.extraCharge;
    final gst = booking.gstAmount;
    final total = booking.computedTotal > 0
        ? booking.computedTotal
        : (double.tryParse(
              booking.amount.replaceAll(RegExp(r'[^\d.]'), ''),
            ) ??
            0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: size.height * 0.92,
        ),
        child: Material(
          color: const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          elevation: 12,
          shadowColor: const Color(0x4226204A),
          child: Column(
            children: [
              _Header(booking: booking),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: c.maxWidth,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _CabinCard(booking: booking)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SpaceTypeCard(booking: booking),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _CustomerCard(booking: booking),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _TimeCard(
                                      label: 'START',
                                      date: booking.startDate,
                                      time: booking.startTime,
                                      accent: const Color(0xFF2563EB),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  Expanded(
                                    child: _TimeCard(
                                      label: 'END',
                                      date: booking.endDate,
                                      time: booking.endTime,
                                      accent: const Color(0xFF7C3AED),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _MetricsRow(
                                hours: hours,
                                days: days,
                                daily: daily,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _SlotCard(
                                      booking: booking,
                                      hours: hours,
                                      days: days,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SeatsCard(booking: booking),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _PriceCard(
                                hours: hours,
                                rate: rate,
                                subtotal: subtotal,
                                seatCharge: seatCharge,
                                gst: gst,
                                total: total,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _Footer(booking: booking),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtHours(double? v) {
    if (v == null || v <= 0) return '0';
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
}

// ─── Header ───────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F1A3D), Color(0xFF3D3568)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ID  #${booking.shortBookingId}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _Tag(
                      'Space Booking',
                      bg: Colors.white.withValues(alpha: 0.18),
                      fg: Colors.white,
                    ),
                    _Tag(
                      (booking.bookingBasis.capitalizeFirst ?? 'Hourly'),
                      bg: Colors.white.withValues(alpha: 0.18),
                      fg: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.18),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: Get.back,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

// ─── Cabin ────────────────────────────────────────────────
class _CabinCard extends StatelessWidget {
  const _CabinCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final address = booking.location.trim().isNotEmpty
        ? booking.location.trim()
        : (booking.city.trim().isNotEmpty ? booking.city.trim() : '—');

    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.apartment_rounded,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF4F46E5),
            title: 'CABIN DETAILS',
          ),
          const SizedBox(height: 8),
          Text(
            booking.spaceName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _MiniStat(
                'Cap ${booking.capacity > 0 ? booking.capacity : booking.seats}',
              ),
              _MiniStat(
                booking.hourlyRate > 0
                    ? '₹${_money(booking.hourlyRate)}/hr'
                    : '—/hr',
              ),
              _MiniStat(booking.cabinKind),
            ],
          ),
          const SizedBox(height: 8),
          _StatusBadge(status: booking.status),
        ],
      ),
    );
  }
}

// ─── Space type ───────────────────────────────────────────
class _SpaceTypeCard extends StatelessWidget {
  const _SpaceTypeCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      tint: const Color(0xFFECFDF5),
      border: const Color(0xFFA7F3D0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.layers_rounded,
            iconBg: const Color(0xFFD1FAE5),
            iconColor: const Color(0xFF059669),
            title: 'SPACE TYPE',
          ),
          const SizedBox(height: 10),
          _Tag(
            booking.shortTypeLabel,
            bg: const Color(0xFFFFEDD5),
            fg: const Color(0xFFC2410C),
            icon: Icons.local_cafe_rounded,
          ),
          const SizedBox(height: 10),
          _kv('Booking Type', 'booking'),
          const SizedBox(height: 3),
          _kv('Basis', booking.bookingBasis),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 11, height: 1.35),
        children: [
          TextSpan(
            text: '$k: ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: v,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Customer ─────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      tint: const Color(0xFFEFF6FF),
      border: const Color(0xFFBFDBFE),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.customerName.isNotEmpty
                      ? booking.customerName
                      : 'Customer',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (booking.customerMobile.isNotEmpty)
                      booking.customerMobile,
                    if (booking.customerEmail.isNotEmpty) booking.customerEmail,
                  ].join('  ·  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Time ─────────────────────────────────────────────────
class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.date,
    required this.time,
    required this.accent,
  });

  final String label;
  final String date;
  final String time;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Metrics ──────────────────────────────────────────────
class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.hours,
    required this.days,
    required this.daily,
  });

  final String hours;
  final int days;
  final String daily;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            value: '${hours}h',
            label: 'Total',
            bg: const Color(0xFFDBEAFE),
            fg: const Color(0xFF1D4ED8),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MetricTile(
            value: '$days',
            label: 'Days',
            bg: const Color(0xFFEDE9FE),
            fg: const Color(0xFF6D28D9),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MetricTile(
            value: '${daily}h',
            label: 'Daily',
            bg: const Color(0xFFE0F2FE),
            fg: const Color(0xFF0369A1),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _MetricTile(
            value: '${hours}h',
            label: 'Left',
            bg: const Color(0xFFFFEDD5),
            fg: const Color(0xFFC2410C),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.bg,
    required this.fg,
  });

  final String value;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: fg.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slot / Seats ─────────────────────────────────────────
class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.booking,
    required this.hours,
    required this.days,
  });

  final BookingModel booking;
  final String hours;
  final int days;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.event_available_rounded,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF4F46E5),
            title: 'SLOTS ($days)',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.startDate,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking.startTime} – ${booking.endTime}',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${hours}h',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeatsCard extends StatelessWidget {
  const _SeatsCard({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final seats = booking.selectedSeats.isNotEmpty
        ? booking.selectedSeats
        : List.generate(
            booking.seats > 0 ? booking.seats : 0,
            (i) => 'Seat ${i + 1} #${i + 1}',
          );

    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.event_seat_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            title: 'SEATS (${seats.isEmpty ? booking.seats : seats.length})',
          ),
          const SizedBox(height: 8),
          if (seats.isEmpty)
            Text(
              'N/A',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            )
          else
            Text(
              seats.take(2).join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Extra Charge: ₹${_money(booking.extraCharge)}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Price ────────────────────────────────────────────────
class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.hours,
    required this.rate,
    required this.subtotal,
    required this.seatCharge,
    required this.gst,
    required this.total,
  });

  final String hours;
  final double rate;
  final double subtotal;
  final double seatCharge;
  final double gst;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Column(
        children: [
          _row('Subtotal (${hours}h × ₹${_money(rate)})', '₹${_money(subtotal)}'),
          const SizedBox(height: 4),
          _row('Seat Charges', '₹${_money(seatCharge)}'),
          const SizedBox(height: 4),
          _row('GST (18%)', '₹${_money(gst)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 7),
            child: Divider(height: 1, color: Color(0xFF6EE7B7)),
          ),
          Row(
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF065F46),
                ),
              ),
              const Spacer(),
              Text(
                '₹${_money(total)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF047857),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF065F46),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF064E3B),
          ),
        ),
      ],
    );
  }
}

// ─── Footer ───────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer({required this.booking});
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: Get.back,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF26204A),
                side: const BorderSide(color: Color(0xFFE8E8F0), width: 1.2),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                minimumSize: const Size(0, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => InvoicePdfService.downloadAndShare(booking),
              borderRadius: BorderRadius.circular(22),
              child: Ink(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF26204A), Color(0xFF3D3568)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Text(
                    'Download Invoice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared bits ──────────────────────────────────────────
class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.tint = Colors.white,
    this.border = const Color(0xFFE2E8F0),
  });

  final Widget child;
  final Color tint;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26204A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 13, color: iconColor),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {required this.bg, required this.fg, this.icon});

  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            color: fg,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
          children: [
            if (icon != null)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(icon, size: 11, color: fg),
                ),
              ),
            TextSpan(text: text),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    late final String label;

    switch (status) {
      case BookingStatus.active:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        icon = Icons.check_circle_rounded;
        label = 'Active';
      case BookingStatus.confirmed:
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        icon = Icons.verified_rounded;
        label = 'Confirmed';
      case BookingStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        icon = Icons.schedule_rounded;
        label = 'Pending';
      case BookingStatus.completed:
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7E22CE);
        icon = Icons.task_alt_rounded;
        label = 'Completed';
      case BookingStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        label = 'Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

String _money(double v) {
  if (v % 1 == 0) return v.toInt().toString();
  return v.toStringAsFixed(2);
}
