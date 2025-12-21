import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:newvendingmachine/Services/local_storage_services.dart';
import 'package:newvendingmachine/const/const.dart';
import 'package:newvendingmachine/controller/PaymentController/payment_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sumup/sumup.dart';

class SumupServices extends GetxController {
  String? accessToken;
  String? refreshToken;
  int expiresIn = 3600;
  DateTime? lastRefreshed;
  Timer? _sumupLoginTimer;

  @override
  void onInit() {
    super.onInit();
    // initializeSumup();
  }

  @override
  void onClose() {
    _sumupLoginTimer?.cancel();
    _sumupLoginTimer = null;
    super.onClose();
  }

  /// Initialize SumUp login and token handling
  void initializeSumup() async {
    await loadStoredTokens();

    if (accessToken != null) {
      // Immediately ensure token is valid and log in
      await ensureValidTokenAndLogin();

      // Start periodic refresh
      startPeriodicLoginTimer();
    } else {
      log("No access token found, user needs to login.");
    }
  }

  /// Load tokens from local storage
  Future<void> loadStoredTokens() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    accessToken = pref.getString('accessToken');
    refreshToken = pref.getString('refreshToken');
    final lastRefreshedStr = pref.getString('lastRefreshed');
    if (lastRefreshedStr != null) {
      lastRefreshed = DateTime.tryParse(lastRefreshedStr);
    }
  }

  /// Ensure token is valid and log in to SumUp
  Future<void> ensureValidTokenAndLogin() async {
    const String affiliateKey = PaymentConstant.AFFELIATED_KEY;

    final token = await getValidAccessToken();
    if (token != null) {
      try {
        var paymntController = Get.find<PaymentConroller>();
        if (!paymntController.isSdkInitialized.value) {
          await Sumup.init(affiliateKey);
        }
        final result = await Sumup.loginWithToken(token);
        log("SumUp login successful: ${result.message?['loginResult']}");
        paymntController.isLoginSuccess.value = true;
      } catch (e) {
        log("Error logging in with SumUp token: $e");
      }
    }
  }

  /// Start a timer to refresh token and re-login periodically
  void startPeriodicLoginTimer() {
    _sumupLoginTimer?.cancel();
    _sumupLoginTimer = Timer.periodic(const Duration(minutes: 59), (_) async {
      await ensureValidTokenAndLogin();
      log("SumUp login refreshed every 5 minutes.");
    });
  }

  /// Exchange authorization code for access token
  Future<void> exchangeAuthCode(String code) async {
    final url = Uri.parse('https://manage.vvsvend.com/api/sumuptoken');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storeTokensFromResponse(data);
        accessToken = data['accessToken'];
        await Sumup.loginWithToken(accessToken!);
        var paymntController = Get.find<PaymentConroller>();
        paymntController.isLoginSuccess.value = true;
        startPeriodicLoginTimer();
      } else {
        log("Failed to get token: ${response.statusCode}");
        log(response.body);
      }
    } catch (e) {
      log("Error exchanging auth code: $e");
    }
  }

  /// Refresh access token
  Future<void> refreshAccessToken() async {
    if (refreshToken == null) {
      log("No refresh token stored.");
      return;
    }

    final url = Uri.parse('https://manage.vvsvend.com/api/sumuptoken');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storeTokensFromResponse(data);
        log("Token refreshed successfully.");
      } else {
        log("Failed to refresh token: ${response.statusCode}");
        log(response.body);
      }
    } catch (e) {
      log("Error refreshing token: $e");
    }
  }

  /// Store tokens locally
  Future<void> storeTokensFromResponse(Map<String, dynamic> data) async {
    accessToken = data['accessToken'];
    refreshToken = data['refreshToken'];
    expiresIn = data['expiresIn'];
    lastRefreshed = DateTime.now();
    log("Storing new tokens. AccessToken: $accessToken");
    log("RefreshToken: $refreshToken");
    await LocalStorageServices.storeAccessToken(token: accessToken!);
    await LocalStorageServices.storeRefreshToken(token: refreshToken!);
    await LocalStorageServices.storeLastRefreshed(lastRefreshed!);
  }

  /// Check whether token is expired or near expiry
  bool isTokenExpired() {
    if (lastRefreshed == null || expiresIn == null) return true;

    final expireTime = lastRefreshed!.add(Duration(seconds: expiresIn!));
    // 5 minutes buffer
    final safeExpire = expireTime.subtract(const Duration(minutes: 5));

    log("Token expires at: $expireTime, safeExpire: $safeExpire, now: ${DateTime.now()}");

    return DateTime.now().isAfter(safeExpire);
  }

  /// Returns guaranteed valid access token
  Future<String?> getValidAccessToken() async {
    if (accessToken == null) {
      log("No access token – user is not logged in.");
      return null;
    }

    if (isTokenExpired()) {
      log("Token expired or about to expire. Refreshing...");
      await refreshAccessToken();
    }

    return accessToken;
  }

  /// Cancel the periodic SumUp login timer manually
  void cancelSumupTimer() {
    _sumupLoginTimer?.cancel();
    _sumupLoginTimer = null;
    log("SumUp login timer cancelled.");
  }
}
