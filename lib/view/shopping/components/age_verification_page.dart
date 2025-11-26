import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/cart/cart_controller.dart';
import 'package:newvendingmachine/utils/message_utils.dart';
import 'package:newvendingmachine/view/Dashboard/dashboard_page.dart';

class AgeVerificationPage extends StatefulWidget {
  final int age;
  final Function(bool) callBack;

  const AgeVerificationPage({
    super.key,
    required this.age,
    required this.callBack,
  });

  @override
  State<AgeVerificationPage> createState() => _AgeVerificationPageState();
}

class _AgeVerificationPageState extends State<AgeVerificationPage> {
  static const platform = MethodChannel('com.appAra.newVending/scanner');
  final cartController = Get.find<CartController>();
  String _scanMessage = 'No code scanning information is available';

  @override
  void initState() {
    super.initState();
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onScanResult':
          _handleScanResult(
            call.arguments['deviceId'],
            call.arguments['data'],
            call.arguments['count'],
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Step 1
            _buildStep(
              step: "Step 1",
              title: "SCAN YOUR ID",
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 50),

            // Step 2
            _buildStep(
              step: "Step 2",
              title: "MAKE PAYMENT",
              icon: Icons.payment_rounded,
            ),
            const SizedBox(height: 50),

            // Step 3
            _buildStep(
              step: "Step 3",
              title: "COLLECT\nYOUR PURCHASED ITEM",
              icon: Icons.shopping_bag_outlined,
              multiLine: true,
            ),

            const SizedBox(height: 60),

            // Cancel Button
            ElevatedButton.icon(
              onPressed: () {
                cartController.cleareCartItems();
                Get.offAll(() => const DashboardPage());
              },
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String step,
    required String title,
    required IconData icon,
    bool multiLine = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          step,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: multiLine ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Icon(
          icon,
          size: 60,
          color: Colors.black87,
        ),
      ],
    );
  }

  void _handleScanResult(int deviceId, String data, int count) {
    String dobString = _extractDob(data);
    DateTime? dob = _parseDob(dobString);

    bool isAbove18 = false;
    if (dob != null) {
      final today = DateTime.now();
      final age = today.year -
          dob.year -
          ((today.month < dob.month ||
                  (today.month == dob.month && today.day < dob.day))
              ? 1
              : 0);
      isAbove18 = age >= widget.age;
    }

    setState(() {
      _scanMessage = '[$count][device number:$deviceId] Buf: $data\n'
          'DOB: $dobString\n'
          'Age Verified: ${isAbove18 ? "✅ Allowed" : "❌ Denied"}';
    });

    widget.callBack(isAbove18);
    if (isAbove18) {
      Get.back();
    }
  }

  String _extractDob(String rawData) {
    final regex = RegExp(r'DBB(\d{8})');
    final match = regex.firstMatch(rawData);
    if (match != null) {
      return match.group(1)!;
    }
    return "";
  }

  DateTime? _parseDob(String dobString) {
    if (dobString.isEmpty || dobString.length != 8) return null;
    final month = int.tryParse(dobString.substring(0, 2));
    final day = int.tryParse(dobString.substring(2, 4));
    final year = int.tryParse(dobString.substring(4, 8));
    if (month == null || day == null || year == null) return null;
    return DateTime(year, month, day);
  }
}
