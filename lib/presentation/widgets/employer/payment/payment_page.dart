import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:jobgo/core/localization/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

// --- CẤU HÌNH VNPAY ---
class VNPayConfig {
  static String get tmnCode => dotenv.env['VNPAY_TMN_CODE'] ?? '';
  static String get hashSecret => dotenv.env['VNPAY_HASH_SECRET'] ?? '';
  static const String url =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String returnUrl = 'jobgo://vnpay-return';
}

class VNPayService {
  static String generatePaymentUrl({required double amount}) {
    // 1. Khởi tạo tham số
    Map<String, String> vnpParams = {
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': VNPayConfig.tmnCode,
      'vnp_Amount': (amount * 100).toInt().toString(), // VNPAY yêu cầu nhân 100
      'vnp_CreateDate': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
      'vnp_CurrCode': 'VND',
      'vnp_IpAddr': '127.0.0.1',
      'vnp_Locale': 'vn',
      // MẸO: Xóa toàn bộ khoảng trắng, dùng gạch dưới để tránh lỗi Encode khác biệt
      'vnp_OrderInfo': 'Thanh_toan_don_hang_JobGo',
      'vnp_OrderType': 'other',
      'vnp_ReturnUrl': VNPayConfig.returnUrl,
      'vnp_TxnRef': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    // 2. Sắp xếp các key theo bảng chữ cái
    var sortedKeys = vnpParams.keys.toList()..sort();

    // 3. Tạo chuỗi query
    List<String> queryData = [];
    for (String key in sortedKeys) {
      final value = vnpParams[key]!;
      // Dùng encodeQueryComponent thay vì encodeComponent để xử lý đúng chuẩn
      queryData.add(
        '${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(value)}',
      );
    }
    String queryString = queryData.join('&');

    // 4. Băm HMAC SHA512
    var hmac = Hmac(sha512, utf8.encode(VNPayConfig.hashSecret));
    var digest = hmac.convert(utf8.encode(queryString));

    // 5. Trả về URL hoàn chỉnh
    return '${VNPayConfig.url}?$queryString&vnp_SecureHash=${digest.toString()}';
  }
}

// ...existing code...

class PaymentPage extends StatefulWidget {
  final double amount;

  const PaymentPage({Key? key, required this.amount}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _openedExternal = false;

  @override
  void initState() {
    super.initState();
    final String url = VNPayService.generatePaymentUrl(amount: widget.amount);

    if (Platform.isWindows) {
      // Mở link bằng trình duyệt ngoài trên Windows
      _openExternal(url);
    } else {
      // Android/iOS: dùng WebView
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith(VNPayConfig.returnUrl)) {
                final uri = Uri.parse(request.url);
                final responseCode = uri.queryParameters['vnp_ResponseCode'];
                final loc = AppLocalizations.of(context);

                if (responseCode == '00') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.paymentSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.paymentFailedOrCanceled),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pop(context, false);
                }
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(url));
    }
  }

  Future<void> _openExternal(String url) async {
    if (_openedExternal) return;
    _openedExternal = true;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      // Sau khi mở trình duyệt, hiển thị dialog hướng dẫn người dùng quay lại app
      if (mounted) {
        _showReturnDialog();
      }
    } else {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.unableToOpenPaymentBrowser),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, false);
      }
    }
  }

  void _showReturnDialog() {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(loc.completePaymentTitle),
        content: Text(loc.completePaymentMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Giả định thanh toán thành công
            },
            child: Text(loc.confirmPaid),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false); // Hủy
            },
            child: Text(loc.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    if (Platform.isWindows) {
      // Hiển thị loading hoặc hướng dẫn trên Windows
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.vnpayPaymentTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: Center(child: Text(loc.openingPaymentBrowser)),
      );
    }
    // Android/iOS: vẫn dùng WebView
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.vnpayPaymentTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.blue)),
        ],
      ),
    );
  }
}
