import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:newvendingmachine/controller/Helper/helper_controller.dart';

class TaxHelper {
  static Future<double> getTaxPercentage(String catName) async {
    final helperController = Get.find<HelperController>();
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(helperController.userId.value)
        .collection("devices")
        .doc(helperController.deviceId.value)
        .collection("ItemCategory")
        .where("catName", isEqualTo: catName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return 0.0; // Category not found → return 0
    }

    final data = querySnapshot.docs.first.data();

    // Read taxAmount, ensure safe fallback
    final tax = data["taxAmount"];
    if (tax == null) return 0.0;

    return (tax is num) ? tax.toDouble() : 0.0;
  }
}
