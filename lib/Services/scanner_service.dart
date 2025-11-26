import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ScannerService {
  static const platform = MethodChannel('com.appAra.newVending/device');
  String val = "";
  Future<String?> getScannerResult() async {
    try {
      final value = await platform.invokeMethod<String>("startScan");
      val = value!;
      return value;
    } on PlatformException catch (e) {
      debugPrint(e.message);
      return val;
    }
  }
}
