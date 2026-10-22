import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/attendance_model.dart';
import '../widgets/server_config_dialog.dart';
import 'login_screen.dart';
import 'qr_scanner_screen.dart';
import 'gps_geofence_screen.dart';
import 'face_auth_screen.dart';
import 'leave_request_screen.dart';
import 'about_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  List<AttendanceModel> _attendances = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final list = await ApiService.instance.getAttendancesBySession(1);
    setState(() {
      _attendances = list;
      _isLoading = false;
    });
  }

  void _logout() {
    AuthService.instance.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final fullName = user?.fullName ?? 'Trần Hoàng Công Đăng';
    final mssv = user?.mssv ?? '2380614670';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Sinh Viên'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Cấu hình Web API',
            onPressed: () => ServerConfigDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Thông tin nhóm TSV',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Student Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade900, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: const Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('SINH VIÊN CHÍNH THỨC', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  fullName,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'MSSV: $mssv | Nhóm TSV',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const Text(
                                  'Lớp: LTDD01 - Lập trình di động',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Early Warning Card (Novel Feature)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.green.shade700, size: 36),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('THEO DÕI CHUYÊN CẦN & CẢNH BÁO CẤM THI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                                SizedBox(height: 2),
                                Text(
                                  'Tỷ lệ vắng: 0% / Tối đa 20% cho phép.\nTrạng thái: AN TOÀN - Đủ điều kiện dự thi cuối kỳ!',
                                  style: TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Feature Grid (3 core presentation features + Novel feature)
                    const Text('CHỨC NĂNG CHÍNH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.qr_code_scanner,
                          color: Colors.blue.shade700,
                          title: 'Điểm Danh QR',
                          subtitle: 'Quét mã QR từ Giảng viên',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen())),
                        ),
                        _buildFeatureCard(
                          icon: Icons.share_location,
                          color: Colors.red.shade700,
                          title: 'Vị Trí GPS',
                          subtitle: 'Chia sẻ vị trí & Radar phòng',
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GpsGeofenceScreen())),
                        ),
                        _buildFeatureCard(
                          icon: Icons.face_retouching_natural,
                          color: Colors.purple.shade700,
                          title: 'Face ID',
                          subtitle: 'Xác thực sinh trắc học',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FaceAuthScreen(
                                studentName: fullName,
                                mssv: mssv,
                                onVerified: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Xác thực khuôn mặt Face ID thành công!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        _buildFeatureCard(
                          icon: Icons.assignment_turned_in,
                          color: Colors.amber.shade800,
                          title: 'Đơn Nghỉ Phép',
                          subtitle: 'Nộp đơn & minh chứng y tế',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LeaveRequestScreen(lopId: 1, isLecturer: false)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Attendance History
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('LỊCH SỬ ĐIỂM DANH GẦN ĐÂY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                        TextButton(
                          onPressed: _loadData,
                          child: const Text('Làm mới', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_attendances.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('Chưa có dữ liệu điểm danh.')),
                        ),
                      )
                    else
                      ..._attendances.map((att) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: att.trangThai == 'PRESENT' ? Colors.green.shade50 : Colors.amber.shade50,
                              child: Icon(
                                att.trangThai == 'PRESENT' ? Icons.check_circle : Icons.access_time,
                                color: att.trangThai == 'PRESENT' ? Colors.green : Colors.amber.shade800,
                              ),
                            ),
                            title: Text(att.buoiHoc?.tenBuoiHoc ?? 'Buổi học', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('Thời gian: ${att.thoiGianDiemDanh} | ${att.ghiChu}', style: const TextStyle(fontSize: 11)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: att.trangThai == 'PRESENT' ? Colors.green.shade100 : Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                att.trangThai == 'PRESENT' ? 'CÓ MẶT' : 'ĐI TRỄ',
                                style: TextStyle(
                                  color: att.trangThai == 'PRESENT' ? Colors.green.shade900 : Colors.amber.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
