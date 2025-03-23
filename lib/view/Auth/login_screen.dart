import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:newvendingmachine/controller/Auth/auth_controller.dart';
import 'package:newvendingmachine/utils/colors_utils.dart';
import 'package:newvendingmachine/utils/padding_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: PaddingUtils.SCREEN_PADDING,
        child: Column(
          children: [
            LottieBuilder.asset("assets/animation/login_page_animation.json"),
            Text(
              "Hey there!",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: VendingMachineColors.primaryColor, fontSize: 50),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "We’re thrilled to see you. Start your seamless vending journey with us by tapping below. Welcome aboard!",
              style: Theme.of(context).textTheme.bodyLarge!,
            ),
            const Spacer(),
            // this is for the login button
            InkWell(
              onTap: () {
                authController.userAuth();
              },
              child: Container(
                width: Get.width, // This will take full width of the screen
                height: 80, // Fixed height for the button
                decoration: BoxDecoration(
                  color: VendingMachineColors.buttonColor, // Background color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Center the icon and text horizontally
                  children: [
                    // Space between icon and text
                    const SizedBox(),

                    Text(
                      "Login",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold), // Text style
                    ),

                    const Padding(
                      padding: EdgeInsets.only(right: 50),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
