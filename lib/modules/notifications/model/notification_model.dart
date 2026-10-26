class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final id = _string(json['_id'] ?? json['id'] ?? json['notificationId']);
    final title = _string(json['title'] ?? json['heading'] ?? json['subject']);
    final message = _string(
      json['message'] ??
          json['body'] ??
          json['description'] ??
          json['content'] ??
          json['text'],
    );
    final rawType = _string(
      json['type'] ?? json['category'] ?? json['tag'] ?? json['notificationType'],
    );
    final type = _resolveType(rawType: rawType, title: title, message: message);
    final isRead = _parseIsRead(json);
    final createdAt = _date(
      json['createdAt'] ??
          json['created_at'] ??
          json['timestamp'] ??
          json['date'] ??
          json['time'],
    );

    return NotificationModel(
      id: id,
      title: title.isEmpty ? 'Notification' : title,
      message: message,
      type: type,
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  /// Classifies using type + title + message so booking alerts
  /// don't fall into System when API sends a generic type.
  static String _resolveType({
    required String rawType,
    required String title,
    required String message,
  }) {
    final raw = rawType.toLowerCase().trim();
    final blob = '$raw $title $message'.toLowerCase();

    if (_isBooking(blob) || raw == 'booking' || raw == 'bookings') {
      return 'bookings';
    }
    if (_isOffer(blob) || raw == 'offer' || raw == 'offers') {
      return 'offers';
    }
    if (raw == 'system' || raw == 'account' || raw == 'general') {
      return 'system';
    }
    return 'system';
  }

  static bool _isBooking(String blob) {
    const keys = [
      'booking',
      'booked',
      'book space',
      'payment',
      'paid',
      'invoice',
      'site visit',
      'sitevisit',
      'reservation',
      'confirmed',
      'cancel booking',
      'cancelled booking',
    ];
    return keys.any(blob.contains);
  }

  static bool _isOffer(String blob) {
    const keys = [
      'offer',
      'promo',
      'discount',
      'coupon',
      'deal',
      '% off',
      'flat ',
      'special offer',
    ];
    return keys.any(blob.contains);
  }

  static bool _parseIsRead(Map<String, dynamic> json) {
    if (json.containsKey('isRead')) return _bool(json['isRead']);
    if (json.containsKey('read')) return _bool(json['read']);
    if (json.containsKey('is_read')) return _bool(json['is_read']);
    if (json.containsKey('seen')) return _bool(json['seen']);
    if (json.containsKey('unread')) return !_bool(json['unread']);
    final status = _string(json['status']).toLowerCase();
    if (status == 'read' || status == 'seen') return true;
    if (status == 'unread' || status == 'new') return false;
    return false;
  }

  static String _string(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static bool _bool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }

  static DateTime? _date(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      final ms = value > 9999999999 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return DateTime.tryParse(value.toString());
  }
}
