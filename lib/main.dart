import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/Services/local_storage_services.dart';
import 'package:newvendingmachine/controller/Auth/auth_controller.dart';
import 'package:newvendingmachine/controller/Device/setting_controller.dart';
import 'package:newvendingmachine/view/Auth/login_screen.dart';
import 'package:newvendingmachine/view/Dashboard/dashboard_page.dart';

import 'controller/cart/cart_controller.dart';
import 'controller/items/items_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  Get.put(CartController());
  Get.put(ItemsController());
  Get.put(SettingController());

  final isLogin = await LocalStorageServices.getUserLoginStatus();
  runApp(MyApp(
    isLogin: isLogin,
  ));
}

class MyApp extends StatelessWidget {
  final bool isLogin;
  const MyApp({super.key, required this.isLogin});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorObservers: [FlutterSmartDialog.observer],
      // here
      builder: FlutterSmartDialog.init(),
      home: isLogin ? const DashboardPage() : const LoginScreen(),
    );
  }
}
