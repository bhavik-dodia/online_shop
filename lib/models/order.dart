import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'cart.dart';

/// Order data model.
class Order {
  final String id, address;
  final double amount;
  final DateTime dateTime;
  final List<Cart> products;

  Order({
    @required this.id,
    @required this.amount,
    @required this.address,
    @required this.dateTime,
    @required this.products,
  });

  /// Converts Order object into json.
  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'address': address,
        'products': jsonDecode(jsonEncode(products)),
        'dateTime': dateTime.toIso8601String(),
      };

  /// Creates Order object from json.
  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        amount: json['amount'],
        address: json['address'],
        dateTime: DateTime.parse(json['dateTime']),
        products: (json['products'] as List)
            .map((cart) => Cart.fromJson(cart))
            .toList(),
      );
}
