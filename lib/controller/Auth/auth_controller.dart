import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/Services/local_storage_services.dart';
import 'package:newvendingmachine/utils/message_utils.dart';
import 'package:newvendingmachine/view/Dashboard/dashboard_page.dart';

class AuthController extends GetxController {
  Future<void> userAuth() async {
    SmartDialog.showLoading(msg: "Authenticating....");
    String deviceId = getDeviceProductId(); // get the device product id

    try {
      FirebaseFirestore fireStore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await fireStore
          .collection("users")
          .where('serialNumber', isEqualTo: deviceId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          LocalStorageServices.storeUserId(userId: doc.id);
          LocalStorageServices.storeUserLoginStatus(isLogin: true);
          Get.offAll(() => const DashboardPage());
          MessageUtils.showSuccess("User authenticated successfully");
        }
      } else {
        // Handle the case where no documents are found
        MessageUtils.showError("No user found with Product ID: $deviceId");
      }
    } catch (e) {
      MessageUtils.showError("Failed to authenticate: ${e.toString()}");
    } finally {
      SmartDialog.dismiss();
    }
  }

  String getDeviceProductId() {
    // Replace with actual logic to get the product ID
    return "asdasdasdaddasdad";
  }
}
