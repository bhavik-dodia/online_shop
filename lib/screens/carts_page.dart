import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/dialog_helper.dart';
import '../providers/carts_data.dart';
import '../widgets/carts/cart_item.dart';
import '../widgets/orders/order_bar.dart';

/// Displays page with options for managing cart.
class CartsPage extends StatelessWidget {
  static final String routeName = '/cats-page';

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            color: Colors.redAccent,
            onPressed: Provider.of<CartsData>(context).cartItems.isEmpty
                ? null
                : () async {
                    var clear = await DialogHelper.showAlertDialog(
                      context,
                      'Are you sure?',
                      'All items from cart will be removed. This action can\'t be undone.',
                    );
                    if (clear == null) return;
                    if (clear) {
                      Provider.of<CartsData>(context, listen: false).clear();
                      Navigator.of(context).pop();
                    }
                  },
          ),
        ],
      ),
      body: Consumer<CartsData>(
        builder: (context, cartsData, child) {
          return cartsData.cartItems.isEmpty
              ? child
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: cartsData.cartsCount,
                  itemBuilder: (context, index) => CartItem(
                    cart: cartsData.cartItems.values.toList()[index],
                    productId: cartsData.cartItems.keys.toList()[index],
                  ),
                );
        },
        child: isPortrait
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildChildren,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buildChildren,
              ),
      ),
      bottomNavigationBar: OrderBar(),
    );
  }

  List<Widget> get buildChildren {
    return [
      AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.asset(
          'images/empty_cart.png',
        ),
      ),
      const Text(
        'Your cart is empty!!!',
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    ];
  }
}
