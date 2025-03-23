import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Device/setting_controller.dart';

class DeviceManagementPage extends StatelessWidget {
  DeviceManagementPage({super.key});
  final settingController = Get.find<SettingController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Reboot Device'),
            onTap: () => _confirmAction(context, 'Reboot', () {
              settingController.deviceManagement(index: 0);
              // print("Hello")
            }),
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: const Text('Shutdown Device'),
            onTap: () => _confirmAction(context, 'Shutdown', () {
              settingController.deviceManagement(index: 1);
            }),
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('System Update'),
            onTap: () => _confirmAction(context, 'Update System', () {
              settingController.deviceManagement(index: 2);
            }),
          ),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String action, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action the device?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _performAction(context, action, onConfirm);
              },
            ),
          ],
        );
      },
    );
  }

  void _performAction(BuildContext context, String action, Function onConfirm) {
    // Placeholder for performing the action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action in progress...'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Implement the actual reboot, shutdown, or update functionality here
    onConfirm();
  }
}
