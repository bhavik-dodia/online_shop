import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../../widgets/orders/order_item.dart';

/// Displays page with glimpse of all the orders.
class OrdersPage extends StatelessWidget {
  static const routeName = '/orders-page';

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(title: const Text('Your Orders')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection('Orders')
            .orderBy('dateTime', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildEmptyPage(isPortrait);
          } else {
            final docs = snapshot.data.docs;
            return docs.isEmpty
                ? buildEmptyPage(isPortrait)
                : ListView.builder(
                    padding: const EdgeInsets.all(5.0),
                    physics: const BouncingScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) => OrderItem(
                      order: Order.fromJson(docs[index].data()),
                      id: docs[index].id,
                    ),
                  );
          }
        },
      ),
    );
  }

  /// Returns page to show when no orders are available.
  Widget buildEmptyPage(bool isPortrait) {
    return Column(
      children: [
        Expanded(
          child: isPortrait
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildChildren,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: buildChildren,
                ),
        ),
      ],
    );
  }

  List<Widget> get buildChildren {
    return [
      AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.asset(
          'images/orders.png',
        ),
      ),
      const Text(
        'Your orders will appear here!!',
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    ];
  }
}
