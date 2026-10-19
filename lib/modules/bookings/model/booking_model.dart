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
  });

  factory BookingModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final cabinRaw = json['cabin'];

    final cabin = cabinRaw is Map
        ? Map<String, dynamic>.from(cabinRaw)
        : <String, dynamic>{};

    final amenitiesRaw =
    cabin['amenities'];

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

    return BookingModel(
      id:
      json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      spaceName:
      cabin['name']?.toString() ??
          json['cabinName']?.toString() ??
          'Workspace',

      location:
      cabin['address']?.toString() ??
          '',

      spaceType:
      isChamber
          ? 'Medical Chamber'
          : cabinType == 'exclusive'
          ? 'Private Office'
          : type == 'coworking'
          ? 'Co-Working Space'
          : 'Co-Working Space',

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
    );
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