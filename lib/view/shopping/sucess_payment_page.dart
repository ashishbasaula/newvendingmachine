import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:newvendingmachine/utils/colors_utils.dart';
import 'package:newvendingmachine/utils/padding_utils.dart';

class SucessPaymentPage extends StatelessWidget {
  const SucessPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment Result Page",
          style:
              Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: PaddingUtils.SCREEN_PADDING,
        child: Column(
          children: [
            LottieBuilder.asset("assets/animation/paymentSucess.json"),
            Text(
              "Remember to collect the items at store !!",
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: VendingMachineColors.primaryColor,
                    minimumSize: Size(Get.width / 2.5, 50)),
                onPressed: () {
                  // Get.offAll(() => const DashboardScreen());
                },
                child: Text(
                  "Return Home ",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
