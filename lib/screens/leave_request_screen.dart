import 'package:flutter/material.dart';
import '../models/leave_request_model.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  final int lopId;
  final bool isLecturer;

  const LeaveRequestScreen({
    Key? key,
    required this.lopId,
    this.isLecturer = false,
  }) : super(key: key);

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  List<LeaveRequestModel> _requests = [];
  List<SessionModel> _sessions = [];
  SessionModel? _selectedSession;
  final _reasonController = TextEditingController();
  String _proofUrl = 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=500';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final reqs = await ApiService.instance.getLeaveRequests(lopId: widget.lopId);
    final sessions = await ApiService.instance.getSessions(widget.lopId);
    setState(() {
      _requests = reqs;
      _sessions = sessions;
      if (sessions.isNotEmpty) {
        _selectedSession = sessions.first;
      }
      _isLoading = false;
    });
  }

  Future<void> _submitRequest() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập lý do xin nghỉ phép!')),
      );
      return;
    }

    final user = AuthService.instance.currentUser;
    await ApiService.instance.createLeaveRequest(
      sinhVienId: user?.id ?? 1,
      buoiHocId: _selectedSession?.id ?? 1,
      lyDo: reason,
      hinhAnhMinhChung: _proofUrl,
    );

    _reasonController.clear();
    await _loadData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã gửi đơn xin nghỉ phép kèm minh chứng thành công!'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  Future<void> _handleApproval(LeaveRequestModel req, String status) async {
    final noteController = TextEditingController();
    final isApproved = status == 'DA_DUYET';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isApproved ? 'Duyệt Đơn Nghỉ Phép' : 'Từ Chối Đơn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sinh viên: ${req.sinhVien?.hoTen ?? "Trần Hoàng Công Đăng"}'),
            Text('Lý do: ${req.lyDo}'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú / Nhận xét của giảng viên',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproved ? Colors.green.shade700 : Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(isApproved ? 'Đồng ý Duyệt' : 'Từ chối'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.instance.approveLeaveRequest(req.id, status, noteController.text.trim());
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isLecturer ? 'Xét Duyệt Đơn Nghỉ Phép' : 'Đơn Nghỉ Phép & Minh Chứng'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Novel Feature Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.amber.shade900),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'QUY ĐỊNH CHUYÊN CẦN & NGHỈ PHÉP',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Quy định: Vắng từ 20% trở lên (>= 20% tổng số buổi) sẽ bị cấm thi. Hệ thống tự động tính toán số buổi vắng và cho phép nộp đơn có minh chứng để chuyển sang Vắng có phép.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // If Student -> Show submission form
                  if (!widget.isLecturer) ...[
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('TẠO ĐƠN NGHỈ PHÉP TRỰC TUYẾN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 12),

                            // Session Dropdown
                            DropdownButtonFormField<SessionModel>(
                              value: _selectedSession,
                              decoration: const InputDecoration(
                                labelText: 'Chọn buổi học xin nghỉ',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              items: _sessions.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text('${s.tenBuoiHoc} (${s.ngayHoc})', style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedSession = val),
                            ),
                            const SizedBox(height: 12),

                            // Reason
                            TextField(
                              controller: _reasonController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Lý do xin nghỉ phép cụ thể',
                                hintText: 'Ví dụ: Sốt cao, đi khám bệnh hoặc tham gia thi Olympic Tin học...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Medical Proof Preview
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      _proofUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.receipt_long, size: 50, color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Minh chứng đính kèm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        Text('Đã đính kèm giấy khám bệnh / hồ sơ y tế', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.attach_file, color: Colors.amber),
                                    tooltip: 'Đổi minh chứng',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã tải lên minh chứng giấy tờ y tế thành công!')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade900,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.send),
                              label: const Text('GỬI ĐƠN XIN NGHỈ CHO GIẢNG VIÊN', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: _submitRequest,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Requests List
                  Text(
                    widget.isLecturer ? 'DANH SÁCH ĐƠN CHỜ GIẢNG VIÊN XÉT DUYỆT' : 'CÁC ĐƠN ĐÃ GỬI GẦN ĐÂY',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  if (_requests.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('Không có đơn nghỉ phép nào.')),
                    )
                  else
                    ..._requests.map((r) {
                      Color statusColor;
                      String statusText;
                      if (r.trangThai == 'DA_DUYET') {
                        statusColor = Colors.green;
                        statusText = 'ĐÃ DUYỆT (CÓ PHÉP)';
                      } else if (r.trangThai == 'TU_CHOI') {
                        statusColor = Colors.red;
                        statusText = 'BỊ TỪ CHỐI';
                      } else {
                        statusColor = Colors.orange;
                        statusText = 'CHỜ DUYỆT';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r.sinhVien?.hoTen ?? 'Trần Hoàng Công Đăng',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusColor.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('MSSV: ${r.sinhVien?.mssv ?? "2380614670"} | Buổi: ${r.buoiHoc?.tenBuoiHoc ?? "Buổi học"}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              const SizedBox(height: 6),
                              Text('Lý do: ${r.lyDo}', style: const TextStyle(fontSize: 13)),
                              if (r.ghiChuGiangVien != null && r.ghiChuGiangVien!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                                  child: Text('Phản hồi GV: ${r.ghiChuGiangVien}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                                ),
                              ],
                              if (widget.isLecturer && r.trangThai == 'CHO_DUYET') ...[
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Từ chối'),
                                      onPressed: () => _handleApproval(r, 'TU_CHOI'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Duyệt có phép'),
                                      onPressed: () => _handleApproval(r, 'DA_DUYET'),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
