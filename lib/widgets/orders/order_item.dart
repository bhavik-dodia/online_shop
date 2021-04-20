import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../helpers/constants_helper.dart';
import '../../models/order.dart';
import '../../screens/orders/invoice_page.dart';

/// Displays an expandable card with order details.
class OrderItem extends StatefulWidget {
  final Order order;
  final String id;

  const OrderItem({Key key, this.order, this.id}) : super(key: key);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      clipBehavior: Clip.antiAlias,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ExpansionTile(
        title: Text(
          'Total Amount: ₹ ${Constants.numberFormat.format(
            double.parse(
              widget.order.amount.toStringAsFixed(2),
            ),
          )}',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          DateFormat('dd MMM, yyyy • hh:mm a').format(widget.order.dateTime),
          style: const TextStyle(fontSize: 12.0),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.end,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [
          for (var product in widget.order.products)
            ListTile(
              dense: true,
              title: Text(
                product.name,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Amount: ₹ ${Constants.numberFormat.format(
                  double.parse(
                    ((product.price +
                                product.shippingCharge +
                                product.price * product.tax / 100) *
                            product.quantity)
                        .toStringAsFixed(2),
                  ),
                )}',
                style: const TextStyle(fontSize: 12.0),
              ),
              trailing: Text(
                '${product.quantity}x',
                style: const TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => InvoicePage(
                  order: widget.order,
                  id: widget.id,
                ),
              ),
            ),
            child: const Text(
              'View Invoice',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              primary: Colors.blueAccent,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
