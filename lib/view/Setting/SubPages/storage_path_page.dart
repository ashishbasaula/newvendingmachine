import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/Device/setting_controller.dart';

class StoragePathsPage extends StatelessWidget {
  StoragePathsPage({super.key});
  final settingController = Get.find<SettingController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Paths'),
      ),
      body: Obx(
        () => settingController.isStroagePathLoaded.isFalse
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.sd_storage),
                    title: const Text('SD Card Path'),
                    subtitle: Text(settingController.sdCardPath.value),
                    onTap: () {
                      // Action to view or manage SD Card storage
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.usb),
                    title: const Text('USB Storage Path'),
                    subtitle: Text(settingController.usbPath.value),
                    onTap: () {
                      // Action to view or manage USB storage
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.memory),
                    title: const Text('Internal Storage Path'),
                    subtitle: const Text('/storage/emulated/0'),
                    onTap: () {
                      // Action to view or manage internal storage
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
