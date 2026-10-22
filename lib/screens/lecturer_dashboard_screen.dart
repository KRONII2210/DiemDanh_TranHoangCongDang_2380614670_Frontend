import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/server_config_dialog.dart';
import 'login_screen.dart';
import 'attendance_check_screen.dart';
import 'qr_generator_screen.dart';
import 'gps_geofence_screen.dart';
import 'leave_request_screen.dart';
import 'summary_screen.dart';
import 'about_screen.dart';

class LecturerDashboardScreen extends StatefulWidget {
  const LecturerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<LecturerDashboardScreen> createState() => _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState extends State<LecturerDashboardScreen> {
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  List<SessionModel> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final classes = await ApiService.instance.getClasses();
    ClassModel? defaultClass = classes.isNotEmpty ? classes.first : null;
    List<SessionModel> sessions = [];
    if (defaultClass != null) {
      sessions = await ApiService.instance.getSessions(defaultClass.id);
    }
    setState(() {
      _classes = classes;
      _selectedClass = defaultClass;
      _sessions = sessions;
      _isLoading = false;
    });
  }

  Future<void> _onClassChanged(ClassModel? newClass) async {
    if (newClass == null) return;
    setState(() {
      _selectedClass = newClass;
      _isLoading = true;
    });
    final sessions = await ApiService.instance.getSessions(newClass.id);
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  void _showAddSessionDialog() {
    final titleController = TextEditingController(text: 'Buổi ${_sessions.length + 1}: ');
    final tietController = TextEditingController(text: 'Tiết 1 - 3');
    final roomController = TextEditingController(text: 'E1-02.05');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Buổi Học Mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tên nội dung buổi học'),
            ),
            TextField(
              controller: tietController,
              decoration: const InputDecoration(labelText: 'Tiết học (VD: Tiết 1 - 3)'),
            ),
            TextField(
              controller: roomController,
              decoration: const InputDecoration(labelText: 'Phòng học (VD: E1-02.05)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;
              final newSession = SessionModel(
                id: 0,
                tenBuoiHoc: titleController.text.trim(),
                ngayHoc: DateTime.now().toString().substring(0, 10),
                tietHoc: tietController.text.trim(),
                phongHoc: roomController.text.trim(),
                lopHoc: _selectedClass,
              );
              await ApiService.instance.addSession(newSession);
              Navigator.pop(ctx);
              _onClassChanged(_selectedClass);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã tạo buổi học mới thành công!')),
              );
            },
            child: const Text('Tạo Buổi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Giảng Viên (Nhân viên)'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Cấu hình Web API nhóm TSV',
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
            onPressed: () {
              AuthService.instance.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade800, Colors.teal.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.assignment_ind, size: 32, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('GIẢNG VIÊN / NHÂN VIÊN ĐIỂM DANH', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(user?.fullName ?? 'GV. Nguyễn Văn Giảng', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              const Text('Nhóm TSV | SV: Trần Hoàng Công Đăng (2380614670)', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Icon(Icons.class_, color: Colors.teal),
                      const SizedBox(width: 8),
                      const Text('Chọn Lớp Phụ Trách:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const Spacer(),
                      DropdownButton<ClassModel>(
                        value: _selectedClass,
                        items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.maLop, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                        onChanged: _onClassChanged,
                      ),
                    ],
                  ),
                  if (_selectedClass != null) ...[
                    Text(
                      '${_selectedClass!.tenLop} - ${_selectedClass!.monHoc}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 16),

                  const Text('CÔNG CỤ THUYẾT TRÌNH & ĐIỂM DANH THÔNG MINH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.qr_code_2,
                          color: Colors.blue.shade700,
                          title: 'Tạo Mã QR Điểm Danh',
                          subtitle: 'Chiếu QR cho sinh viên quét',
                          onTap: () {
                            if (_sessions.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chưa có buổi học nào để tạo QR!')));
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QrGeneratorScreen(
                                  session: _sessions.first,
                                  className: _selectedClass?.maLop ?? 'LTDD01',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.share_location,
                          color: Colors.red.shade700,
                          title: 'Chia Sẻ Vị Trí (GPS)',
                          subtitle: 'Định vị bán kính phòng học',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GpsGeofenceScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.approval,
                          color: Colors.amber.shade800,
                          title: 'Duyệt Đơn Nghỉ Phép',
                          subtitle: 'Xét duyệt minh chứng y tế/lý do',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LeaveRequestScreen(
                                  lopId: _selectedClass?.id ?? 1,
                                  isLecturer: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.analytics,
                          color: Colors.purple.shade700,
                          title: 'Thống Kê & Cảnh Báo',
                          subtitle: 'Tỷ lệ % vắng, nguy cơ cấm thi',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SummaryScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('DANH SÁCH BUỔI HỌC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Thêm Buổi', style: TextStyle(fontSize: 12)),
                        onPressed: _showAddSessionDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_sessions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('Lớp này chưa có buổi học nào. Nhấn Thêm Buổi để bắt đầu!')),
                    )
                  else
                    ..._sessions.map((session) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade50,
                            child: Icon(Icons.calendar_month, color: Colors.teal.shade800),
                          ),
                          title: Text(session.tenBuoiHoc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('Ngày: ${session.ngayHoc} | ${session.tietHoc} | ${session.phongHoc}', style: const TextStyle(fontSize: 12)),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Điểm danh', style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AttendanceCheckScreen(
                                    session: session,
                                    lopId: _selectedClass?.id ?? 1,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
