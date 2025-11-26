import 'package:flutter/material.dart';
import 'package:newvendingmachine/utils/colors_utils.dart';

class PurchaseDescription extends StatelessWidget {
  const PurchaseDescription({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: VendingMachineColors.primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "VVS vending ",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05, // Responsive font size
                    ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.contact_support,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "1. Select product  →  2. Check out  →  3. Swipe to pay  →  4. Collect items",
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontSize: screenWidth * 0.035, // Adjust text size
                ),
          ),
        ],
      ),
    );
  }
}
