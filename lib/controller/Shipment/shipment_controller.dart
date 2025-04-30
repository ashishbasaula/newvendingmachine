import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/Services/local_storage_services.dart';
import 'package:newvendingmachine/Services/shipment_service.dart';
import 'package:newvendingmachine/controller/Device/setting_controller.dart';
import 'package:newvendingmachine/utils/message_utils.dart';

import '../../view/shopping/sucess_payment_page.dart';
import '../cart/cart_controller.dart' show CartController;

class ShipmentController extends GetxController {
  static const platform = MethodChannel('com.appAra.newVending/device');
  final firebaseFireStore = FirebaseFirestore.instance;

  final cartController = Get.find<CartController>();
  final settingController = Get.find<SettingController>();

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

//   void processQueue() async {
//     try {
//       if (channelQueue.isNotEmpty) {
//         var currentItem = channelQueue.removeFirst();
//         dispenseItems(channelNumber: currentItem['channelId']);
//       } else {
//         isAllItemDispatch.value =
//             true; // Indicate all items have been processed

//         SmartDialog.dismiss();

// // clear the cart and upload the data to the backend
//         addOrderToDatabase();
//       }
//     } catch (e) {
//       MessageUtils.showError(e.toString());
//     }
//   }

  void processQueue() async {
    try {
      if (channelQueue.isNotEmpty) {
        final currentItem = channelQueue.first;

        // Check device status before dispensing
        final Map<dynamic, dynamic> status =
            await platform.invokeMethod("getShipmentStatus");

        final runStatus = status['runStatus'];
        final faultCode = status['faultCode'];

        if (runStatus == 0 && faultCode == 0) {
          // Safe to dispense
          channelQueue.removeFirst();
          await dispenseItems(channelNumber: currentItem['channelId']);
        } else {
          // Not safe, show error or retry
          MessageUtils.showError(
              "Waiting for device to be ready. Status: $runStatus, Fault: $faultCode");

          // Optionally, retry after delay
          Future.delayed(const Duration(seconds: 2), () {
            processQueue(); // Retry
          });
        }
      } else {
        isAllItemDispatch.value = true;
        SmartDialog.dismiss();
        addOrderToDatabase();
      }
    } catch (e) {
      MessageUtils.showError("Error during processing: ${e.toString()}");
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

  Future<void> addOrderToDatabase() async {
    SmartDialog.showLoading();

    final userId = await LocalStorageServices.getUserId();
    // use this in the production
    // final deviceNumber = settingController.serialNumber.value;
    const deviceNumber = "asdasdasdaddasdad";

    try {
      final docRef = firebaseFireStore
          .collection("users")
          .doc(userId)
          .collection("Orders")
          .doc();
      final orderId = docRef.id;

      await docRef.set({
        "order_no": orderId,
        "order_status": "finished",
        "device_no": deviceNumber,
        "goods": cartController.items.map((item) => item.toMap()).toList(),
        "total_price": cartController.totalPrice,
        "drop_detect": true,
        "order_time": DateTime.now(),
        "payment_time": DateTime.now()
      }).then((val) {
        // reduce the inventory items
        reduceProduct();
      });
    } catch (e) {
      MessageUtils.showError(e.toString());
    }
  }

  Future<void> reduceProduct() async {
    final userId = await LocalStorageServices.getUserId();

    try {
      for (var items in cartController.items) {
        await firebaseFireStore
            .collection("users")
            .doc(userId)
            .collection("Items")
            .doc(items.id)
            .update({
          "inventoryThreshold": items.inventoryThreasHold - items.quantity
        });
      }
      MessageUtils.showSuccess("Completed");
      cartController.cleareCartItems();
      Get.to(() => const SucessPaymentPage());
    } catch (e) {
      MessageUtils.showError(e.toString());
    } finally {
      SmartDialog.dismiss();
    }
  }
}
