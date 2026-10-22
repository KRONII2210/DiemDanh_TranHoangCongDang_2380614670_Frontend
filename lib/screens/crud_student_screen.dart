import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/api_service.dart';

class CrudStudentScreen extends StatefulWidget {
  const CrudStudentScreen({Key? key}) : super(key: key);

  @override
  State<CrudStudentScreen> createState() => _CrudStudentScreenState();
}

class _CrudStudentScreenState extends State<CrudStudentScreen> {
  List<StudentModel> _students = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final list = await ApiService.instance.getStudents();
    setState(() {
      _students = list;
      _isLoading = false;
    });
  }

  Future<void> _showStudentDialog({StudentModel? existing}) async {
    final mssvCtrl = TextEditingController(text: existing?.mssv ?? '');
    final nameCtrl = TextEditingController(text: existing?.hoTen ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.soDienThoai ?? '');
    final isEdit = existing != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Sửa Thông Tin Sinh Viên' : 'Thêm Sinh Viên Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: mssvCtrl,
                decoration: const InputDecoration(labelText: 'Mã số sinh viên (MSSV)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Họ và tên sinh viên', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email sinh viên', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Số điện thoại', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
            child: Text(isEdit ? 'Lưu' : 'Thêm'),
            onPressed: () {
              if (mssvCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập MSSV và Họ tên!')));
                return;
              }
              Navigator.pop(ctx, true);
            },
          ),
        ],
      ),
    );

    if (result == true) {
      if (isEdit) {
        existing.mssv = mssvCtrl.text.trim();
        existing.hoTen = nameCtrl.text.trim();
        existing.email = emailCtrl.text.trim();
        existing.soDienThoai = phoneCtrl.text.trim();
      } else {
        final newS = StudentModel(
          id: _students.length + 1,
          mssv: mssvCtrl.text.trim(),
          hoTen: nameCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          soDienThoai: phoneCtrl.text.trim(),
          gioiTinh: 'Nam',
          ngaySinh: '2004-01-01',
        );
        await ApiService.instance.addStudent(newS);
      }
      _loadStudents();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Đã cập nhật sinh viên!' : 'Đã thêm sinh viên mới!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _deleteStudent(StudentModel s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa sinh viên?'),
        content: Text('Bạn có chắc chắn muốn xóa sinh viên ${s.hoTen} (${s.mssv}) không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xóa'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.instance.deleteStudent(s.id);
      _loadStudents();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa sinh viên ${s.mssv}!'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _students.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.mssv.toLowerCase().contains(q) || s.hoTen.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Sinh Viên (CRUD)'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm SV'),
        onPressed: () => _showStudentDialog(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Tìm kiếm MSSV, họ tên...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Không tìm thấy sinh viên nào.'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            final isAuthor = s.mssv == '2380614670';

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: isAuthor ? BorderSide(color: Colors.teal.shade500, width: 1.5) : BorderSide.none,
                              ),
                              elevation: isAuthor ? 3 : 1,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isAuthor ? Colors.teal.shade700 : Colors.teal.shade50,
                                  foregroundColor: isAuthor ? Colors.white : Colors.teal.shade800,
                                  child: const Icon(Icons.person),
                                ),
                                title: Row(
                                  children: [
                                    Text(s.hoTen, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if (isAuthor) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('Nhóm TSV', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text('MSSV: ${s.mssv} | SĐT: ${s.soDienThoai ?? "N/A"}\nEmail: ${s.email}', style: const TextStyle(fontSize: 12)),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showStudentDialog(existing: s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteStudent(s),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
