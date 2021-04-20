import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/cart.dart';
import '../models/product.dart';

/// Provides methods to manage carts data.
class CartsData extends ChangeNotifier {
  Map<String, Cart> _cartItems = {};

  Map<String, Cart> get cartItems => _cartItems;

  int get cartsCount => _cartItems.length;

  CollectionReference get collectionReference => FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection('Cart Items');

  /// Returns grand total of prices of all the products in the cart (inclusive of all taxes).
  double get totalAmount {
    var total = 0.0;
    _cartItems.forEach((_, cartItem) => total += (cartItem.price +
            cartItem.shippingCharge +
            cartItem.price * cartItem.tax / 100) *
        cartItem.quantity);
    return total;
  }

  /// Fetches and sets the cart items from database.
  void loadCartItems() async {
    final snapshot = await collectionReference.get();
    if (snapshot.docs.isEmpty) {
      _cartItems.clear();
      notifyListeners();
      return;
    }
    _cartItems = {
      for (var item
          in snapshot.docs.map((item) => Cart.fromJson(item.data())).toList())
        item.id: item
    };
    notifyListeners();
  }

  /// Saves cart items on the database.
  void saveCartItems() {
    if (_cartItems.isEmpty) {
      clear();
      return;
    }
    (jsonDecode(jsonEncode(_cartItems.values.toList())) as List)
        .forEach((item) => collectionReference.doc(item['id']).set(item));
  }

  /// Inserts new product into cart and updates its quantity if already available.
  void addToCart(Product product, {int quantity: 1}) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems.update(
        product.id,
        (existingCart) {
          if (existingCart.quantity + quantity > 8) {
            throw Exception('Quantity limit exceeded!!!');
          }
          return Cart(
            id: existingCart.id,
            tax: existingCart.tax,
            name: existingCart.name,
            price: existingCart.price,
            imageUrl: existingCart.imageUrl,
            quantity: existingCart.quantity + quantity,
            shippingCharge: existingCart.shippingCharge,
          );
        },
      );
    } else {
      _cartItems.putIfAbsent(
        product.id,
        () => Cart(
          id: product.id,
          tax: product.tax,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          shippingCharge: product.shippingCharge,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  /// Updates quantity of a specific product.
  void updateQuantity(String productId, int quantity) {
    _cartItems.update(
      productId,
      (existingCart) => Cart(
        id: existingCart.id,
        tax: existingCart.tax,
        name: existingCart.name,
        price: existingCart.price,
        imageUrl: existingCart.imageUrl,
        shippingCharge: existingCart.shippingCharge,
        quantity: quantity,
      ),
    );
    notifyListeners();
  }

  /// Deletes specific product from cart.
  void removeFromCart(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }

  /// Deletes all products from cart.
  void clear() {
    collectionReference.get().then(
          (snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete()),
        );
    _cartItems.clear();
    notifyListeners();
  }
}
