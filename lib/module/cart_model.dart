class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String channelNumber;
  final String imageUrl;
  final int inventoryThreasHold;
  final String itemCategory;

  CartItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.channelNumber,
      required this.inventoryThreasHold,
      this.quantity = 1,
      required this.imageUrl,
      required this.itemCategory});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}
