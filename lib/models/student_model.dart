import 'class_model.dart';

class StudentModel {
  int id;
  String mssv;
  String hoTen;
  String gioiTinh;
  String? ngaySinh;
  String? email;
  String? soDienThoai;
  ClassModel? lopHoc;

  StudentModel({
    required this.id,
    required this.mssv,
    required this.hoTen,
    this.gioiTinh = 'Nam',
    this.ngaySinh,
    this.email,
    this.soDienThoai,
    this.lopHoc,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      mssv: json['mssv'] ?? json['code'] ?? '',
      hoTen: json['hoTen'] ?? json['fullName'] ?? '',
      gioiTinh: json['gioiTinh'] ?? 'Nam',
      ngaySinh: json['ngaySinh'],
      email: json['email'],
      soDienThoai: json['soDienThoai'],
      lopHoc: json['lopHoc'] != null ? ClassModel.fromJson(json['lopHoc']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mssv': mssv,
      'hoTen': hoTen,
      'gioiTinh': gioiTinh,
      'ngaySinh': ngaySinh,
      'email': email,
      'soDienThoai': soDienThoai,
      'lopHoc': lopHoc?.toJson(),
    };
  }
}
