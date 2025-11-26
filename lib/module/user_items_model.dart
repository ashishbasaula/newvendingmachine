class UserItemModel {
  final String id;
  final int ageLimit;
  final int channelNo;
  final double costPrice;
  final String goodsImage;
  final String goodsName;
  final int goodsNumber;
  final String goodsSpecification;
  final String goodsType;
  final String inventory;
  final int inventoryThreshold;
  final double sellingPrice;

  UserItemModel({
    required this.id,
    required this.ageLimit,
    required this.channelNo,
    required this.costPrice,
    required this.goodsImage,
    required this.goodsName,
    required this.goodsNumber,
    required this.goodsSpecification,
    required this.goodsType,
    required this.inventory,
    required this.inventoryThreshold,
    required this.sellingPrice,
  });

  // Factory constructor to create an instance from Firestore document
  factory UserItemModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return UserItemModel(
      id: docId ?? "0d34",
      ageLimit: data['ageLimit'] ?? 0,
      channelNo: data['channelNo'] ?? 0,
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      goodsImage: data['goodsImage'] ?? '',
      goodsName: data['goodsName'] ?? '',
      goodsNumber: data['goodsNumber'] ?? 0,
      goodsSpecification: data['goodsSpecification'] ?? '',
      goodsType: data['goodsType'] ?? '',
      inventory: data['inventory'] ?? '',
      inventoryThreshold: data['inventoryThreshold'] ?? 0,
      sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
    );
  }

  // Convert instance to Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      "ageLimit": ageLimit,
      "channelNo": channelNo,
      "costPrice": costPrice,
      "goodsImage": goodsImage,
      "goodsName": goodsName,
      "goodsNumber": goodsNumber,
      "goodsSpecification": goodsSpecification,
      "goodsType": goodsType,
      "inventory": inventory,
      "inventoryThreshold": inventoryThreshold,
      "sellingPrice": sellingPrice,
    };
  }
}
