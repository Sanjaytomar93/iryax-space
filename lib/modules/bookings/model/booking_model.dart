enum BookingStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum PaymentMode {
  online,
  cash,
}

class BookingModel {
  final String id;

  final String spaceName;
  final String location;
  final String spaceType;

  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;

  final String duration;
  final String days;
  final int seats;

  final String amount;
  final String createdAt;

  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMode paymentMode;

  final String customerName;
  final String customerEmail;
  final String customerMobile;

  /// Extra fields for rich details / invoice (Numbers-style sheet).
  final double totalHours;
  final int totalDays;
  final double hourlyRate;
  final int capacity;
  final String cabinKind;
  final double extraCharge;
  final List<String> selectedSeats;
  final String transactionId;
  final String bookingBasis;
  final String city;

  const BookingModel({
    required this.id,
    required this.spaceName,
    required this.location,
    required this.spaceType,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.duration,
    required this.days,
    required this.seats,
    required this.amount,
    required this.createdAt,
    required this.status,
    required this.paymentStatus,
    required this.paymentMode,
    required this.customerName,
    required this.customerEmail,
    required this.customerMobile,
    this.totalHours = 0,
    this.totalDays = 1,
    this.hourlyRate = 0,
    this.capacity = 0,
    this.cabinKind = 'normal',
    this.extraCharge = 0,
    this.selectedSeats = const [],
    this.transactionId = '',
    this.bookingBasis = 'hourly',
    this.city = '',
  });

  BookingModel copyWith({
    String? id,
    String? spaceName,
    String? location,
    String? spaceType,
    String? startDate,
    String? startTime,
    String? endDate,
    String? endTime,
    String? duration,
    String? days,
    int? seats,
    String? amount,
    String? createdAt,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    PaymentMode? paymentMode,
    String? customerName,
    String? customerEmail,
    String? customerMobile,
    double? totalHours,
    int? totalDays,
    double? hourlyRate,
    int? capacity,
    String? cabinKind,
    double? extraCharge,
    List<String>? selectedSeats,
    String? transactionId,
    String? bookingBasis,
    String? city,
  }) {
    return BookingModel(
      id: id ?? this.id,
      spaceName: spaceName ?? this.spaceName,
      location: location ?? this.location,
      spaceType: spaceType ?? this.spaceType,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      days: days ?? this.days,
      seats: seats ?? this.seats,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMode: paymentMode ?? this.paymentMode,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerMobile: customerMobile ?? this.customerMobile,
      totalHours: totalHours ?? this.totalHours,
      totalDays: totalDays ?? this.totalDays,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      capacity: capacity ?? this.capacity,
      cabinKind: cabinKind ?? this.cabinKind,
      extraCharge: extraCharge ?? this.extraCharge,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      transactionId: transactionId ?? this.transactionId,
      bookingBasis: bookingBasis ?? this.bookingBasis,
      city: city ?? this.city,
    );
  }

  factory BookingModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final cabinRaw = json['cabin'];

    final cabin = cabinRaw is Map
        ? Map<String, dynamic>.from(cabinRaw)
        : <String, dynamic>{};

    final cabinType =
    cabin['cabinType']
        ?.toString()
        .trim()
        .toLowerCase();

    final isChamber =
        cabin['isChamber'] == true;

    final type =
    cabin['type']
        ?.toString()
        .trim()
        .toLowerCase();

    final totalHours =
    _toDouble(
      json['totalHours'],
    );

    final totalDays =
    _toInt(
      json['totalDays'],
    );

    final seatCount =
    _toInt(
      json['seatCount'],
    );

    final totalPrice =
    _toDouble(
      json['totalPrice'],
    );

    final hourlyRate = _toDouble(
      cabin['price'] ??
          cabin['hourlyPrice'] ??
          json['hourlyRate'] ??
          json['price'],
    );

    final seatsRaw = json['selectedSeats'];
    final selectedSeats = <String>[];
    if (seatsRaw is List) {
      for (final s in seatsRaw) {
        if (s == null) continue;
        if (s is Map) {
          final name = s['name']?.toString() ??
              s['seatName']?.toString() ??
              s['label']?.toString() ??
              '';
          final id = s['id']?.toString() ??
              s['_id']?.toString() ??
              s['seatNumber']?.toString() ??
              '';
          if (name.isNotEmpty) {
            selectedSeats.add(id.isNotEmpty ? '$name #$id' : name);
          } else if (id.isNotEmpty) {
            selectedSeats.add('Seat $id');
          }
        } else {
          final text = s.toString().trim();
          if (text.isNotEmpty) selectedSeats.add(text);
        }
      }
    }

    final city = cabin['city']?.toString().trim() ??
        cabin['location']?.toString().trim() ??
        json['city']?.toString().trim() ??
        '';

    final address = () {
      final fromCabin = cabin['address']?.toString().trim() ?? '';
      if (fromCabin.isNotEmpty) return fromCabin;
      final fromRoot = json['address']?.toString().trim() ?? '';
      if (fromRoot.isNotEmpty) return fromRoot;
      final fromLocation = cabin['fullAddress']?.toString().trim() ??
          json['location']?.toString().trim() ??
          '';
      if (fromLocation.isNotEmpty) return fromLocation;
      return city;
    }();

