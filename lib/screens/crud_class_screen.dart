import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../services/api_service.dart';

class CrudClassScreen extends StatefulWidget {
  const CrudClassScreen({Key? key}) : super(key: key);

  @override
  State<CrudClassScreen> createState() => _CrudClassScreenState();
}

class _CrudClassScreenState extends State<CrudClassScreen> {
  List<ClassModel> _classes = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    final list = await ApiService.instance.getClasses();
    setState(() {
      _classes = list;
      _isLoading = false;
    });
  }

  Future<void> _showClassDialog({ClassModel? existing}) async {
    final codeCtrl = TextEditingController(text: existing?.maLop ?? '');
    final nameCtrl = TextEditingController(text: existing?.tenLop ?? '');
    final termCtrl = TextEditingController(text: existing?.hocKy ?? 'Học kỳ 1 (2026-2027)');
    final lecturerCtrl = TextEditingController(text: existing?.giangVien ?? 'GV. Nguyễn Văn Giảng');

    final isEdit = existing != null;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Chỉnh Sửa Lớp Học' : 'Thêm Lớp Học Mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã Lớp (VD: LTDD01)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên Môn / Lớp Học', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: termCtrl,
                decoration: const InputDecoration(labelText: 'Học Kỳ', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lecturerCtrl,
                decoration: const InputDecoration(labelText: 'Giảng Viên Phụ Trách', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700, foregroundColor: Colors.white),
            child: Text(isEdit ? 'Cập Nhật' : 'Tạo Mới'),
            onPressed: () {
              if (codeCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')));
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
        existing.maLop = codeCtrl.text.trim();
        existing.tenLop = nameCtrl.text.trim();
        existing.hocKy = termCtrl.text.trim();
        existing.giangVien = lecturerCtrl.text.trim();
      } else {
        final newC = ClassModel(
          id: _classes.length + 1,
          maLop: codeCtrl.text.trim(),
          tenLop: nameCtrl.text.trim(),
          hocKy: termCtrl.text.trim(),
          monHoc: nameCtrl.text.trim(),
          giangVien: lecturerCtrl.text.trim(),
        );
        await ApiService.instance.addClass(newC);
      }
      _loadClasses();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Đã cập nhật lớp thành công!' : 'Đã thêm lớp học mới!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _deleteClass(ClassModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa lớp?'),
        content: Text('Bạn có chắc chắn muốn xóa lớp "${c.tenLop}" (${c.maLop}) không?'),
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
      await ApiService.instance.deleteClass(c.id);
      _loadClasses();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa lớp ${c.maLop}!'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _classes.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.maLop.toLowerCase().contains(q) || c.tenLop.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Lớp Học (CRUD)'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm Lớp'),
        onPressed: () => _showClassDialog(),
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
                      hintText: 'Tìm kiếm mã lớp, tên môn học...',
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
                      ? const Center(child: Text('Không tìm thấy lớp học nào.'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final c = filtered[index];
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade100,
                                  child: Icon(Icons.school, color: Colors.indigo.shade800),
                                ),
                                title: Text(c.tenLop, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Mã: ${c.maLop} | GV: ${c.giangVien}\n${c.hocKy}', style: const TextStyle(fontSize: 12)),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showClassDialog(existing: c),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteClass(c),
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
