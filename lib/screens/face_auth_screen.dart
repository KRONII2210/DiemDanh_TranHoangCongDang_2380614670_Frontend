import 'dart:async';
import 'package:flutter/material.dart';

class FaceAuthScreen extends StatefulWidget {
  final String studentName;
  final String mssv;
  final VoidCallback onVerified;

  const FaceAuthScreen({
    Key? key,
    required this.studentName,
    required this.mssv,
    required this.onVerified,
  }) : super(key: key);

  @override
  State<FaceAuthScreen> createState() => _FaceAuthScreenState();
}

class _FaceAuthScreenState extends State<FaceAuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _statusText = 'Đang căn chỉnh khuôn mặt vào khung tròn...';
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _runFaceAuthSequence();
  }

  void _runFaceAuthSequence() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _statusText = 'Đang nhận diện các điểm đặc trưng sinh trắc học...');
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _statusText = 'Đang đối soát khuôn mặt: ${widget.studentName}...');
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _statusText = 'Xác thực thành công! Độ khớp 99.8%';
        _isSuccess = true;
      });
      _controller.stop();
      await Future.delayed(const Duration(milliseconds: 700));
      widget.onVerified();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhận Diện Khuôn Mặt (Face ID)'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.studentName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'MSSV: ${widget.mssv} | Nhóm TSV',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 36),

              Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: _controller,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isSuccess ? Colors.greenAccent : Colors.tealAccent,
                          width: 3,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white10,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: Icon(
                      _isSuccess ? Icons.check_circle_outline : Icons.face_rounded,
                      size: 110,
                      color: _isSuccess ? Colors.greenAccent : Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _statusText,
                  style: TextStyle(
                    color: _isSuccess ? Colors.greenAccent : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              if (!_isSuccess)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Bấm Xác Thực Ngay (Demo)'),
                  onPressed: () {
                    widget.onVerified();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
