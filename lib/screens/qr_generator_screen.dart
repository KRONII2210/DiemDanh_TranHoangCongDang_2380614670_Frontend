import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';

class QrGeneratorScreen extends StatefulWidget {
  final SessionModel session;
  final String className;

  const QrGeneratorScreen({
    Key? key,
    required this.session,
    required this.className,
  }) : super(key: key);

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  late String _currentToken;
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateNewToken();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateNewToken() {
    final rand = Random();
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code = List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
    final token = 'TSV-${widget.session.id}-$code';
    ApiService.instance.broadcastNewQrToken(token); // Đồng bộ mã QR động lên Server/API
    setState(() {
      _currentToken = token;
      _secondsRemaining = 30;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        _generateNewToken();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final qrData = 'DIEMDANH:${widget.session.id}:$_currentToken';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mã QR Điểm Danh Động'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'LỚP: ${widget.className} | ${widget.session.tenBuoiHoc}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue.shade900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Chiếu màn hình này lên máy chiếu để sinh viên quét trực tiếp từ app.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
                ],
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Column(
                children: [
                  // QR Matrix Chuẩn Quốc Tế ISO (Máy quét camera nhận diện ngay)
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 240.0,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0D47A1),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      'MÃ: $_currentToken',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Countdown Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: _secondsRemaining / 30.0,
                        strokeWidth: 5,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _secondsRemaining > 10 ? Colors.blue.shade700 : Colors.red,
                        ),
                      ),
                    ),
                    Text(
                      '$_secondsRemaining s',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _secondsRemaining > 10 ? Colors.blue.shade900 : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mã QR tự động đổi sau mỗi 30s', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Chống chụp hình gửi điểm danh hộ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('LÀM MỚI MÃ QR NGAY', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _generateNewToken,
            ),
            const SizedBox(height: 24),

            // Student submission proof note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: Colors.orange, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Đồ án môn học: Điểm danh sinh viên\nTác giả: Trần Hoàng Công Đăng - MSSV: 2380614670 (Nhóm TSV)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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


