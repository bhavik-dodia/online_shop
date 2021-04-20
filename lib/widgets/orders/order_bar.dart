import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants_helper.dart';
import '../../providers/carts_data.dart';
import '../../screens/orders/shipping_details_page.dart';

/// Displays the grand total of the cart items and an option to provide shipping details.
class OrderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartsData = Provider.of<CartsData>(context);
    return BottomAppBar(
      color: theme.canvasColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              'Total Amount: ',
              style: TextStyle(fontSize: 15.0),
            ),
            Text(
              '₹ ${Constants.numberFormat.format(double.parse(cartsData.totalAmount.toStringAsFixed(2)))}',
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontSize: 17.0,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'Order Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: cartsData.cartItems.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ShippingDetailsPage(),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
