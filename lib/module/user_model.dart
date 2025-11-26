// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final bool success;
  final List<UserData> data;

  UserModel({
    required this.success,
    required this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        success: json["success"],
        data:
            List<UserData>.from(json["data"].map((x) => UserData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class UserData {
  final String id;
  final String belongingModel;
  final bool deviceIsOperating;
  final String deviceName;
  final int noOfChannel;
  final String password;
  final String phoneNumber;
  final String placementAddress;
  final String placementCity;
  final String placementLocation;
  final String serialNumber;
  final int storageCapacity;
  final String userEmail;
  final String userName;
  final bool isAdmin;
  final String apiKey;

  UserData({
    required this.id,
    required this.belongingModel,
    required this.deviceIsOperating,
    required this.deviceName,
    required this.noOfChannel,
    required this.password,
    required this.phoneNumber,
    required this.placementAddress,
    required this.placementCity,
    required this.placementLocation,
    required this.serialNumber,
    required this.storageCapacity,
    required this.userEmail,
    required this.userName,
    required this.isAdmin,
    required this.apiKey,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["id"],
        belongingModel: json["belongingModel"],
        deviceIsOperating: json["deviceIsOperating"],
        deviceName: json["deviceName"],
        noOfChannel: json["noOfChannel"],
        password: json["password"],
        phoneNumber: json["phoneNumber"],
        placementAddress: json["placementAddress"],
        placementCity: json["placementCity"],
        placementLocation: json["placementLocation"],
        serialNumber: json["serialNumber"],
        storageCapacity: json["storageCapacity"],
        userEmail: json["userEmail"],
        userName: json["userName"],
        isAdmin: json["isAdmin"],
        apiKey: json["apiKey"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "belongingModel": belongingModel,
        "deviceIsOperating": deviceIsOperating,
        "deviceName": deviceName,
        "noOfChannel": noOfChannel,
        "password": password,
        "phoneNumber": phoneNumber,
        "placementAddress": placementAddress,
        "placementCity": placementCity,
        "placementLocation": placementLocation,
        "serialNumber": serialNumber,
        "storageCapacity": storageCapacity,
        "userEmail": userEmail,
        "userName": userName,
        "isAdmin": isAdmin,
        "apiKey": apiKey,
      };
}