    return BookingModel(
      id:
      json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      spaceName:
      cabin['name']?.toString() ??
          json['cabinName']?.toString() ??
          'Workspace',

      location: address,

      spaceType: () {
        final isCafe = cabin['isCafe'] == true;
        if (isChamber) return 'Medical Chamber';
        if (isCafe) return 'Cafe & Dining';
        if (cabinType == 'exclusive') return 'Private Office';
        if (type == 'meeting' || cabinType == 'meeting') {
          return 'Meeting Room';
        }
        return 'Co-Working Space';
      }(),

      startDate:
      _formatDate(
        json['startDate'],
      ),

      startTime:
      _formatTime(
        json['startTime'],
      ),

      endDate:
      _formatDate(
        json['endDate'],
      ),

      endTime:
      _formatTime(
        json['endTime'],
      ),

      duration:
      '${_formatNumber(totalHours)}h',

      days:
      '${totalDays <= 0 ? 1 : totalDays}d',

      seats:
      seatCount,

      amount:
      _formatPrice(
        totalPrice,
      ),

      createdAt:
      _formatDateTime(
        json['createdAt'],
      ),

      status:
      _parseBookingStatus(
        json['status'],
      ),

      paymentStatus:
      _parsePaymentStatus(
        json['paymentStatus'],
      ),

      paymentMode:
      _parsePaymentMode(
        json['paymentMethod'],
      ),

      customerName:
      json['name']?.toString() ??
          '',

      customerEmail:
      json['email']?.toString() ??
          '',

      customerMobile:
      json['mobile']?.toString() ??
          '',

      totalHours: totalHours,
      totalDays: totalDays <= 0 ? 1 : totalDays,
      hourlyRate: hourlyRate,
      capacity: _toInt(
        cabin['capacity'] ?? cabin['seatCount'] ?? seatCount,
      ),
      cabinKind: cabin['cabinType']?.toString().trim().isNotEmpty == true
          ? cabin['cabinType'].toString().trim()
          : (cabin['type']?.toString().trim().isNotEmpty == true
              ? cabin['type'].toString().trim()
              : 'normal'),
      extraCharge: _toDouble(json['extraCharge']),
      selectedSeats: selectedSeats,
      transactionId: json['transactionId']?.toString() ??
          json['paymentId']?.toString() ??
          json['orderId']?.toString() ??
          '',
      bookingBasis:
          json['bookingBasis']?.toString().trim().isNotEmpty == true
              ? json['bookingBasis'].toString().trim()
              : 'hourly',
      city: city,
    );
  }

  double get dailyHours =>
      totalDays > 0 && totalHours > 0 ? totalHours / totalDays : totalHours;

  double get subtotalAmount =>
      hourlyRate > 0 && totalHours > 0 ? hourlyRate * totalHours : 0;

  double get gstAmount {
    final base = subtotalAmount + extraCharge;
    return base > 0 ? base * 0.18 : 0;
  }

  double get computedTotal => subtotalAmount + extraCharge + gstAmount;

  String get shortTypeLabel {
    final t = spaceType.toLowerCase();
    if (t.contains('cafe')) return 'Cafe';
    if (t.contains('medical')) return 'Medical';
    if (t.contains('meeting')) return 'Meeting';
    if (t.contains('private')) return 'Private Office';
    return 'Co-Working';
  }

  String get shortBookingId {
    if (id.isEmpty) return 'REF';
    if (id.length <= 8) return id.toUpperCase();
    return id.substring(id.length - 8).toUpperCase();
  }

  static BookingStatus _parseBookingStatus(
      dynamic value,
      ) {
    switch (
    value
        ?.toString()
        .trim()
        .toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;

      case 'active':
        return BookingStatus.active;

      case 'completed':
        return BookingStatus.completed;

      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;

      default:
        return BookingStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(
      dynamic value,
      ) {
    switch (
    value
        ?.toString()
        .trim()
        .toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
      case 'fail':
        return PaymentStatus.failed;
      case 'refunded':
      case 'refund':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  static PaymentMode _parsePaymentMode(
      dynamic value,
      ) {
    switch (
    value
        ?.toString()
        .trim()
        .toLowerCase()) {
      case 'cash':
        return PaymentMode.cash;

      default:
        return PaymentMode.online;
    }
  }

  static int _toInt(
      dynamic value,
      ) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static double _toDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static String _formatNumber(
      double value,
      ) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  static String _formatPrice(
      double value,
      ) {
    if (value % 1 == 0) {
      return '₹${value.toInt()}';
    }

    return '₹${value.toStringAsFixed(2)}';
  }

  static String _formatDate(
      dynamic value,
      ) {
    final text =
        value?.toString().trim() ??
            '';

    if (text.isEmpty) {
      return '--';
    }

    final date =
    DateTime.tryParse(text);

    if (date == null) {
      return text;
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String _formatTime(
      dynamic value,
      ) {
    final text =
        value?.toString().trim() ??
            '';

    if (text.isEmpty) {
      return '--';
    }

    final parts =
    text.split(':');

    if (parts.length < 2) {
      return text;
    }

    final hour =
    int.tryParse(parts[0]);

    final minute =
    int.tryParse(parts[1]);

    if (hour == null ||
        minute == null) {
      return text;
    }

    final period =
    hour >= 12
        ? 'PM'
        : 'AM';

    var displayHour =
        hour % 12;

    if (displayHour == 0) {
      displayHour = 12;
    }

    return '$displayHour:'
        '${minute.toString().padLeft(2, '0')} '
        '$period';
  }

  static String _formatDateTime(
      dynamic value,
      ) {
    final text =
        value?.toString().trim() ??
            '';

    if (text.isEmpty) {
      return '--';
    }

    final date =
    DateTime.tryParse(text);

    if (date == null) {
      return text;
    }

    final local =
    date.toLocal();

    final period =
    local.hour >= 12
        ? 'PM'
        : 'AM';

    var hour =
        local.hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '$hour:'
        '${local.minute.toString().padLeft(2, '0')} '
        '$period';
  }
}