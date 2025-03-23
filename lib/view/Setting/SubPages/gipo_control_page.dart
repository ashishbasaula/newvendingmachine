import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/controller/Device/gpoi_controller.dart';

class GPIOControlsPage extends StatelessWidget {
  const GPIOControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GPIOController gpioController = Get.put(GPIOController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPIO Controls'),
      ),
      body: Obx(() => ListView.builder(
            itemCount: gpioController.gpios.length,
            itemBuilder: (context, index) {
              GPIO gpio = gpioController.gpios[index];
              return Card(
                child: ListTile(
                  title: Text('GPIO ${gpio.pin}'),
                  subtitle: Text(
                      'Direction: ${gpio.direction}, Level: ${gpio.level}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () =>
                        _showGPIOSettingsPanel(context, gpio, gpioController),
                  ),
                ),
              );
            },
          )),
    );
  }

  void _showGPIOSettingsPanel(
      BuildContext context, GPIO gpio, GPIOController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: <Widget>[
              ListTile(
                title: const Text('Set Direction'),
                trailing: DropdownButton<String>(
                  value: gpio.direction,
                  onChanged: (newValue) {
                    controller.setGpioDirection(gpio.pin, newValue!);
                    Navigator.pop(context);
                  },
                  items: <String>['Input', 'Output']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              ListTile(
                title: const Text('Set Level'),
                trailing: DropdownButton<String>(
                  value: gpio.level,
                  onChanged: (newValue) {
                    controller.setGpioValue(gpio.pin, newValue!);
                    Navigator.pop(context);
                  },
                  items: <String>['High', 'Low']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
