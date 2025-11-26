import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/PaymentController/payment_controller.dart';
import 'package:newvendingmachine/utils/padding_utils.dart';

class PaymentSettingsPage extends StatelessWidget {
  PaymentSettingsPage({super.key});

  final paymentController = Get.find<PaymentConroller>();

  Widget _statusTile({
    required IconData icon,
    required String title,
    required bool isSuccess,
    String? subtitle,
    required Function onPressed,
  }) {
    return InkWell(
      onTap: () => onPressed(),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor:
                isSuccess ? Colors.green.shade100 : Colors.red.shade100,
            child: Icon(
              icon,
              color: isSuccess ? Colors.green : Colors.red,
            ),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: Icon(
            isSuccess ? Icons.check_circle : Icons.cancel,
            color: isSuccess ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(Get.context!).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Settings"),
      ),
      body: Obx(
        () => Padding(
          padding: PaddingUtils.SCREEN_PADDING,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SDK Status
              _statusTile(
                icon: Icons.payment,
                title: "SDK Initialization",
                isSuccess: paymentController.isSdkInitialized.value,
                subtitle: paymentController.isSdkInitialized.value
                    ? "SDK is ready to use"
                    : "Please initialize the SDK",
                onPressed: paymentController.initializeSumUpSDK,
              ),
              const SizedBox(height: 10),

              // Login Status
              _statusTile(
                icon: Icons.login,
                title: "Login Status",
                isSuccess: paymentController.isLoginSuccess.value,
                subtitle: paymentController.isLoginSuccess.value
                    ? "Merchant: ${paymentController.merchantResponse.value?.merchantCode ?? "Unknown"}"
                    : "Please login to proceed",
                onPressed: paymentController.handleLogin,
              ),
              const SizedBox(height: 10),

              // Reader Setup
              _statusTile(
                icon: Icons.settings,
                title: "Reader Setup",
                isSuccess: paymentController.isSettingSuccess.value,
                subtitle: paymentController.isSettingSuccess.value
                    ? "Reader is configured"
                    : "Setup required",
                onPressed: paymentController.handleOpenSettings,
              ),
              const SizedBox(height: 20),

              // Actions
              if (!paymentController.isSdkInitialized.value)
                _actionButton(
                  label: "Initialize Payment SDK",
                  onPressed: paymentController.initializeSumUpSDK,
                ),

              if (paymentController.isSdkInitialized.value &&
                  !paymentController.isLoginSuccess.value)
                _actionButton(
                  label: "Login",
                  onPressed: paymentController.handleLogin,
                  color: Colors.orange,
                ),

              if (paymentController.isLoginSuccess.value &&
                  !paymentController.isSettingSuccess.value)
                _actionButton(
                  label: "Setup Reader Settings",
                  onPressed: paymentController.handleOpenSettings,
                  color: Colors.blue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
