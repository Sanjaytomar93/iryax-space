class ProfileModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String address;
  final String memberSince;
  final String role;
  final String organization;
  final String gstNumber;
  final bool isDoctor;

  const ProfileModel({
    this.id = '',
    this.name = '',
    this.email = '',
    this.mobile = '',
    this.address = '',
    this.memberSince = '',
    this.role = '',
    this.organization = '',
    this.gstNumber = '',
    this.isDoctor = false,
  });

  factory ProfileModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProfileModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      memberSince: _formatMemberSince(
        json['createdAt'],
      ),
      role: _formatRole(
        json['role']?.toString(),
      ),
      organization:
      json['organizationName']
          ?.toString() ??
          '',
      gstNumber:
      json['gstNumber']?.toString() ??
          '',
      isDoctor:
      json['isDoctor'] == true,
    );
  }

  static String _formatRole(
      String? value,
      ) {
    final role = value?.trim() ?? '';

    if (role.isEmpty) {
      return '';
    }

    return '${role[0].toUpperCase()}${role.substring(1)}';
  }

  static String _formatMemberSince(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    final parsed =
    DateTime.tryParse(
      value.toString(),
    );

    if (parsed == null) {
      return '';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${parsed.day.toString().padLeft(2, '0')} '
        '${months[parsed.month - 1]} '
        '${parsed.year}';
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? address,
    String? memberSince,
    String? role,
    String? organization,
    String? gstNumber,
    bool? isDoctor,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      memberSince:
      memberSince ?? this.memberSince,
      role: role ?? this.role,
      organization:
      organization ??
          this.organization,
      gstNumber:
      gstNumber ?? this.gstNumber,
      isDoctor:
      isDoctor ?? this.isDoctor,
    );
  }
}