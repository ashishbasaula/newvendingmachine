import 'package:get/get.dart';
import 'package:flutter/services.dart';

class GPIOController extends GetxController {
  final methodChannel = const MethodChannel("com.example.vend_final/serial");
  var gpios = <GPIO>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Example initial setup, you might want to fetch this from a device
    gpios.assignAll([
      GPIO(pin: 1, direction: 'Output', level: 'High'),
      GPIO(pin: 2, direction: 'Input', level: 'Low'),
      // Add more initial GPIO configurations
    ]);
  }

  Future<void> setGpioDirection(int pin, String direction) async {
    try {
      int dirValue =
          direction == "Output" ? 1 : 0; // Assuming 'Output' is 1, 'Input' is 0
      await methodChannel.invokeMethod(
          'setGpioDirection', {'gpio': pin, 'direction': dirValue});
      int index = gpios.indexWhere((g) => g.pin == pin);
      if (index != -1) {
        gpios[index].direction = direction;
        gpios.refresh(); // Refresh observable to update UI
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to set GPIO direction: ${e.toString()}');
    }
  }

  Future<void> setGpioValue(int pin, String value) async {
    try {
      await methodChannel
          .invokeMethod('setGpioValue', {'gpio': pin, 'value': value});
      int index = gpios.indexWhere((g) => g.pin == pin);
      if (index != -1) {
        gpios[index].level = value;
        gpios.refresh(); // Refresh observable to update UI
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to set GPIO value: ${e.toString()}');
    }
  }
}

class GPIO {
  int pin;
  String direction;
  String level;

  GPIO({required this.pin, required this.direction, required this.level});
}
