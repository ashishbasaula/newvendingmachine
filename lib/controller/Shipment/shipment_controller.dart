import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/Services/shipment_service.dart';
import 'package:newvendingmachine/utils/message_utils.dart';

import '../../view/shopping/sucess_payment_page.dart';
import '../cart/cart_controller.dart' show CartController;

class ShipmentController extends GetxController {
  static const platform = MethodChannel('com.appAra.newVending/device');

  final cartController = Get.find<CartController>();
  Queue<Map<String, dynamic>> channelQueue = Queue<Map<String, dynamic>>();
  var isAllItemDispatch = false.obs;
  Future<void> initialShipment() async {
    SmartDialog.showLoading(msg: "Wait while processing");
    try {
      for (var element in cartController.items) {
        for (int i = 0; i < element.quantity; i++) {
          channelQueue.add({"channelId": int.parse(element.channelNumber)});
        }
      }
      dynamic data = await platform.invokeMethod("getShipmentStatus");
      MessageUtils.showSuccess(data.toString());
      processQueue();
    } catch (e) {
      MessageUtils.showError("Error during initial shipment: ${e.toString()}");
    } finally {
      SmartDialog.dismiss();
    }
  }

  void processQueue() async {
    try {
      if (channelQueue.isNotEmpty) {
        var currentItem = channelQueue.removeFirst();
        dispenseItems(channelNumber: currentItem['channelId']);
      } else {
        isAllItemDispatch.value =
            true; // Indicate all items have been processed

        SmartDialog.dismiss();

// clear the cart and upload the data to the backend
        cartController.cleareCartItems();
        Get.to(() => const SucessPaymentPage());
      }
    } catch (e) {
      MessageUtils.showError(e.toString());
    }
  }

  Future<void> dispenseItems({required int channelNumber}) async {
    try {
      String message = await ShipmentService.initiateShipment(
          1, channelNumber, 1, false, false);
      debugPrint(message);
      //check if current shipment is sucess and if sucess proced another
      platform.setMethodCallHandler(_handleMethod);
    } on PlatformException catch (e) {
      MessageUtils.showError("Error dispensing items: ${e.toString()}");
    }
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "updateLastUniqueData":
        processQueue();

        break;
      default:
        throw PlatformException(
            code: 'NotImplemented',
            details:
                'No implementation found for method ${call.method} on channel com.example.vend_final/serial');
    }
  }
}
