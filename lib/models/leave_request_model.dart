import 'session_model.dart';
import 'student_model.dart';

class LeaveRequestModel {
  final int id;
  final StudentModel? sinhVien;
  final SessionModel? buoiHoc;
  final String lyDo;
  final String? hinhAnhMinhChung;
  String trangThai; // 'CHO_DUYET', 'DA_DUYET', 'TU_CHOI'
  String? ghiChuGiangVien;
  final String? ngayTao;

  LeaveRequestModel({
    required this.id,
    this.sinhVien,
    this.buoiHoc,
    required this.lyDo,
    this.hinhAnhMinhChung,
    this.trangThai = 'CHO_DUYET',
    this.ghiChuGiangVien,
    this.ngayTao,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      sinhVien: json['sinhVien'] != null ? StudentModel.fromJson(json['sinhVien']) : null,
      buoiHoc: json['buoiHoc'] != null ? SessionModel.fromJson(json['buoiHoc']) : null,
      lyDo: json['lyDo'] ?? json['reason'] ?? '',
      hinhAnhMinhChung: json['hinhAnhMinhChung'] ?? json['proofUrl'],
      trangThai: json['trangThai'] ?? json['status'] ?? 'CHO_DUYET',
      ghiChuGiangVien: json['ghiChuGiangVien'] ?? json['teacherNote'],
      ngayTao: json['ngayTao'] ?? json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sinhVien': sinhVien?.toJson(),
      'buoiHoc': buoiHoc?.toJson(),
      'lyDo': lyDo,
      'hinhAnhMinhChung': hinhAnhMinhChung,
      'trangThai': trangThai,
      'ghiChuGiangVien': ghiChuGiangVien,
      'ngayTao': ngayTao,
    };
  }

  String get trangThaiTiengViet {
    switch (trangThai) {
      case 'DA_DUYET':
      case 'APPROVED':
        return 'Đã duyệt';
      case 'TU_CHOI':
      case 'REJECTED':
        return 'Từ chối';
      case 'CHO_DUYET':
      case 'PENDING':
      default:
        return 'Chờ duyệt';
    }
  }
}
