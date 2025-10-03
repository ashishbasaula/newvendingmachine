import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Helper/device_ui_helper.dart';
import 'package:newvendingmachine/controller/PaymentController/payment_controller.dart';
import 'package:newvendingmachine/controller/Shipment/shipment_controller.dart';
import 'package:newvendingmachine/controller/cart/cart_controller.dart';
import 'package:newvendingmachine/utils/colors_utils.dart';
import 'package:newvendingmachine/utils/message_utils.dart';
import 'package:newvendingmachine/utils/padding_utils.dart';
import 'package:newvendingmachine/view/shopping/components/age_verification_page.dart';
import 'package:newvendingmachine/view/shopping/components/checkout_product_card.dart';

class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final cartController = Get.find<CartController>();
  final shipmentController = Get.find<ShipmentController>();
  final paymentController = Get.find<PaymentConroller>();
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
                              onPressed: () async {
                                if (cartController.items.isEmpty) {
                                  MessageUtils.showWarning(
                                      "No Items to checkout");
                                } else {
// check if the age verification is required else skip it

                                  bool isAgeVerificationRequired = false;

                                  for (var item in cartController.items) {
                                    if (item.ageLimt > 0) {
                                      isAgeVerificationRequired = true;
                                      break;
                                    }
                                  }

                                  if (!isAgeVerificationRequired) {
                                    await paymentController
                                        .handlePrepareForCheckout();
                                    if (paymentController
                                        .isPreparedForCheckout.value) {
                                      await paymentController.handleCheckout(
                                          paymentTitle:
                                              "Your Payment ${DateTime.now()}",
                                          totalPayment:
                                              cartController.totalPrice,
                                          totalItems:
                                              cartController.items.length,
                                          callBack: (value) {
                                            if (value) {
                                              shipmentController
                                                  .initialShipment();
                                            } else {
                                              MessageUtils.showError(
                                                  "Fail to checkout due to payment issue");
                                            }
                                          });
                                    } else {
                                      MessageUtils.showError(
                                          "Checkout is not initalized");
                                    }
                                  } else {
                                    // find the highest age requirement among items
                                    int highestAgeLimit = 0;
                                    for (var item in cartController.items) {
                                      if (item.ageLimt > highestAgeLimit) {
                                        highestAgeLimit = item.ageLimt;
                                      }
                                    }

                                    Get.to(() => AgeVerificationPage(
                                          age: highestAgeLimit,
                                          callBack: (isVerified) async {
                                            if (isVerified) {
                                              // continue with payment process
                                              await paymentController
                                                  .handlePrepareForCheckout();
                                              if (paymentController
                                                  .isPreparedForCheckout
                                                  .value) {
                                                await paymentController
                                                    .handleCheckout(
                                                        paymentTitle:
                                                            "Your Payment ${DateTime.now()}",
                                                        totalPayment:
                                                            cartController
                                                                .totalPrice,
                                                        totalItems:
                                                            cartController
                                                                .items.length,
                                                        callBack: (value) {
                                                          if (value) {
                                                            shipmentController
                                                                .initialShipment();
                                                          } else {
                                                            MessageUtils.showError(
                                                                "Fail to checkout due to payment issue");
                                                          }
                                                        });
                                              } else {
                                                MessageUtils.showError(
                                                    "Checkout is not initialized");
                                              }
                                            } else {
                                              MessageUtils.showWarning(
                                                  "Age verification failed. You must be at least $highestAgeLimit years old to buy these items.");
                                            }
                                          },
                                        ));
                                  }
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
                          // call this in production

                          // shipmentController.initialShipment();

// this is for the test
                          shipmentController.addOrderToDatabase();
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
                          // call this in production

                          // shipmentController.initialShipment();

// this is for the test
                          shipmentController.addOrderToDatabase();
                        },
                      ),
                      const Text('Card Payment')
                    ],
                  ),
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
