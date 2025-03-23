import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  List<CategoryItems> categories = [
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
        name: 'GPIO Controls',
        iconData: Icons.settings_input_component,
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(filteredCategories[index].iconData),
                    title: Text(filteredCategories[index].name),
                    onTap: () {
                      filteredCategories[index].onTap();
                    }, // Implement onTap callback
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class CategoryItems {
  final String name;
  final IconData iconData;
  final Function onTap;

  CategoryItems(
      {required this.name, required this.iconData, required this.onTap});
}
