import 'dart:math';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class GpsGeofenceScreen extends StatefulWidget {
  const GpsGeofenceScreen({Key? key}) : super(key: key);

  @override
  State<GpsGeofenceScreen> createState() => _GpsGeofenceScreenState();
}

class _GpsGeofenceScreenState extends State<GpsGeofenceScreen> {
  // Coordinates of Classroom
  static const double classLat = 10.82200;
  static const double classLng = 106.68800;
  static const double maxRadiusMeters = 100.0;

  // Student's simulated GPS position (Default inside classroom: 18m away)
  double studentLat = 10.82210;
  double studentLng = 106.68815;

  bool _isSubmitting = false;

  // Haversine formula to calculate distance in meters
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  void _setAtClassroom() {
    setState(() {
      studentLat = 10.82210;
      studentLng = 106.68815;
    });
  }

  void _setAtHome() {
    setState(() {
      studentLat = 10.83500;
      studentLng = 106.70200;
    });
  }

  Future<void> _submitAttendance() async {
    final distance = _calculateDistance(studentLat, studentLng, classLat, classLng);
    if (distance > maxRadiusMeters) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Ngoài Bán Kính!'),
            ],
          ),
          content: Text(
            'Khoảng cách của bạn đến lớp là ${distance.toStringAsFixed(1)}m, vượt quá bán kính quy định ($maxRadiusMeters m).\nKhông thể điểm danh!',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đã hiểu')),
          ],
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = AuthService.instance.currentUser;

    await ApiService.instance.markAttendanceWithQrAndLocation(
      buoiHocId: 1,
      sinhVienId: user?.id ?? 1,
      qrToken: 'GPS-DIRECT-CHECKIN',
      latitude: studentLat,
      longitude: studentLng,
      faceVerified: true,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('Điểm Danh GPS Thành Công!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sinh viên: ${user?.fullName ?? "Trần Hoàng Công Đăng"}'),
            Text('MSSV: ${user?.mssv ?? "2380614670"}'),
            const SizedBox(height: 6),
            Text('Khoảng cách đến phòng: ${distance.toStringAsFixed(1)}m (Hợp lệ < $maxRadiusMeters m)'),
            Text('Tọa độ gửi: ${studentLat.toStringAsFixed(5)}, ${studentLng.toStringAsFixed(5)}'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
            child: const Text('Đóng'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distance = _calculateDistance(studentLat, studentLng, classLat, classLng);
    final isInside = distance <= maxRadiusMeters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chia Sẻ Vị Trí & Radar GPS'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isInside ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isInside ? Colors.green.shade400 : Colors.red.shade400),
              ),
              child: Row(
                children: [
                  Icon(
                    isInside ? Icons.location_on : Icons.location_off,
                    color: isInside ? Colors.green.shade800 : Colors.red.shade800,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isInside ? 'TRONG VÙNG ĐIỂM DANH HỢP LỆ' : 'NGOÀI VÙNG ĐIỂM DANH',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isInside ? Colors.green.shade900 : Colors.red.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Khoảng cách: ${distance.toStringAsFixed(1)}m (Bán kính tối đa: ${maxRadiusMeters.toInt()}m)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual Radar / Geofence Canvas
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF101820),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: CustomPaint(
                painter: _GeofenceRadarPainter(
                  distanceMeters: distance,
                  maxRadius: maxRadiusMeters,
                  isInside: isInside,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Demo Location Toggle for Presentation
            const Text('CHẾ ĐỘ MÔ PHỎNG VỊ TRÍ ĐỂ THUYẾT TRÌNH:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.school, size: 18),
                    label: const Text('Tại Giảng Đường (18m)', style: TextStyle(fontSize: 11)),
                    onPressed: _setAtClassroom,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.home, size: 18),
                    label: const Text('Ở Nhà / Xa Trường (>1km)', style: TextStyle(fontSize: 11)),
                    onPressed: _setAtHome,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Coordinates details
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    _buildCoordRow('Tọa độ phòng học:', '$classLat, $classLng'),
                    const Divider(height: 16),
                    _buildCoordRow('Tọa độ thiết bị bạn:', '${studentLat.toStringAsFixed(5)}, ${studentLng.toStringAsFixed(5)}'),
                    const Divider(height: 16),
                    _buildCoordRow('Sinh viên đại diện:', 'Trần Hoàng Công Đăng - 2380614670'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInside ? Colors.red.shade800 : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: Text(
                  _isSubmitting ? 'Đang gửi...' : 'XÁC THỰC VỊ TRÍ & ĐIỂM DANH GPS',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _isSubmitting ? null : _submitAttendance,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}

class _GeofenceRadarPainter extends CustomPainter {
  final double distanceMeters;
  final double maxRadius;
  final bool isInside;

  _GeofenceRadarPainter({
    required this.distanceMeters,
    required this.maxRadius,
    required this.isInside,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Grid concentric circles
    final gridPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, 40, gridPaint);
    canvas.drawCircle(center, 70, gridPaint);
    canvas.drawCircle(center, 100, gridPaint);

    // Crosshairs
    canvas.drawLine(Offset(center.dx, 10), Offset(center.dx, size.height - 10), gridPaint);
    canvas.drawLine(Offset(10, center.dy), Offset(size.width - 10, center.dy), gridPaint);

    // Geofence Safe Radius (70px represents maxRadius = 100m)
    const geofenceVisualRadius = 70.0;
    final geofencePaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final geofenceStroke = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, geofenceVisualRadius, geofencePaint);
    canvas.drawCircle(center, geofenceVisualRadius, geofenceStroke);

    // Center classroom pin
    final classPaint = Paint()..color = Colors.blueAccent;
    canvas.drawCircle(center, 7, classPaint);

    // Student position dot
    double ratio = distanceMeters / maxRadius;
    if (ratio > 1.5) ratio = 1.5;
    double pixelDist = ratio * geofenceVisualRadius;

    // Angle fixed at 45 degrees for visualization
    const angle = pi / 4;
    final studentPos = Offset(
      center.dx + pixelDist * cos(angle),
      center.dy - pixelDist * sin(angle),
    );

    final studentPaint = Paint()..color = isInside ? Colors.amberAccent : Colors.redAccent;
    canvas.drawCircle(studentPos, 9, studentPaint);

    // Pulse ring around student
    final studentRing = Paint()
      ..color = (isInside ? Colors.amberAccent : Colors.redAccent).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(studentPos, 14, studentRing);
  }

  @override
  bool shouldRepaint(covariant _GeofenceRadarPainter oldDelegate) {
    return oldDelegate.distanceMeters != distanceMeters || oldDelegate.isInside != isInside;
  }
}
