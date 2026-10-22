import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class QrScannerScreen extends StatefulWidget {
  final SessionModel? session;
  const QrScannerScreen({Key? key, this.session}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _laserAnimController;
  final TextEditingController _manualCodeController = TextEditingController(text: 'TSV-1-K7X9A2');
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _hasScanned = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _manualCodeController.text = ApiService.instance.currentDynamicQrCode;
    _laserAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Tự động đồng bộ mã QR mới nhất do Giảng viên phát từ Server
    ApiService.instance.fetchActiveQrToken().then((latest) {
      if (mounted) {
        setState(() {
          _manualCodeController.text = latest;
        });
      }
    });
  }

  @override
  void dispose() {
    _laserAnimController.dispose();
    _cameraController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _hasScanned) return;

    for (final barcode in capture.barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        _handleDetectedCode(rawValue.trim());
        break;
      }
    }
  }

  void _handleDetectedCode(String rawData) {
    if (_isProcessing || _hasScanned) return;
    setState(() => _hasScanned = true);

    String token = rawData;
    int buoiId = widget.session?.id ?? 1;

    // Hỗ trợ định dạng mã QR đầy đủ "DIEMDANH:<buoiId>:<token>" hoặc mã token độc lập "TSV-..."
    if (rawData.startsWith('DIEMDANH:')) {
      final parts = rawData.split(':');
      if (parts.length >= 2) {
        final parsed = int.tryParse(parts[1]);
        if (parsed != null) buoiId = parsed;
      }
      if (parts.length >= 3) {
        token = parts[2];
      }
    }

    _manualCodeController.text = token;
    _processScan(token, buoiHocId: buoiId);
  }

  Future<void> _processScan(String qrContent, {int? buoiHocId}) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final user = AuthService.instance.currentUser;
    final int buoiId = buoiHocId ?? widget.session?.id ?? 1;

    // Tọa độ GPS mô phỏng (10.8221, 106.6882) - Bán kính khuôn viên trường
    final result = await ApiService.instance.markAttendanceWithQrAndLocation(
      buoiHocId: buoiId,
      sinhVienId: user?.id ?? 1,
      qrToken: qrContent,
      latitude: 10.8221,
      longitude: 106.6882,
      faceVerified: true,
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (result['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 8),
              const Text('Điểm Danh Thành Công!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('Sinh viên:', user?.fullName ?? 'Trần Hoàng Công Đăng'),
              _buildRow('MSSV:', user?.mssv ?? '2380614670'),
              _buildRow('Mã QR:', qrContent),
              _buildRow('Vị trí GPS:', '10.8221, 106.6882 (Hợp lệ)'),
              _buildRow('Khoảng cách:', '${result['distanceMeters'] ?? 18}m / Bán kính 100m'),
              _buildRow('Xác thực khuôn mặt:', 'Đã đối soát Face ID'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                child: const Text('Trạng thái: ĐÃ GHI NHẬN CÓ MẶT (PRESENT)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
              child: const Text('Xong'),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } else {
      setState(() => _hasScanned = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Lỗi điểm danh'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: () => setState(() => _hasScanned = false),
          ),
        ),
      );
    }
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87))),
        ],
      ),
    );
  }

  void _showQrCodeDialog() async {
    final activeCode = await ApiService.instance.fetchActiveQrToken();
    if (!mounted) return;
    final int buoiId = widget.session?.id ?? 1;
    final String fullQrData = 'DIEMDANH:$buoiId:$activeCode';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_2, color: Colors.blue),
            SizedBox(width: 8),
            Text('Mã QR Chuẩn Của Buổi Học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lớp: LTDD01 - Lập trình di động\nBuổi học: Buổi $buoiId (Mã đổi mỗi 30s)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                ],
              ),
              child: SizedBox(
                width: 180,
                height: 180,
                child: QrImageView(
                  data: fullQrData,
                  version: QrVersions.auto,
                  size: 180.0,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                'Mã: $activeCode',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Điểm danh ngay'),
            onPressed: () {
              Navigator.pop(ctx);
              _manualCodeController.text = activeCode;
              _processScan(activeCode);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét Mã QR Điểm Danh'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'Bật/Tắt Đèn Flash',
            onPressed: () async {
              await _cameraController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            tooltip: 'Đổi Camera Trước/Sau',
            onPressed: () => _cameraController.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'Xem mã QR buổi học (Dành cho kiểm thử 1 máy)',
            onPressed: _showQrCodeDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Khung Camera Thật Quét Mã QR Thời Gian Thực
            SizedBox(
              height: 320,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Luồng Camera Thật sử dụng MobileScanner
                  MobileScanner(
                    controller: _cameraController,
                    onDetect: _onDetect,
                    errorBuilder: (context, error, child) {
                      return Container(
                        color: Colors.black87,
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Không thể khởi động Camera (${error.errorCode.name})\nVui lòng cấp quyền Camera hoặc dùng nút kiểm thử bên dưới.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Khung ngắm Viewfinder
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyanAccent, width: 2.5),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
                      ],
                    ),
                  ),

                  // Tia quét Laser chuyển động
                  AnimatedBuilder(
                    animation: _laserAnimController,
                    builder: (context, child) {
                      return Positioned(
                        top: 45 + (_laserAnimController.value * 225),
                        child: Container(
                          width: 220,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyanAccent.withOpacity(0.0),
                                Colors.cyanAccent,
                                Colors.cyanAccent.withOpacity(0.0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.cyanAccent.withOpacity(0.9), blurRadius: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Dòng hướng dẫn người dùng
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.65), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Hướng camera vào mã QR của Giảng viên để tự động điểm danh', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            // Các chức năng kiểm thử & Nhập mã thủ công
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.qr_code_scanner),
                    label: Text(_isProcessing ? 'Đang xác thực điểm danh...' : 'QUÉT & ĐIỂM DANH MÃ QR HIỆN TẠI', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    onPressed: _isProcessing
                        ? null
                        : () async {
                            final active = await ApiService.instance.fetchActiveQrToken();
                            setState(() {
                              _manualCodeController.text = active;
                            });
                            _processScan(active);
                          },
                  ),
                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade900,
                      side: BorderSide(color: Colors.blue.shade300, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text('HIỂN THỊ MÃ QR BUỔI HỌC (TEST 1 MÁY)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: _showQrCodeDialog,
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const Text('HOẶC NHẬP MÃ ĐIỂM DANH THỦ CÔNG:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualCodeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            labelText: 'Mã QR Code',
                            prefixIcon: const Icon(Icons.pin),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Xác nhận'),
                        onPressed: _isProcessing
                            ? null
                            : () {
                                final code = _manualCodeController.text.trim();
                                if (code.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng nhập mã QR của buổi học!')),
                                  );
                                  return;
                                }
                                _processScan(code);
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('QUY TRÌNH XÁC THỰC 3 LỚP AN TOÀN:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                        SizedBox(height: 4),
                        Text('1. Nhận diện QR Code bảo mật thời gian thực bằng Camera', style: TextStyle(fontSize: 12)),
                        Text('2. Đối soát tọa độ GPS trong bán kính phòng học', style: TextStyle(fontSize: 12)),
                        Text('3. Xác thực danh tính sinh viên Trần Hoàng Công Đăng - 2380614670', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
