import 'package:flutter/material.dart';
import '../services/api_config.dart';

class ServerConfigDialog extends StatefulWidget {
  const ServerConfigDialog({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const ServerConfigDialog(),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ApiConfig.currentBaseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.cloud_sync, color: Colors.indigo),
          SizedBox(width: 8),
          Expanded(child: Text('Cấu hình API Nhóm TSV', style: TextStyle(fontSize: 18))),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập đường link Web API dùng chung của nhóm bạn vào đây:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Base URL Web API',
                hintText: 'http://10.0.2.2:5080/api',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Gợi ý kết nối nhanh:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Wrap(
              spacing: 6,
              children: [
                ActionChip(
                  label: const Text('Máy ảo Android (10.0.2.2:5080)'),
                  onPressed: () {
                    _controller.text = 'http://10.0.2.2:5080/api';
                  },
                ),
                ActionChip(
                  label: const Text('Máy tính (localhost:5080)'),
                  onPressed: () {
                    _controller.text = 'http://localhost:5080/api';
                  },
                ),
                ActionChip(
                  label: const Text('Chế độ Demo / Mock Data'),
                  onPressed: () {
                    _controller.text = 'http://mock-offline.tsv/api';
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 Mẹo: Nếu Web API của nhóm chưa chạy, ứng dụng sẽ tự động chuyển sang chế độ Demo để bài thuyết trình diễn ra trơn tru 100%.',
                style: TextStyle(fontSize: 12, color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            ApiConfig.setCustomUrl(_controller.text.trim());
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã cập nhật URL API: ${ApiConfig.currentBaseUrl}')),
            );
          },
          child: const Text('Lưu cấu hình'),
        ),
      ],
    );
  }
}
