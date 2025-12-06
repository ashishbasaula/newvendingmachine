import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Helper/price_format_helper.dart';
import 'package:newvendingmachine/controller/cart/cart_controller.dart';
import 'package:newvendingmachine/module/cart_model.dart';
import 'package:newvendingmachine/utils/message_utils.dart';

class CheckoutProductCard extends StatelessWidget {
  final CartItem cartItem;

  CheckoutProductCard({
    super.key,
    required this.cartItem,
  });

  final cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double imageSize = constraints.maxWidth * 0.25;
        double fontSize = constraints.maxWidth * 0.045;
        double priceFontSize = constraints.maxWidth * 0.055;
        double iconSize = constraints.maxWidth * 0.06;

        // Calculate tax amount
        double taxAmount = (cartItem.price * cartItem.taxPercentage!) / 100;
        double totalWithTax = cartItem.price + taxAmount;

        return Card(
          elevation: 4,
          color: Colors.white,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Image with enhanced styling
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      cartItem.imageUrl,
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: imageSize,
                          width: imageSize,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: imageSize * 0.4,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: constraints.maxWidth * 0.04),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cartItem.name,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: fontSize,
                                  color: Colors.black87,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cartItem.itemCategory,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.blue.shade700,
                                    fontSize: fontSize * 0.7,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: constraints.maxWidth * 0.03),

                // Price and Quantity Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Base Price
                    Text(
                      "\$${PriceFormatHelper.formatPrice(cartItem.price)}",
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: priceFontSize,
                                color: Colors.green.shade700,
                              ),
                    ),

                    // Tax Information
                    if (cartItem.taxPercentage! > 0) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              size: fontSize * 0.6,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "Tax: ${cartItem.taxPercentage}%",
                              style: TextStyle(
                                fontSize: fontSize * 0.6,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "=${PriceFormatHelper.formatPrice(totalWithTax)}",
                        style: TextStyle(
                          fontSize: fontSize * 0.65,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    SizedBox(height: constraints.maxWidth * 0.015),

                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: iconSize,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              cartController.decrementItemQuantity(cartItem.id);
                            },
                            icon: Icon(
                              Icons.remove,
                              color: Colors.red.shade600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              cartController
                                  .getItemQuantity(cartItem.id)
                                  .toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: fontSize * 0.9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                            ),
                          ),
                          IconButton(
                            iconSize: iconSize,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final item = cartController.items
                                  .where((e) => e.id == cartItem.id)
                                  .first;
                              if (item.inventoryThreasHold <=
                                  cartController.getItemQuantity(cartItem.id)) {
                                MessageUtils.showWarning(
                                    "Inventory Threshold Reached");
                                return;
                              }
                              cartController.incrementItemQuantity(cartItem.id);
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
