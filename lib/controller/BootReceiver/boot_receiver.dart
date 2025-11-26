import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RebootDetector {
  static const _channel = MethodChannel('com.appAra.newVending/device');

  static Future<bool> wasAfterReboot() async {
    try {
      final result = await _channel.invokeMethod('wasAfterReboot');
      debugPrint('RebootDetector: wasAfterReboot result: $result');
      return result == true;
    } catch (e) {
      print('Error checking reboot: $e');
      return false;
    }
  }
}
