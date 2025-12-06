class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String channelNumber;
  final String imageUrl;
  final int inventoryThreasHold;
  final String itemCategory;
  final int ageLimt;
  final double? taxPercentage;

  CartItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.channelNumber,
      required this.inventoryThreasHold,
      this.quantity = 1,
      required this.imageUrl,
      required this.itemCategory,
      required this.ageLimt,
      required this.taxPercentage});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}
