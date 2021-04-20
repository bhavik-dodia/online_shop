import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart.dart';
import '../services/api_service.dart';

/// Helps to manage Orders.
class OrdersHelper {
  /// Places an order using the api and saves it on the database.
  static placeOrder(
      Map<String, Cart> cartItems, double total, String address) async {
    try {
      final response = await APIService.makePostRequest(
        {
          'product_id': cartItems.keys,
          'total_products': cartItems.length.toString(),
        },
      );
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('Orders')
          .add({
        'id': json.decode(response.body)['responseID'],
        'amount': total,
        'address': address,
        'products': jsonDecode(jsonEncode(cartItems.values.toList())),
        'dateTime': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
