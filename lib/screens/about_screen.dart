import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Đồ Án Điểm Danh'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student & Group Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade900, Colors.indigo.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.school, size: 42, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ĐỒ ÁN LẬP TRÌNH DI ĐỘNG',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'HỆ THỐNG ĐIỂM DANH SINH VIÊN',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.white30, height: 24),
                  _buildStudentInfoRow('Sinh viên thực hiện:', 'Trần Hoàng Công Đăng'),
                  _buildStudentInfoRow('Mã số sinh viên (MSSV):', '2380614670'),
                  _buildStudentInfoRow('Tên nhóm đồ án:', 'Nhóm TSV'),
                  _buildStudentInfoRow('Công nghệ sử dụng:', 'Flutter (Dart) + ASP.NET Core API + SQL Server'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // System Features & Capabilities
            const Text('TÍNH NĂNG NỔI BẬT CỦA HỆ THỐNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo)),
            const SizedBox(height: 12),

            _buildRubricItem(
              number: '1',
              title: 'Đăng ký tài khoản trực tuyến qua Email',
              desc: 'Hỗ trợ đăng ký tài khoản với xác nhận Email, phân chia quyền hạn rõ ràng và bảo mật cao.',
              status: 'SẴN SÀNG',
              color: Colors.green,
            ),
            _buildRubricItem(
              number: '2',
              title: 'Bảo mật đăng nhập 2 lớp (OTP xác thực)',
              desc: 'Quy trình đăng nhập 2 bước an toàn: kiểm tra thông tin và xác thực mã OTP ngẫu nhiên đổi mới mỗi lượt.',
              status: 'SẴN SÀNG',
              color: Colors.green,
            ),
            _buildRubricItem(
              number: '3',
              title: 'Phân quyền người dùng đa cấp bậc',
              desc: 'Giao diện tùy biến theo vai trò: Admin (quản trị), Giảng viên (tổ chức điểm danh), Sinh viên (điểm danh & theo dõi học tập).',
              status: 'SẴN SÀNG',
              color: Colors.green,
            ),
            _buildRubricItem(
              number: '4',
              title: 'Quản lý dữ liệu học tập toàn diện (CRUD)',
              desc: 'Tra cứu, khởi tạo, cập nhật và quản lý lớp học, sinh viên, buổi học cùng lịch sử điểm danh nhanh chóng.',
              status: 'SẴN SÀNG',
              color: Colors.green,
            ),
            _buildRubricItem(
              number: '5',
              title: 'Công nghệ điểm danh thông minh đa phương thức',
              desc: 'Tích hợp nhận diện khuôn mặt Face ID, định vị radar GPS Geofencing phòng học và mã QR động xoay vòng 30s chống gian lận.',
              status: 'SẴN SÀNG',
              color: Colors.blue,
            ),
            _buildRubricItem(
              number: '6',
              title: 'Cảnh báo chuyên cần & Quản lý đơn nghỉ phép',
              desc: 'Thuật toán tự động cảnh báo nguy cơ cấm thi khi vắng từ 20% trở lên và số hóa quy trình nộp đơn xin nghỉ kèm ảnh minh chứng.',
              status: 'SẴN SÀNG',
              color: Colors.purple,
            ),
            _buildRubricItem(
              number: '7',
              title: 'Thiết kế chuẩn Material 3 & Hoạt động ổn định',
              desc: 'Giao diện hiện đại, tối ưu trải nghiệm người dùng, tương thích cả khi trực tuyến lẫn ngoại tuyến.',
              status: 'SẴN SÀNG',
              color: Colors.teal,
            ),
            const SizedBox(height: 20),

            // Footer note
            Center(
              child: Text(
                'Bản quyền đồ án © 2026 - Trần Hoàng Công Đăng - 2380614670',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static Widget _buildStudentInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRubricItem({
    required String number,
    required String title,
    required String desc,
    required String status,
    required MaterialColor color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.shade100,
              child: Text(number, style: TextStyle(color: color.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(4), border: Border.all(color: color.shade300)),
                        child: Text(status, style: TextStyle(color: color.shade900, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
