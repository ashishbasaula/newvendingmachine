class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String channelNumber;
  final String imageUrl;

  CartItem(
      {required this.id,
      required this.name,
      required this.price,
      required this.channelNumber,
      this.quantity = 1,
      required this.imageUrl});
}
