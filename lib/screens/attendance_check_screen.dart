import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';

class AttendanceCheckScreen extends StatefulWidget {
  final SessionModel session;
  final int lopId;

  const AttendanceCheckScreen({
    Key? key,
    required this.session,
    required this.lopId,
  }) : super(key: key);

  @override
  State<AttendanceCheckScreen> createState() => _AttendanceCheckScreenState();
}

class _AttendanceCheckScreenState extends State<AttendanceCheckScreen> {
  List<StudentModel> _students = [];
  final Map<int, String> _statuses = {}; // studentId -> 'PRESENT' | 'LATE' | 'ABSENT'
  final Map<int, TextEditingController> _notes = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    for (var c in _notes.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final list = await ApiService.instance.getStudents(lopId: widget.lopId);
    for (var s in list) {
      _statuses[s.id] = 'PRESENT';
      _notes[s.id] = TextEditingController();
    }
    setState(() {
      _students = list;
      _isLoading = false;
    });
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);
    final batch = _students.map((s) {
      return {
        'sinhVienId': s.id,
        'trangThai': _statuses[s.id] ?? 'PRESENT',
        'ghiChu': _notes[s.id]?.text ?? '',
      };
    }).toList();

    await ApiService.instance.saveAttendanceBatch(widget.session.id, batch);
    setState(() => _isSaving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu điểm danh thành công cho buổi: ${widget.session.tenBuoiHoc}!'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _markAll(String status) {
    setState(() {
      for (var s in _students) {
        _statuses[s.id] = status;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int countPresent = _statuses.values.where((v) => v == 'PRESENT').length;
    int countLate = _statuses.values.where((v) => v == 'LATE').length;
    int countAbsent = _statuses.values.where((v) => v == 'ABSENT').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.tenBuoiHoc),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Đánh dấu tất cả có mặt',
            onPressed: () => _markAll('PRESENT'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Session summary banner
                Container(
                  color: Colors.teal.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCountBadge('Sĩ số: ${_students.length}', Colors.black87),
                      _buildCountBadge('Có mặt: $countPresent', Colors.green.shade800),
                      _buildCountBadge('Đi trễ: $countLate', Colors.orange.shade800),
                      _buildCountBadge('Vắng: $countAbsent', Colors.red.shade800),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = _students[index];
                      final currentStatus = _statuses[s.id] ?? 'PRESENT';
                      final isSpecialStudent = s.mssv == '2380614670';

                      return Card(
                        elevation: isSpecialStudent ? 3 : 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: isSpecialStudent ? BorderSide(color: Colors.teal.shade400, width: 1.5) : BorderSide.none,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isSpecialStudent ? Colors.teal.shade700 : Colors.grey.shade300,
                                    foregroundColor: isSpecialStudent ? Colors.white : Colors.black87,
                                    child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(s.hoTen, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            if (isSpecialStudent) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: BorderRadius.circular(4)),
                                                child: const Text('Tác giả', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text('MSSV: ${s.mssv} | ${s.email}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatusBtn(
                                      title: 'Có mặt',
                                      color: Colors.green,
                                      isSelected: currentStatus == 'PRESENT',
                                      onTap: () => setState(() => _statuses[s.id] = 'PRESENT'),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildStatusBtn(
                                      title: 'Đi trễ',
                                      color: Colors.orange,
                                      isSelected: currentStatus == 'LATE',
                                      onTap: () => setState(() => _statuses[s.id] = 'LATE'),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _buildStatusBtn(
                                      title: 'Vắng',
                                      color: Colors.red,
                                      isSelected: currentStatus == 'ABSENT',
                                      onTap: () => setState(() => _statuses[s.id] = 'ABSENT'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, -2))],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Đang lưu...' : 'LƯU KẾT QUẢ ĐIỂM DANH', style: const TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _isSaving ? null : _saveAttendance,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCountBadge(String text, Color color) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color));
  }

  Widget _buildStatusBtn({
    required String title,
    required MaterialColor color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.shade600 : color.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? color.shade700 : color.shade200),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color.shade800,
          ),
        ),
      ),
    );
  }
}
