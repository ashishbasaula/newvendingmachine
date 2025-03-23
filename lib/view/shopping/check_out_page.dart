import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Helper/device_ui_helper.dart';
import 'package:newvendingmachine/controller/cart/cart_controller.dart';
import 'package:newvendingmachine/utils/colors_utils.dart';
import 'package:newvendingmachine/utils/message_utils.dart';
import 'package:newvendingmachine/utils/padding_utils.dart';
import 'package:newvendingmachine/view/shopping/components/checkout_product_card.dart';

class CheckOutPage extends StatelessWidget {
  CheckOutPage({super.key});

  final cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Order"),
      ),
      body: Padding(
        padding: PaddingUtils.SCREEN_PADDING,
        child: Obx(
          () => Column(
            children: [
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cartController.items.length,
                    itemBuilder: (context, index) {
                      return CheckoutProductCard(
                        cartItem: cartController.items[index],
                      );
                    }),
              ),
              Column(
                children: [
                  const Divider(),
                  Container(
                    padding: const EdgeInsets.all(18),
                    width: Get.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            Icons.shopping_cart_checkout,
                            size: 50,
                            color: VendingMachineColors.primaryColor,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\$ ${cartController.totalPrice.toStringAsFixed(2)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(color: Colors.black),
                              ),
                              Text(
                                "${cartController.items.length} goods selected",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.black),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: DeviceUiHelper.isNotMobile()
                                      ? const Size(200, 50)
                                      : const Size(100, 50),
                                  backgroundColor:
                                      VendingMachineColors.primaryColor),
                              onPressed: () {
                                if (cartController.items.isEmpty) {
                                  MessageUtils.showWarning(
                                      "No Items to checkout");
                                } else {
                                  showPaymentOptionsDialog(context);
                                }
                              },
                              child: Text(
                                "Pay",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Colors.white, fontSize: 20),
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void showPaymentOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // QR Code Icon
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.qr_code,
                          size: DeviceUiHelper.isNotMobile() ? 250 : 100,
                        ),
                        onPressed: () {
                          SmartDialog.showLoading(msg: "Wait while processing");
                          // motorController.configureSerialPort();
                        },
                      ),
                      const Text('QR Code')
                    ],
                  ),
                  // Card Payment Icon
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.credit_card,
                          size: DeviceUiHelper.isNotMobile() ? 250 : 100,
                        ),
                        onPressed: () {
                          SmartDialog.showLoading(msg: "Wait while processing");
                          // motorController.configureSerialPort();
                        },
                      ),
                      const Text('Card Payment')
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // QR Code Icon
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.card_membership_sharp,
                          size: DeviceUiHelper.isNotMobile() ? 250 : 100,
                        ),
                        onPressed: () {
                          SmartDialog.showLoading(msg: "Wait while processing");
                          // motorController.configureSerialPort();
                        },
                      ),
                      const Text('On Screen Payment')
                    ],
                  ),
                  // Card Payment Icon
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
