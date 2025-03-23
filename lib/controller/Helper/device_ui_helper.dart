import 'package:get/get.dart';

class DeviceUiHelper {
  static bool isNotMobile() {
    return Get.width > 600;
  }
}
