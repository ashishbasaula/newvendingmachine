import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/Services/local_storage_services.dart';
import 'package:newvendingmachine/const/const.dart';
import 'package:newvendingmachine/controller/Device/setting_controller.dart';
import 'package:newvendingmachine/utils/message_utils.dart';
import 'package:sumup/sumup.dart';

class PaymentConroller extends GetxController {
  static const String affiliateKey = PaymentConstant.AFFELIATED_KEY;
  final isSdkInitialized = false.obs;
  final isLoginSuccess = false.obs;
  final isSettingSuccess = false.obs;
  final isPreparedForCheckout = false.obs;
  final isLoading = false.obs;
  final statusMessage = 'Initializing...'.obs;
  var merchantResponse = Rx<SumupPluginMerchantResponse?>(null);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initializeSumUpSDK();
  }

  // Initialize SumUp SDK - This is crucial and was missing in your original code
  Future<void> initializeSumUpSDK() async {
    isLoading.value = true;
    statusMessage.value = 'Initializing SumUp SDK...';

    try {
      await Sumup.init(affiliateKey);

      isSdkInitialized.value = true;
      statusMessage.value = 'SDK initialized successfully. Please login.';

      // Check if already logged in
      await checkLoginStatus();
    } catch (e) {
      statusMessage.value = 'SDK initialization failed: $e';

      debugPrint('SDK initialization error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if already logged in
  Future<void> checkLoginStatus() async {
    if (!isSdkInitialized.value) return;

    try {
      final isLoggedIn = await Sumup.isLoggedIn ?? false;
      if (isLoggedIn) {
        isLoginSuccess.value = true;
        statusMessage.value = 'Already logged in';

        await getMerchantInfo();
      } else {
        statusMessage.value = 'Please login to continue';
      }
    } catch (e) {
      statusMessage.value = 'Error checking login status: $e';

      debugPrint('Error checking login status: $e');
    }
  }

  // Get merchant information
  Future<void> getMerchantInfo() async {
    try {
      final merchant = await Sumup.merchant;
      merchantResponse.value = merchant;
      debugPrint('Merchant info: ${merchant.toString()}');

      statusMessage.value =
          'Logged in as: ${merchant.merchantCode ?? 'Unknown'}';
      MessageUtils.showSuccess(statusMessage.value);
    } catch (e) {
      debugPrint('Error getting merchant info: $e');
      MessageUtils.showError('Error getting merchant info: $e');
    }
  }

  Future<void> handleLogin() async {
    if (!isSdkInitialized.value) {
      return;
    }

    isLoading.value = true;
    statusMessage.value = 'Logging in...';
    MessageUtils.showSuccess(statusMessage.value);

    try {
      final data = await Sumup.login();
      if (data.message?['loginResult'] == true) {
        isLoginSuccess.value = true;
        statusMessage.value = 'Login successful!';
        MessageUtils.showSuccess(statusMessage.value);

        await getMerchantInfo();
      } else {
        statusMessage.value =
            'Login failed: ${data.message?['message'] ?? 'Unknown error'}';
        MessageUtils.showWarning(statusMessage.value);
      }
    } catch (e) {
      statusMessage.value = 'Login error: $e';
      MessageUtils.showError(statusMessage.value);

      debugPrint('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleOpenSettings() async {
    if (!isLoginSuccess.value) {
      return;
    }

    isLoading.value = true;
    statusMessage.value = 'Opening settings...';
    MessageUtils.showSuccess(statusMessage.value);

    try {
      final data = await Sumup.openSettings();
      debugPrint('Settings response: ${data.toString()}');

      if (data.status) {
        isSettingSuccess.value = true;
        statusMessage.value = 'Terminal configured successfully!';
        MessageUtils.showSuccess(statusMessage.value);
      } else {
        statusMessage.value = 'Settings configuration failed';
        MessageUtils.showWarning(statusMessage.value);
      }
    } catch (e) {
      statusMessage.value = 'Settings error: $e';
      MessageUtils.showError(statusMessage.value);

      debugPrint('Settings error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Prepare terminal for checkout
  Future<void> handlePrepareForCheckout() async {
    if (!isSettingSuccess.value) {
      return;
    }

    isLoading.value = true;
    statusMessage.value = 'Preparing terminal for checkout...';
    MessageUtils.showSuccess(statusMessage.value);

    try {
      final data = await Sumup.prepareForCheckout();
      debugPrint('Prepare checkout response: ${data.toString()}');

      if (data.status) {
        isPreparedForCheckout.value = true;
        statusMessage.value = 'Terminal ready for payment!';
        MessageUtils.showSuccess(statusMessage.value);
      } else {
        statusMessage.value = 'Failed to prepare terminal';
        MessageUtils.showWarning(statusMessage.value);
      }
    } catch (e) {
      statusMessage.value = 'Prepare checkout error: $e';
      MessageUtils.showError(statusMessage.value);

      debugPrint('Prepare checkout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleCheckout(
      {required Function(bool) callBack,
      required double totalPayment,
      required String paymentTitle,
      required int totalItems}) async {
    if (!isPreparedForCheckout.value) {
      return;
    }

    isLoading.value = true;
    statusMessage.value = 'Processing payment...';
    MessageUtils.showSuccess(statusMessage.value);

    try {
      // Create payment object according to documentation
      final payment = SumupPayment(
        title: paymentTitle,
        total: totalPayment,
        currency: 'USD',
        foreignTransactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        saleItemsCount: totalItems,
        skipSuccessScreen: true,
        tip: 0.0,
      );

      final request = SumupPaymentRequest(payment);
      final data = await Sumup.checkout(request);

      debugPrint('Checkout response: ${data.toString()}');

      // Handle different payment results
      if (data.success!) {
        final transactionCode = data.transactionCode;
        final cardType = data.cardType;
        final amount = data.amount;

        statusMessage.value =
            'Payment successful!\nTransaction: $transactionCode\nCard: $cardType\nAmount:\$$amount';
        MessageUtils.showSuccess(statusMessage.value);

        addTransactionDetails(transactionCode!, cardType, amount);
        // _showSuccessDialog(
        //   'Payment Successful!',
        //   'Transaction Code: $transactionCode',
        // );
        callBack(true);
      } else {
        const errorMessage = 'Payment failed';

        statusMessage.value = 'Payment failed: $errorMessage';
        MessageUtils.showError(statusMessage.value);

        callBack(false);
        // _showError('Payment failed: $errorMessage');
      }
    } catch (e) {
      statusMessage.value = 'Checkout error: $e';
      MessageUtils.showError(statusMessage.value);

      callBack(false);
      debugPrint('Checkout error: $e');
      // _showError('Checkout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleLogout() async {
    if (!isLoginSuccess.value) return;

    isLoading.value = true;
    statusMessage.value = 'Logging out...';
    MessageUtils.showSuccess(statusMessage.value);

    try {
      final data = await Sumup.logout();
      debugPrint('Logout response: ${data.toString()}');

      isLoginSuccess.value = false;
      isSettingSuccess.value = false;
      isPreparedForCheckout.value = false;
      statusMessage.value = 'Logged out successfully';
      MessageUtils.showSuccess(statusMessage.value);
    } catch (e) {
      statusMessage.value = 'Logout error: $e';
      MessageUtils.showError(statusMessage.value);

      debugPrint('Logout error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransactionDetails(
      String transactionCode, cardType, amount) async {
    var settingController = Get.find<SettingController>();
    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'merchantCode': merchantResponse.value?.merchantCode,
        'transactionCode': transactionCode,
        'cardType': cardType,
        'amount': amount,
        "deviceNumber": settingController.serialNumber.value,
        'userId': await LocalStorageServices.getUserId(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      MessageUtils.showError(e.toString());
    }
  }
}
