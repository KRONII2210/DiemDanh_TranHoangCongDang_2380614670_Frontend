import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/server_config_dialog.dart';
import 'login_screen.dart';
import 'crud_class_screen.dart';
import 'crud_student_screen.dart';
import 'summary_screen.dart';
import 'leave_request_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) {
    AuthService.instance.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Quản Trị Hệ Thống (Admin)'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Cấu hình Web API',
            onPressed: () => ServerConfigDialog.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade800, Colors.indigo.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.admin_panel_settings, size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HỆ THỐNG QUẢN TRỊ ADMIN',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.fullName ?? 'Quản Trị Viên Hệ Thống',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tài khoản Quản trị cấp cao (Toàn quyền quản lý)',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'CHỨC NĂNG QUẢN LÝ HỆ THỐNG',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildAdminCard(
                    context,
                    title: 'Quản Lý Lớp Học',
                    subtitle: 'Thêm, Sửa, Xóa lớp & môn',
                    icon: Icons.class_outlined,
                    color: Colors.blue.shade700,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrudClassScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAdminCard(
                    context,
                    title: 'Quản Lý Sinh Viên',
                    subtitle: 'MSSV, Hồ sơ, Tìm kiếm',
                    icon: Icons.people_alt_outlined,
                    color: Colors.teal.shade700,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CrudStudentScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildAdminCard(
                    context,
                    title: 'Báo Cáo Chuyên Cần',
                    subtitle: 'Thống kê tỷ lệ có mặt/vắng',
                    icon: Icons.bar_chart,
                    color: Colors.purple.shade700,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SummaryScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAdminCard(
                    context,
                    title: 'Duyệt Đơn Nghỉ Phép',
                    subtitle: 'Xét duyệt đơn xin nghỉ',
                    icon: Icons.assignment_turned_in,
                    color: Colors.amber.shade800,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LeaveRequestScreen(lopId: 1, isLecturer: true)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng quan dữ liệu toàn hệ thống', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Divider(height: 20),
                    _buildStatRow('Môn học đang quản lý:', 'LTDD01 (Lập trình di động), CSDL02'),
                    _buildStatRow('Tổng số sinh viên:', '4 sinh viên'),
                    _buildStatRow('Trạng thái kết nối API:', 'Đang hoạt động'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
