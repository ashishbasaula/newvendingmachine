import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:http/http.dart' as http;

class ShipmentController extends GetxController {
  static const platform = MethodChannel('com.appAra.newVending/device');
  final firebaseFireStore = FirebaseFirestore.instance;

  final cartController = Get.find<CartController>();
  final settingController = Get.find<SettingController>();
  var userName = "".obs;
  var userEmail = "".obs;

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
        final currentItem = channelQueue.removeFirst();

        // Await shipment before going to next
        await dispenseItems(channelNumber: currentItem['channelId']);

        // Move to next item after previous is done
        processQueue();
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
      // This will block until shipment is complete because of the Kotlin side
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
    final deviceNumber = settingController.serialNumber.value;
    // const deviceNumber = "asdasdasdaddasdad";

    try {
      final docRef = firebaseFireStore
          .collection("users")
          .doc(userId)
          .collection("devices")
          .doc(await LocalStorageServices.getDeviceId())
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
        if (items.inventoryThreasHold - items.quantity <= 0) {
          String to = userEmail.value;
          String subject = "Stock Alert: Item ${items.name} is Out of Stock";
          String message =
              "Dear ${userName.value}, your item ${items.name} is out of stock in device  ${settingController.serialNumber.value}. Please refill it as soon as possible. Thank you.";
          await sendEmail(to: to, subject: subject, message: message);
        }

        await firebaseFireStore
            .collection("users")
            .doc(userId)
            .collection("devices")
            .doc(await LocalStorageServices.getDeviceId())
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

  void testSendEmail() async {
    String to = userEmail.value;
    String subject = "Stock Alert: Item  Apple is Out of Stock";
    String message =
        "Dear ${userName.value}, your item apple is out of stock in device  ${settingController.serialNumber.value}. Please refill it as soon as possible. Thank you.";
    // await sendEmail(to: to, subject: subject, message: message);
    debugPrint(message);
  }

  Future<void> sendEmail({
    required String to,
    required String subject,
    required String message,
  }) async {
    try {
      // Optional: set status text here, if you use state or a UI element
      debugPrint("📨 Sending...");

      final response = await http.post(
        Uri.parse("http://88.99.192.190/api/sendmail"), // your API endpoint
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "to": to,
          "subject": subject,
          "text": message,
          "html": "<p>$message</p>",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("✅ Email sent successfully: $data");
      } else {
        final data = jsonDecode(response.body);
        debugPrint("❌ Error: ${data['error'] ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint("❌ Failed to send email: $e");
    }
  }

  Future<void> getAdminDetails() async {
    try {
      // Replace with your actual user ID
      String userId = await LocalStorageServices.getUserId();
      ;

      // Fetch document from Firestore
      final DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        userName.value = data['userName'] ?? 'Unknown';
        userEmail.value = data['userEmail'] ?? 'Unknown';
        // final password = data['password'] ?? 'Unknown';
        // final phoneNumber = data['phoneNumber'] ?? 'Unknown';

        // Optionally, you can store these in your app state or model
      } else {
        debugPrint("❌ No admin found for userId: $userId");
      }
    } catch (e) {
      MessageUtils.showError(e.toString());
    }
  }
}
