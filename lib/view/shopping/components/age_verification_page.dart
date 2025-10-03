import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:newvendingmachine/controller/cart/cart_controller.dart';
import 'package:newvendingmachine/utils/message_utils.dart';
import 'package:newvendingmachine/utils/padding_utils.dart';
import 'package:newvendingmachine/view/Dashboard/dashboard_page.dart';

class AgeVerificationPage extends StatefulWidget {
  final int age;
  final Function(bool) callBack;
  const AgeVerificationPage(
      {super.key, required this.age, required this.callBack});

  @override
  State<AgeVerificationPage> createState() => _AgeVerificationPageState();
}

class _AgeVerificationPageState extends State<AgeVerificationPage> {
  static const platform = MethodChannel('com.appAra.newVending/scanner');
  String _scanMessage = 'No code scanning information is available';
  final cartController = Get.find<CartController>();

  @override
  void initState() {
    // TODO: implement initState
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
      appBar: AppBar(
        title: const Text("Age Verification"),
      ),
      body: Padding(
        padding: PaddingUtils.SCREEN_PADDING,
        child: Column(
          children: [
            Lottie.asset(
              "assets/animation/id_verify.json",
            ),
            const Text(
              "1.Please Scan you id card to verify your age\n2.Pay For your items\n3.Collect you items",
              textAlign: TextAlign.justify,
              style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton.icon(
              onPressed: () {
                cartController.cleareCartItems();
                Get.offAll(() => const DashboardPage());
              },
              label: const Text(
                "Cancel",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrangeAccent),
              ),
              icon: const Icon(Icons.cancel),
            )
          ],
        ),
      ),
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
      MessageUtils.showWarning(_scanMessage);
    });

    // Call back to parent

    widget.callBack(isAbove18);
    if (isAbove18) {
      Get.back();
    }
  }

  String _extractDob(String rawData) {
    // Find DBB field in the raw barcode data
    final regex = RegExp(r'DBB(\d{8})');
    final match = regex.firstMatch(rawData);
    if (match != null) {
      return match.group(1)!; // returns like "02221997"
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
