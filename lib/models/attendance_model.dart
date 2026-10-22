import 'session_model.dart';
import 'student_model.dart';

class AttendanceModel {
  final int id;
  final SessionModel? buoiHoc;
  final StudentModel? sinhVien;
  String trangThai; // 'PRESENT', 'LATE', 'ABSENT_EXCUSED', 'ABSENT_UNEXCUSED'
  String? ghiChu;
  String? thoiGianDiemDanh;

  AttendanceModel({
    required this.id,
    this.buoiHoc,
    this.sinhVien,
    this.trangThai = 'PRESENT',
    this.ghiChu,
    this.thoiGianDiemDanh,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      buoiHoc: json['buoiHoc'] != null ? SessionModel.fromJson(json['buoiHoc']) : null,
      sinhVien: json['sinhVien'] != null ? StudentModel.fromJson(json['sinhVien']) : null,
      trangThai: json['trangThai'] ?? json['status'] ?? 'PRESENT',
      ghiChu: json['ghiChu'] ?? json['note'],
      thoiGianDiemDanh: json['thoiGianDiemDanh'] ?? json['checkInTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buoiHoc': buoiHoc?.toJson(),
      'sinhVien': sinhVien?.toJson(),
      'trangThai': trangThai,
      'ghiChu': ghiChu,
      'thoiGianDiemDanh': thoiGianDiemDanh,
    };
  }

  String get trangThaiTiengViet {
    switch (trangThai) {
      case 'PRESENT':
        return 'Có mặt';
      case 'LATE':
        return 'Đi trễ';
      case 'ABSENT_EXCUSED':
        return 'Có phép';
      case 'ABSENT_UNEXCUSED':
        return 'Vắng';
      default:
        return 'Chưa điểm danh';
    }
  }
}
