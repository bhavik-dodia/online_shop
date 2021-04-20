import 'package:flutter/foundation.dart';

/// Cart data model.
class Cart {
  final double price;
  final String id, name, imageUrl;
  final int quantity, shippingCharge, tax;

  Cart({
    @required this.id,
    @required this.tax,
    @required this.name,
    @required this.price,
    @required this.imageUrl,
    @required this.quantity,
    @required this.shippingCharge,
  });

  /// Converts Cart object into json.
  Map<String, dynamic> toJson() => {
        'id': id,
        'tax': tax,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'shippingCharge': shippingCharge,
      };

  /// Creates Cart object from json.
  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json['id'],
        tax: json['tax'],
        name: json['name'],
        price: json['price'],
        imageUrl: json['imageUrl'],
        quantity: json['quantity'],
        shippingCharge: json['shippingCharge'],
      );
}
