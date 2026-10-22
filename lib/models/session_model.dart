import 'class_model.dart';

class SessionModel {
  int id;
  String tenBuoiHoc;
  String ngayHoc;
  String tietHoc;
  String phongHoc;
  ClassModel? lopHoc;

  SessionModel({
    required this.id,
    required this.tenBuoiHoc,
    required this.ngayHoc,
    this.tietHoc = 'Tiết 1 - 3',
    this.phongHoc = 'E1-02.05',
    this.lopHoc,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      tenBuoiHoc: json['tenBuoiHoc'] ?? json['title'] ?? '',
      ngayHoc: json['ngayHoc'] ?? (json['startTime'] != null ? json['startTime'].toString().substring(0, 10) : '2026-10-21'),
      tietHoc: json['tietHoc'] ?? 'Tiết 1 - 3',
      phongHoc: json['phongHoc'] ?? 'E1-02.05',
      lopHoc: json['lopHoc'] != null ? ClassModel.fromJson(json['lopHoc']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenBuoiHoc': tenBuoiHoc,
      'ngayHoc': ngayHoc,
      'tietHoc': tietHoc,
      'phongHoc': phongHoc,
      'lopHoc': lopHoc?.toJson(),
    };
  }
}
