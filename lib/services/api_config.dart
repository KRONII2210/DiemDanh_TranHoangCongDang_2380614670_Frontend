/**
 * =====================================================================
 * CẤU HÌNH ĐƯỜNG DẪN WEB API DÙNG CHUNG CỦA NHÓM TSV
 * (KẾT NỐI API DiemDanh_DoDangKhoa_2380614683_API TỪ GITHUB)
 * SINH VIÊN: TRẦN HOÀNG CÔNG ĐĂNG (2380614670)
 * =====================================================================
 */
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Tự động nhận diện nền tảng:
  /// - Chạy trên PC / Trình duyệt Web (Edge/Chrome): tự động nhận diện theo domain/port máy chủ
  /// - Chạy trên Điện thoại (USB/adb reverse): kết nối "http://localhost:5080/api"
  static String get defaultUrl {
    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && !origin.startsWith('file:') && origin != 'null') {
          return "$origin/api";
        }
      } catch (_) {}
      return "http://localhost:5080/api";
    }
    return "http://localhost:5080/api";
  }

  static String sharedApiUrl = defaultUrl;
  static String currentBaseUrl = defaultUrl;

  // Lưu trữ Token JWT sau khi đăng nhập thành công
  static String? jwtToken;

  static void setCustomUrl(String newUrl) {
    if (newUrl.endsWith("/")) {
      currentBaseUrl = newUrl.substring(0, newUrl.length - 1);
    } else {
      currentBaseUrl = newUrl;
    }
  }

  static Map<String, String> get authHeaders {
    final headers = {'Content-Type': 'application/json'};
    if (jwtToken != null && jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $jwtToken';
    }
    return headers;
  }
}
