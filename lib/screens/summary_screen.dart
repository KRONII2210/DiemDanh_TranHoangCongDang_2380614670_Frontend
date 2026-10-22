import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../services/api_service.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final classes = await ApiService.instance.getClasses();
    ClassModel? defaultClass = classes.isNotEmpty ? classes.first : null;
    Map<String, dynamic>? stats;
    if (defaultClass != null) {
      stats = await ApiService.instance.getStatistics(defaultClass.id);
    }
    setState(() {
      _classes = classes;
      _selectedClass = defaultClass;
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _onClassChanged(ClassModel? c) async {
    if (c == null) return;
    setState(() => _isLoading = true);
    final stats = await ApiService.instance.getStatistics(c.id);
    setState(() {
      _selectedClass = c;
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Chuyên Cần & Cấm Thi'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Class Selector Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ClassModel>(
                        value: _selectedClass,
                        isExpanded: true,
                        items: _classes.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text('${c.maLop} - ${c.tenLop}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: _onClassChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Overall Stats Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade800, Colors.deepPurple.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('TỶ LỆ CHUYÊN CẦN TOÀN LỚP', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          '${_stats?['tyLeCoMatPhanTram'] ?? 80.0}%',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniStat('Sĩ số', '${_stats?['tongSinhVien'] ?? 4} SV'),
                            _buildMiniStat('Số buổi', '${_stats?['tongBuoiHoc'] ?? 3} buổi'),
                            _buildMiniStat('Có mặt', '${_stats?['tongCoMat'] ?? 3} lượt'),
                            _buildMiniStat('Vắng', '${_stats?['tongVangKhongPhep'] ?? 1} lượt'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Warning Notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 26),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sinh viên vắng từ 20% trở lên (quá 3 buổi/15 buổi) sẽ bị cảnh báo đỏ và chuyển danh sách cấm thi cuối kỳ.',
                            style: TextStyle(fontSize: 12, color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('DANH SÁCH SINH VIÊN & NGUY CƠ CẤM THI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
                  const SizedBox(height: 10),

                  // Sample student list with warning badges
                  _buildStudentRow(
                    name: 'Trần Hoàng Công Đăng',
                    mssv: '2380614670',
                    absentCount: 0,
                    totalCount: 15,
                    isSpecial: true,
                  ),
                  _buildStudentRow(
                    name: 'Đỗ Đăng Khoa',
                    mssv: '2380614683',
                    absentCount: 1,
                    totalCount: 15,
                  ),
                  _buildStudentRow(
                    name: 'Trần Thị An',
                    mssv: '2380000001',
                    absentCount: 2,
                    totalCount: 15,
                  ),
                  _buildStudentRow(
                    name: 'Lê Văn Bình',
                    mssv: '2380000002',
                    absentCount: 4,
                    totalCount: 15,
                    isBanned: true,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildStudentRow({
    required String name,
    required String mssv,
    required int absentCount,
    required int totalCount,
    bool isSpecial = false,
    bool isBanned = false,
  }) {
    final double percent = (absentCount / totalCount) * 100;
    final bool danger = percent >= 20.0 || isBanned;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSpecial ? BorderSide(color: Colors.purple.shade400, width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: danger ? Colors.red.shade100 : Colors.green.shade100,
          child: Icon(
            danger ? Icons.error_outline : Icons.check_circle_outline,
            color: danger ? Colors.red : Colors.green,
          ),
        ),
        title: Row(
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            if (isSpecial) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(4)),
                child: const Text('Nhóm TSV', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple)),
              ),
            ],
          ],
        ),
        subtitle: Text('MSSV: $mssv | Vắng: $absentCount/$totalCount buổi (${percent.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: danger ? Colors.red.shade100 : Colors.green.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            danger ? 'CẢNH BÁO CẤM THI' : 'AN TOÀN',
            style: TextStyle(
              color: danger ? Colors.red.shade900 : Colors.green.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
