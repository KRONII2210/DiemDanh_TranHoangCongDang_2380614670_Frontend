class UserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role; // 'ADMIN', 'GIANG_VIEN', 'SINH_VIEN'
  final String? phone;
  final String? mssv;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.mssv,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['username'] ?? '',
      role: (json['role'] ?? 'SINH_VIEN').toString().toUpperCase(),
      phone: json['phone'],
      mssv: json['mssv'] ?? json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'role': role,
      'phone': phone,
      'mssv': mssv,
    };
  }

  bool get isAdmin => role == 'ADMIN';
  bool get isLecturer => role == 'GIANG_VIEN' || role == 'LECTURER';
  bool get isStudent => role == 'SINH_VIEN' || role == 'STUDENT';
}
