import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Helper/helper_controller.dart';
import 'package:newvendingmachine/utils/message_utils.dart';
import 'package:newvendingmachine/view/Payment/super_payment.dart';
import 'package:newvendingmachine/view/barcodeScanning/barcode_scanner.dart';
import 'SubPages/advance_option_page.dart';
import 'SubPages/device_management.dart';
import 'SubPages/display_setting_page.dart';
import 'SubPages/gipo_control_page.dart';
import 'SubPages/network_setting_page.dart';
import 'SubPages/power_management_page.dart';
import 'SubPages/storage_path_page.dart';

import 'SubPages/system_info.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController searchController = TextEditingController();
  var helperController = Get.find<HelperController>();
  List<CategoryItems> categories = [
    CategoryItems(
        name: 'Payment Setting',
        iconData: Icons.payment,
        onTap: () {
          Get.to(() => PaymentSettingsPage());
        }),
    CategoryItems(
        name: 'Barcode Setting',
        iconData: Icons.barcode_reader,
        onTap: () {
          Get.to(() => ScannerHomePage());
        }),
    CategoryItems(
        name: 'System Info',
        iconData: Icons.info,
        onTap: () {
          Get.to(() => const SystemInfo());
        }),
    CategoryItems(
        name: 'Device Management',
        iconData: Icons.devices,
        onTap: () {
          Get.to(() => DeviceManagementPage());
        }),
    CategoryItems(
        name: 'Display Settings',
        iconData: Icons.display_settings,
        onTap: () {
          Get.to(() => const DisplaySettingsPage());
        }),
    CategoryItems(
        name: 'Network Settings',
        iconData: Icons.network_check,
        onTap: () {
          Get.to(() => const NetworkSettingsPage());
        }),
    CategoryItems(
        name: 'Storage Paths',
        iconData: Icons.sd_storage,
        onTap: () {
          Get.to(() => StoragePathsPage());
        }),
    CategoryItems(
        name: 'Power Management',
        iconData: Icons.power_settings_new,
        onTap: () {
          Get.to(() => const PowerManagementPage());
        }),
    CategoryItems(
        name: 'Update App',
        iconData: Icons.system_update,
        isdifferentColor: true,
        onTap: () {
          // print('GPIO Controls tapped');
          Get.to(() => const GPIOControlsPage());
        }),
    CategoryItems(
        name: 'Advanced Options',
        iconData: Icons.build_circle,
        onTap: () {
          // print('Advanced Options tapped');
          Get.to(() => const AdvancedOptionsPage());
        }),
  ];

  List<CategoryItems> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    filteredCategories = categories; // Initialize with all categories
    searchController.addListener(() {
      filterCategories();
    });
  }

  void filterCategories() {
    List<CategoryItems> results = [];
    if (searchController.text.isEmpty) {
      results = categories;
    } else {
      results = categories
          .where((item) => item.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredCategories = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search", // Placeholder text
                  prefixIcon: const Icon(Icons.search), // Search icon
                  fillColor: Colors.black12, // Background color
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                    borderSide: BorderSide.none, // No border
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                itemCount: filteredCategories.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(filteredCategories[index].iconData),
                    title: Text(
                      filteredCategories[index].name,
                      style: filteredCategories[index].isdifferentColor != null
                          ? const TextStyle(color: Colors.green)
                          : null,
                    ),
                    onTap: () {
                      filteredCategories[index].onTap();
                    }, // Implement onTap callback
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Sumup Email"),
                subtitle: const Text("Sumup@gmail.com"),
                trailing: const Icon(Icons.copy),
                onTap: () {
                  copyToClipboard(helperController.sumupEmail.string);
                  MessageUtils.showSuccessGreen("Copied sucessfully");
                },
              ),
              ListTile(
                leading: const Icon(Icons.password),
                title: const Text("Sumup password"),
                subtitle: Text("*" * 4),
                trailing: const Icon(Icons.copy),
                onTap: () {
                  copyToClipboard(helperController.sumupPassword.string);
                  MessageUtils.showSuccessGreen("Copied sucessfully");
                },
              ),
              ElevatedButton(
                  onPressed: () {
                    helperController.canShowLogoutButton.value = true;
                    MessageUtils.showSuccess("SucessFully Enabled Pin");
                  },
                  child: const Text("Show Pin Btton"))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void copyToClipboard(String textToCopy) {
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {});
  }
}

class CategoryItems {
  final String name;
  final IconData iconData;
  final Function onTap;
  final bool? isdifferentColor;

  CategoryItems(
      {required this.name,
      required this.iconData,
      required this.onTap,
      this.isdifferentColor});
}
