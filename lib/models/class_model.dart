class ClassModel {
  int id;
  String maLop;
  String tenLop;
  String hocKy;
  String monHoc;
  String giangVien;

  ClassModel({
    required this.id,
    required this.maLop,
    required this.tenLop,
    required this.hocKy,
    required this.monHoc,
    required this.giangVien,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      maLop: json['maLop'] ?? json['code'] ?? '',
      tenLop: json['tenLop'] ?? json['name'] ?? '',
      hocKy: json['hocKy'] ?? 'Học kỳ 1 (2026-2027)',
      monHoc: json['monHoc'] ?? json['name'] ?? '',
      giangVien: json['giangVien'] ?? json['lecturerName'] ?? 'GV. Nguyễn Văn Giảng',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maLop': maLop,
      'tenLop': tenLop,
      'hocKy': hocKy,
      'monHoc': monHoc,
      'giangVien': giangVien,
    };
  }
}
