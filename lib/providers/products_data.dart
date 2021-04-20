import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/api_service.dart';

/// Provides methods to manage products data.
class ProductsData extends ChangeNotifier {
  List<Product> _products = [];

  UnmodifiableListView get products => UnmodifiableListView(_products);

  /// Returns a product of a specific id.
  Product getProductFromId(String id) =>
      _products.firstWhere((product) => product.id == id);

  /// Fetches and sets the products from api.
  Future<void> fetchProducts() async {
    try {
      final response = await APIService.makeGetRequest();
      final data = jsonDecode(response.body) as List;
      _products = data.map((product) => Product.fromJson(product)).toList();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
