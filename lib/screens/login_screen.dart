import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/server_config_dialog.dart';
import 'register_screen.dart';
import 'face_auth_screen.dart';
import 'admin_dashboard_screen.dart';
import 'lecturer_dashboard_screen.dart';
import 'student_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'sv_dang');
  final _passwordController = TextEditingController(text: 'Sv@12345');
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showOtpStep = false;
  String? _tempRole;
  String? _tempFullName;
  String? _tempMssv;
  String? _generatedOtpDemo;

  void _navigateToRoleDashboard(UserModel user) {
    AuthService.instance.setCurrentUser(user);
    Widget nextScreen;
    if (user.isAdmin) {
      nextScreen = const AdminDashboardScreen();
    } else if (user.isLecturer) {
      nextScreen = const LecturerDashboardScreen();
    } else {
      nextScreen = const StudentDashboardScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  Future<void> _handleLoginStep1() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên đăng nhập và mật khẩu!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.instance.login(username, password);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      if (res['requiresOtp'] == true) {
        final newOtp = res['tempOtpToken']?.toString() ?? '123456';
        setState(() {
          _showOtpStep = true;
          _generatedOtpDemo = newOtp;
          _tempRole = res['role'];
          _tempFullName = res['fullName'];
          _tempMssv = res['mssv'];
          _otpController.text = newOtp; // Điền sẵn mã ngẫu nhiên vừa sinh
        });
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.mark_email_read, color: Colors.indigo),
                SizedBox(width: 8),
                Text('Mã Xác Thực OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tài khoản: $username', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.indigo.shade300),
                  ),
                  child: Text(
                    newOtp,
                    style: const TextStyle(fontSize: 28, letterSpacing: 6, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Mã xác thực OTP có hiệu lực trong 5 phút. Vui lòng nhập mã để hoàn tất đăng nhập an toàn.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Nhập Mã & Tiếp Tục'),
              ),
            ],
          ),
        );
      } else {
        final user = UserModel.fromJson(res);
        _navigateToRoleDashboard(user);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(res['message'] ?? 'Đăng nhập thất bại!')),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final username = _usernameController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã OTP 6 số!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.instance.verifyOtp(
      username,
      otp,
      role: _tempRole,
      fullName: _tempFullName,
      mssv: _tempMssv,
    );
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      final user = UserModel.fromJson(res);
      _navigateToRoleDashboard(user);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(res['message'] ?? 'Xác thực OTP thất bại!')),
      );
    }
  }

  void _quickFill(String username, String pass, String roleName) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = pass;
      _showOtpStep = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã chọn tài khoản: $username ($roleName)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Nhập Hệ Thống'),
        actions: [
          IconButton(
            tooltip: 'Cấu hình link Web API chung nhóm TSV',
            icon: const Icon(Icons.settings_ethernet),
            onPressed: () => ServerConfigDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Logo
              Center(
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.indigo, width: 2),
                  ),
                  child: const Icon(Icons.school_rounded, size: 48, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'APP ĐIỂM DANH SINH VIÊN',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
              const Center(
                child: Text(
                  'Nhóm: TSV  |  SV: Trần Hoàng Công Đăng (2380614670)',
                  style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),

              // BƯỚC 1: NHẬP TÊN ĐĂNG NHẬP & MẬT KHẨU
              if (!_showOtpStep) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập hoặc Email',
                    hintText: 'sv_dang / gv_khoa / admin',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _handleLoginStep1,
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.arrow_forward),
                  label: const Text('Tiếp Tục (Xác Thực OTP)', style: TextStyle(fontSize: 16)),
                ),
              ] else ...[
                // BƯỚC 2: NHẬP MÃ OTP 6 CHỮ SỐ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.mark_email_read_outlined, size: 36, color: Colors.indigo),
                      const SizedBox(height: 6),
                      const Text(
                        'Xác Thực 2 Bước (OTP)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mã xác thực đã được gửi về email của bạn. Nhập mã OTP 6 số để tiếp tục.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      if (_generatedOtpDemo != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade400),
                          ),
                          child: Text(
                            'Mã OTP của bạn: $_generatedOtpDemo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown.shade900),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '(Mã bảo mật gửi đến email đăng ký của bạn)',
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Nhập mã OTP 6 số',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.security),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _handleVerifyOtp,
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Xác Nhận & Đăng Nhập', style: TextStyle(fontSize: 16)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Đổi mã OTP mới'),
                      onPressed: _isLoading ? null : _handleLoginStep1,
                    ),
                    const Text(' | ', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () => setState(() => _showOtpStep = false),
                      child: const Text('Quay lại đăng nhập'),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // CHỨC NĂNG 5A: ĐĂNG NHẬP NHANH BẰNG KHUÔN MẶT (FACE ID)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal.shade800,
                  side: BorderSide(color: Colors.teal.shade400, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.face_retouching_natural, color: Colors.teal),
                label: const Text('Đăng Nhập Bằng Khuôn Mặt (Face ID)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FaceAuthScreen(
                        studentName: 'Trần Hoàng Công Đăng',
                        mssv: '2380614670',
                        onVerified: () {
                          Navigator.pop(context);
                          _navigateToRoleDashboard(UserModel(
                            id: 1,
                            username: 'sv_dang',
                            email: 'dang.thc@diemdanh.local',
                            fullName: 'Trần Hoàng Công Đăng (Face ID)',
                            role: 'SINH_VIEN',
                            mssv: '2380614670',
                          ));
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ĐIỀU HƯỚNG ĐĂNG KÝ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Đăng ký qua Email',
                      style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Gợi ý đăng nhập nhanh các vai trò
              const Divider(),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Chọn nhanh vai trò đăng nhập:',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.admin_panel_settings, size: 16, color: Colors.red),
                    label: const Text('Admin', style: TextStyle(fontSize: 11)),
                    onPressed: () => _quickFill('admin', 'Admin@123', 'Quản trị viên'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.assignment_ind, size: 16, color: Colors.blue),
                    label: const Text('Giảng viên (gv_khoa)', style: TextStyle(fontSize: 11)),
                    onPressed: () => _quickFill('gv_khoa', 'Gv@12345', 'Giảng viên'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.person, size: 16, color: Colors.green),
                    label: const Text('SV Trần Hoàng Công Đăng', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => _quickFill('sv_dang', 'Sv@12345', 'Sinh viên Đăng - TSV'),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.person_outline, size: 16, color: Colors.teal),
                    label: const Text('SV Đỗ Đăng Khoa', style: TextStyle(fontSize: 11)),
                    onPressed: () => _quickFill('sv_khoa', 'Sv@12345', 'Sinh viên Khoa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
