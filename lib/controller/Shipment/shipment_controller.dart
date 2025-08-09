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
        final currentItem = channelQueue.first;

        channelQueue.removeFirst();
        await dispenseItems(channelNumber: currentItem['channelId']);
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
    } on PlatformException catch (e) {
      MessageUtils.showError("Error dispensing items: ${e.toString()}");
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
