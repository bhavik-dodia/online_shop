import 'package:flutter/foundation.dart';

/// Product data model.
class Product {
  final String id, name, shortDescription, longDescription, imageUrl;
  final int shippingCharge, tax;
  final double price;

  Product({
    @required this.id,
    @required this.tax,
    @required this.name,
    @required this.price,
    @required this.imageUrl,
    @required this.shippingCharge,
    @required this.longDescription,
    @required this.shortDescription,
  });

  /// Converts Product object into json.
  Map<String, dynamic> toJson() => {
        'id': id,
        'tax': tax,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'shippingCharge': shippingCharge,
        'longDescription': longDescription,
        'shortDescription': shortDescription,
      };

  /// Creates Product object from json.
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        tax: json['tax'],
        id: json['productId'],
        name: json['productName'],
        imageUrl: json['productImage'],
        shippingCharge: json['shippingCharge'],
        price: json['productPrice'].toDouble(),
        longDescription: json['longDescription'],
        shortDescription: json['shortDescription'],
      );
}
