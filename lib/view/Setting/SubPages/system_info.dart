import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Device/setting_controller.dart';

class SystemInfo extends StatefulWidget {
  const SystemInfo({super.key});

  @override
  State<SystemInfo> createState() => _SystemInfoState();
}

class _SystemInfoState extends State<SystemInfo> {
  final settingController = Get.find<SettingController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Information'),
      ),
      body: Obx(
        () => settingController.isSystemInfoLoaded.isFalse
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.memory),
                      title: const Text('API Version'),
                      subtitle: Text(settingController.apiVersion.value),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.smartphone),
                      title: const Text('Device Model'),
                      subtitle: Text(settingController.deviceModel.value),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('System Storage'),
                      subtitle:
                          Text('${settingController.systemStorage.value}B'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.build),
                      title: const Text('CPU Model'),
                      subtitle: Text(settingController.cpuModel.value),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.thermostat_outlined),
                      title: const Text('CPU Temperature'),
                      subtitle: Text('${settingController.cpuTemp.value}°C'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.numbers),
                      title: const Text('Serial Number'),
                      subtitle: Text(settingController.serialNumber.value),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
