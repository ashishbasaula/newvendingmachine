import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageServices {
  static String idKey = "uID";
  static String deviceId = "deviceid";
  static String loginKey = "isLogin";

  static Future<void> storeUserId({required String userId}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(idKey, userId);
  }

  static Future<void> storeDeviceId({required String myId}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(deviceId, myId);
  }

  // this is for getting the user id
  static Future<String> getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(idKey) ?? "";
  }

  static Future<String> getDeviceId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(deviceId) ?? "";
  }

  static Future<void> storeUserLoginStatus({required bool isLogin}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(loginKey, isLogin);
  }

  // this is for getting the user login status
  static Future<bool> getUserLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(loginKey) ?? false;
  }

  static Future<void> storeAccessToken({required String token}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("accessToken", token);
  }

  static Future<String> getAccessToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("accessToken") ?? "";
  }

  static Future<void> storeRefreshToken({required String token}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("refreshToken", token);
  }

  static Future<String> getRefreshToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("refreshToken") ?? "";
  }

  static Future<void> storeLastRefreshed(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("lastRefreshed", time.toIso8601String());
  }
}
