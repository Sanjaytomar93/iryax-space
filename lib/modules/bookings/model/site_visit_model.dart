enum SiteVisitStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class SiteVisitModel {
  final String id;

  final String spaceName;
  final String location;
  final String spaceType;

  final String visitDate;
  final String visitTime;

  final String visitorName;
  final String visitorMobile;
  final String visitorEmail;

  final String createdAt;

  final SiteVisitStatus status;

  const SiteVisitModel({
    required this.id,
    required this.spaceName,
    required this.location,
    required this.spaceType,
    required this.visitDate,
    required this.visitTime,
    required this.visitorName,
    required this.visitorMobile,
    required this.visitorEmail,
    required this.createdAt,
    required this.status,
  });

  factory SiteVisitModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final cabinRaw =
    json['cabin'];

    final cabin = cabinRaw is Map
        ? Map<String, dynamic>.from(
      cabinRaw,
    )
        : <String, dynamic>{};

    final isChamber =
        cabin['isChamber'] == true;

    final cabinType =
    cabin['cabinType']
        ?.toString()
        .trim()
        .toLowerCase();

    final type =
    cabin['type']
        ?.toString()
        .trim()
        .toLowerCase();

    return SiteVisitModel(
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

      visitDate:
      _formatDate(
        json['startDate'],
      ),

      visitTime:
      _formatTime(
        json['startTime'],
      ),

      visitorName:
      json['name']?.toString() ??
          '',

      visitorMobile:
      json['mobile']?.toString() ??
          '',

      visitorEmail:
      json['email']?.toString() ??
          '',

      createdAt:
      _formatDateTime(
        json['createdAt'],
      ),

      status:
      _parseStatus(
        json['status'],
      ),
    );
  }

  static SiteVisitStatus _parseStatus(
      dynamic value,
      ) {
    switch (
    value
        ?.toString()
        .trim()
        .toLowerCase()) {
      case 'confirmed':
        return SiteVisitStatus.confirmed;

      case 'completed':
        return SiteVisitStatus.completed;

      case 'cancelled':
      case 'canceled':
        return SiteVisitStatus.cancelled;

      default:
        return SiteVisitStatus.pending;
    }
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
    int.tryParse(
      parts[0],
    );

    final minute =
    int.tryParse(
      parts[1],
    );

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