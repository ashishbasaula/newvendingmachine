import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/NewMotorTest/crc_services.dart';
import 'package:newvendingmachine/utils/message_utils.dart';
import 'package:newvendingmachine/view/shopping/sucess_payment_page.dart';

class MotorController extends GetxController {
  final _channel = const MethodChannel('com.appAra.newVending/serial');
  var _response = "".obs;
  final String _initialCommand = "FFAA03010";
  String motorRotationCommand = "FCCBFFEE0106";
  String initialSequence = "01";
  // final cartController = Get.find<CartController>();
  var isMotorUnderProcess = false.obs;
  var allItemsDispatched = false.obs;

  var items = <int>[].obs;

  Queue<Map<String, dynamic>> dispatchQueue = Queue();

  void configureSerialPort() async {
    // for (var item in cartController.items) {
    //   for (int i = 0; i < item.quantity; i++) {
    //     dispatchQueue.add({"channelId": item.channelNumber});
    //   }
    // }

    for (int i = 0; i < items.length; i++) {
      dispatchQueue.add({
        "channelId": [items[i]]
      });
    }

    try {
      final result = await _channel.invokeMethod('configureSerialPort', {
        'serialName': "/dev/ttyS3",
        'baudRate': "57600",
      });

      _response.value = result;
      if (result.toString().contains("Serial port opened successfully")) {
        MessageUtils.showSuccess(result);
        processQueue();
        // rotate the moter accordingly
      }
    } on PlatformException catch (e) {
      _response.value = "Failed to configure serial port: ${e.message}";
      MessageUtils.showError(e.toString());
    }
  }

  Future<void> _sendCommand({required String command}) async {
    try {
      await _channel.invokeMethod('sendCommand', {
        'data': command,
        'isNeedSendWake': true,
      });
    } on PlatformException catch (e) {
      _response.value = "Failed to send command: ${e.message}";
      MessageUtils.showError(e.toString());
    }
  }

  void _closeSerialPort() async {
    try {
      final result = await _channel.invokeMethod('closeSerialPort');

      _response.value = result;
      MessageUtils.showSuccess(result);
    } on PlatformException catch (e) {
      _response.value = "Failed to close serial port: ${e.message}";
      MessageUtils.showError(e.toString());
    }
  }

  void rotateMotor({required String channelNumber}) async {
    try {
      String data = "$_initialCommand$channelNumber${initialSequence}01";

      List<int> convertedHex = hexStringToListInt(data);
      int crcData = CRC8.calculateChecksum(convertedHex);
      String convertedCrc = crcData.toRadixString(16).toUpperCase();
      String finalCombineData = "$data$convertedCrc";
      _sendCommand(command: finalCombineData);

      // send the motor rotation command
      String motorRotateFinalCommand = "$motorRotationCommand$initialSequence";
      _sendCommand(command: motorRotateFinalCommand);
      _channel.setMethodCallHandler(_handleMethod);

      print("Commands Run sucessfully");
    } catch (e) {
      isMotorUnderProcess.value = false;
      MessageUtils.showError("Failed to rotate motor: ${e.toString()}");
    } finally {
      // processQueue();
      SmartDialog.dismiss();
    }
  }

  String incrementHex(String hex) {
    if (hex.toUpperCase() == 'FF') {
      return '01'; // Wrap around to '01' or you can modify it to return 'FF' if no wrap is desired.
    }

    int decimal = int.parse(hex, radix: 16); // Convert hex to decimal.
    decimal++; // Increment the decimal value.

    String nextHex = decimal
        .toRadixString(16)
        .padLeft(2, '0')
        .toUpperCase(); // Convert back to hex and ensure two characters.

    return nextHex;
  }

  List<int> hexStringToListInt(String hex) {
    List<int> result = [];
    for (int i = 0; i < hex.length; i += 2) {
      String byteString = hex.substring(i, i + 2);
      int byteValue = int.parse(byteString, radix: 16);
      result.add(byteValue);
    }
    return result;
  }

  void processQueue() async {
    if (dispatchQueue.isNotEmpty) {
      var currentItem = dispatchQueue.removeFirst();
      rotateMotor(channelNumber: currentItem['channelId']);
    } else {
      allItemsDispatched.value = true; // Indicate all items have been processed
      _closeSerialPort();
      SmartDialog.dismiss();

// clear the cart and upload the data to the backend
      // cartController.items.clear();
      // Get.to(() => const SucessPaymentPage());

      items.clear();
      MessageUtils.showSuccess("Sucessfully completed");
    }
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "updateLastUniqueData":
        String newData = call.arguments;
        print("Serial Data Received$newData");
        if (newData.contains("FF550204")) {
          String newHex = incrementHex(initialSequence);

          initialSequence = newHex;
          isMotorUnderProcess.value = false;
          processQueue();
        }
        break;
      default:
        throw PlatformException(
            code: 'NotImplemented',
            details:
                'No implementation found for method ${call.method} on channel com.example.vend_final/serial');
    }
  }
}
