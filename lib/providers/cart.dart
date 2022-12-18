import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.price,
    required this.quantity,
    required this.title,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get noOfItems {
    return _items.length;
  }

  void removeItem(String id) {
    _items.removeWhere((key, value) => value.id == id);
    notifyListeners();
  }

  double get totalPrice {
    double total = 0.0;
    _items.forEach(
        (key, cartItem) => total += cartItem.price * cartItem.quantity);
    return total;
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existing) => CartItem(
                id: existing.id,
                price: existing.price,
                quantity: existing.quantity + 1,
                title: existing.title,
              ));
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          price: price,
          quantity: 1,
          title: title,
        ),
      );
    }
    notifyListeners();
  }

  void removeSingle(String productId) {
    if (_items[productId]!.quantity <= 1)
      _items.remove(productId);
    else
      _items.update(
        productId,
        (existing) => CartItem(
            id: existing.id,
            price: existing.price,
            quantity: existing.quantity - 1,
            title: existing.title),
      );

  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
