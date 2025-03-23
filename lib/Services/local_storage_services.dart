import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageServices {
  static String idKey = "uID";
  static String loginKey = "isLogin";

  static Future<void> storeUserId({required String userId}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(idKey, userId);
  }

  // this is for getting the user id
  static Future<String> getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(idKey) ?? "";
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
}
