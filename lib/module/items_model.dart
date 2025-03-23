class ItemsModel {
  final String id;
  final String name;
  final double price;
  final String availableQuantity;
  final String itemChannelNumber;
  final String itemCategory;

  // Constructor with required fields
  ItemsModel({
    required this.id,
    required this.name,
    required this.price,
    required this.availableQuantity,
    required this.itemChannelNumber,
    required this.itemCategory,
  });
}
