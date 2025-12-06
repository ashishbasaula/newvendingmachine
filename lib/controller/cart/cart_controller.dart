import 'package:get/get.dart';
import 'package:newvendingmachine/module/cart_model.dart';

class CartController extends GetxController {
  final RxList<CartItem> _items = <CartItem>[].obs;

  List<CartItem> get items =>
      _items.toList(); // Provides a copy to prevent external modifications.

  // Add item to cart
  void addItem(CartItem item) {
    // Search for the item by ID, and increment quantity if found.

    var existingItem =
        _items.firstWhereOrNull((element) => element.id == item.id);
    if (existingItem != null) {
      existingItem.quantity++;
    } else {
      _items.add(item);
    }
    _items.refresh(); // Notify listeners about the update.
  }

  // Remove item from cart
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _items.refresh(); // Notify listeners about the update.
  }

  double get totalTax {
    return _items.fold(0.0, (sum, item) {
      double itemTotal = item.price * item.quantity;
      double itemTax = (itemTotal * item.taxPercentage!) / 100;
      return sum + itemTax;
    });
  }

  // Get total price
  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  // Get total price (including tax)
  double get totalPrice => subtotal + totalTax;

  // Checkout method
  void checkout() {
    if (_items.isNotEmpty) {
      print("Checkout with total: $totalPrice");
      _items.clear(); // Clear the cart after checkout.
      _items.refresh(); // Notify listeners about the update.
    }
  }

  // Check if item is in the cart
  bool isItemInCart(String id) {
    return _items.any((item) => item.id == id);
  }

  // Increment item quantity
  void incrementItemQuantity(String id) {
    var item = _items.firstWhereOrNull((element) => element.id == id);
    if (item != null) {
      item.quantity++;
      _items.refresh(); // Notify listeners about the update.
    }
  }

  // Decrement item quantity
  void decrementItemQuantity(String id) {
    var item = _items.firstWhereOrNull((element) => element.id == id);
    if (item != null && item.quantity > 1) {
      item.quantity--;
      _items.refresh(); // Notify listeners about the update.
    } else {
      removeItem(id);
      _items.refresh();
    }
  }

  // Get item quantity
  int getItemQuantity(String id) {
    CartItem? item = _items.firstWhereOrNull((element) => element.id == id);
    return item?.quantity ?? 0; // Return 0 if the item is not found
  }

  // for clearing the cart items
  void cleareCartItems() {
    _items.clear();
    _items.refresh();
  }
}
