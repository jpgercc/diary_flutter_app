import 'package:flutter/material.dart';
import 'package:fashion_store_app/models/product.dart';

class CartItem {
  final Product product;
  final String selectedSize;
  final Color selectedColor;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  // Unique identifier for the same product with same size and color
  String get uniqueId => '${product.id}-${selectedSize}-${selectedColor.value}';
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product, String selectedSize, Color selectedColor) {
    final uniqueId = '${product.id}-$selectedSize-${selectedColor.value}';

    if (_items.containsKey(uniqueId)) {
      _items.update(
        uniqueId,
            (existingCartItem) => CartItem(
          product: existingCartItem.product,
          selectedSize: existingCartItem.selectedSize,
          selectedColor: existingCartItem.selectedColor,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        uniqueId,
            () => CartItem(
          product: product,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String uniqueId) {
    _items.remove(uniqueId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}