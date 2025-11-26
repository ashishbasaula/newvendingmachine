import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SettingController extends GetxController {
  final methodChannel = const MethodChannel("com.appAra.newVending/device");

  // Observables for storing system information as strings
  var apiVersion = "".obs;
  var deviceModel = "".obs;
  var systemStorage = "".obs;
  var cpuModel = "".obs;
  var cpuTemp = "".obs;
  var serialNumber = "".obs;
  var isSystemInfoLoaded = false.obs;

  // for the storage paths
  var sdCardPath = "".obs;
  var usbPath = "".obs;
  var internalPath = "".obs;
  var isStroagePathLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    getSystemInformation();
  }

  Future<void> getSystemInformation() async {
    try {
      // Using toString() to ensure all values are stored as strings
      apiVersion.value =
          (await methodChannel.invokeMethod('getApiVersion')).toString();
      deviceModel.value =
          (await methodChannel.invokeMethod('getBuildModel')).toString();
      systemStorage.value =
          (await methodChannel.invokeMethod('getSystemStorage')).toString();
      cpuModel.value =
          (await methodChannel.invokeMethod('getSystemVersion')).toString();
      cpuTemp.value =
          (await methodChannel.invokeMethod('getCPUTemp')).toString();
      serialNumber.value =
          (await methodChannel.invokeMethod('getSerialNumber')).toString();
      (await methodChannel.invokeMethod('hideStatusBar')).toString();
      isSystemInfoLoaded.value = true;
    } catch (e) {
      debugPrint(e.toString());
      showResultSnackbar("Error", e.toString());
      isSystemInfoLoaded.value =
          false; // Ensuring the observable reflects the error state
    }
  }

// Device management function
  Future<void> deviceManagement({required int index}) async {
    switch (index) {
      case 0:
        try {
          await methodChannel.invokeMethod('rebootDevice');
        } catch (e) {
          debugPrint(e.toString());
          showResultSnackbar("Error", e.toString());
        }
        break;
      case 1:
        try {
          await methodChannel.invokeMethod('shutdownDevice');
        } catch (e) {
          debugPrint(e.toString());
          showResultSnackbar("Error", e.toString());
        }
        break;
      case 2:
        try {
          await methodChannel.invokeMethod('upgradeFirmware');
        } catch (e) {
          debugPrint(e.toString());
          showResultSnackbar("Error", e.toString());
        }
        break;
    }
  }

  // For the Display Settings
  Future<void> dsBrightness(int brightness) async {
    try {
      // Make sure the brightness value is within the acceptable range (0-100)
      int clampedBrightness = brightness.clamp(0, 100);
      // Invoke the native method with the clamped brightness value
      final result = await methodChannel.invokeMethod(
          'changeScreenBrightness', {'brightness': clampedBrightness});
      debugPrint('Brightness change result: $result');
    } catch (e) {
      showResultSnackbar("Error", e.toString());
      debugPrint(e.toString());
    }
  }

  Future<void> dsToggleHdmi(bool enable) async {
    try {
      final result = await methodChannel
          .invokeMethod('toggleHDMIOutput', {'enable': enable});
      debugPrint('HDMI output toggle result: $result');
    } catch (e) {
      showResultSnackbar("Error", e.toString());
      debugPrint('Error toggling HDMI output: ${e.toString()}');
    }
  }

  // For the storage path
  Future<void> storagePath() async {
    try {
      // Using toString() to ensure all values are stored as strings
      sdCardPath.value =
          (await methodChannel.invokeMethod('getSdCardPath')).toString();
      usbPath.value =
          (await methodChannel.invokeMethod('getUsbPath')).toString();

      isStroagePathLoaded.value = true;
    } catch (e) {
      debugPrint(e.toString());
      showResultSnackbar("Error", e.toString());
      isStroagePathLoaded.value =
          false; // Ensuring the observable reflects the error state
    }
  }

  // For the Gipo control
  void showResultSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.all(10),
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> hideStatusBar(bool isHide) async {
    try {
      final result =
          await methodChannel.invokeMethod("hideStatusBar", {"hide": isHide});
      print("Native response: $result");
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }
}
