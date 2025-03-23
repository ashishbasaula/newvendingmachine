import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/utils/colors_utils.dart';

class MessageUtils {
  static void showSuccess(String message) {
    Get.snackbar(
      "Success",
      message,
      backgroundColor: VendingMachineColors.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showWarning(String message) {
    Get.snackbar(
      "Warning",
      message,
      backgroundColor: VendingMachineColors.accentColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
