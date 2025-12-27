import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newvendingmachine/NewMotorTest/motor_controller.dart';
import 'package:newvendingmachine/utils/message_utils.dart';

class TestMotor extends StatelessWidget {
  TestMotor({super.key});

  List<int> channelNumber = [101, 102, 201, 202, 301, 302, 401, 402];
  var motorController = Get.put(MotorController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motor Test"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
                itemCount: channelNumber.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  return TextButton(
                      onPressed: () {
                        if (!motorController.items
                            .contains(channelNumber[index])) {
                          motorController.items.add(channelNumber[index]);
                        } else {
                          MessageUtils.showWarning("Already added");
                        }
                      },
                      child: Text("Test Motor ${channelNumber[index]}"));
                }),
          ),
          ElevatedButton(
              onPressed: () {
                motorController.configureSerialPort();
              },
              child: const Text("Dispatch Items"))
        ],
      ),
    );
  }
}
