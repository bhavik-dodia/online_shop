import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../helpers/constants_helper.dart';
import '../../models/order.dart';

/// Displays a page with generated invoice of specific order.
class InvoicePage extends StatelessWidget {
  final Order order;
  final String id;

  const InvoicePage({Key key, this.order, this.id}) : super(key: key);

  /// Returns sum of unit prices of the products ordered.
  double get totalPrice {
    var total = 0.0;
    order.products.forEach((product) => total += product.price);
    return total;
  }

  /// Returns sum of taxes of the products ordered.
  int get totalTax {
    var total = 0;
    order.products.forEach((product) => total += product.tax);
    return total;
  }

  /// Returns sum of shipping charges of the products ordered.
  int get totalShippingCharge {
    var total = 0;
    order.products.forEach((product) => total += product.shippingCharge);
    return total;
  }

  /// Returns sum of quantities of the products ordered.
  int get totalQuantity {
    var total = 0;
    order.products.forEach((product) => total += product.quantity);
    return total;
  }

  /// Returns grand total of prices of all the products ordered (inclusive of all taxes).
  double get totalAmount {
    var total = 0.0;
    order.products.forEach((product) => total += (product.price +
            product.shippingCharge +
            product.price * product.tax / 100) *
        product.quantity);
    return total;
  }

  /// Returns approximate delevery time based on shipping address of the order.
  String get deliveryDuration {
    if (order.address.contains('Gujarat')) return '1 - 2';
    if (order.address.contains('Maharashtra') ||
        order.address.contains('Rajasthan') ||
        order.address.contains('Madhya Pradesh')) return '3 - 4';
    return '5 - 6';
  }

  User get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        physics: const BouncingScrollPhysics(),
        children: [
          buildSectionTitle(title: 'Recipient'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              user.displayName,
              style: const TextStyle(
                fontSize: 17.0,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(user.email),
            trailing: CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL),
            ),
          ),
          const Divider(),
          buildSectionTitle(title: 'Shipping details'),
          buildHeadingDataPair(
            heading: 'Delivery in',
            data: '$deliveryDuration working days',
            theme: theme,
          ),
          buildHeadingDataPair(
            heading: 'Ship to',
            data: order.address,
            theme: theme,
          ),
          const Divider(),
          buildSectionTitle(title: 'Order details'),
          buildHeadingDataPair(
            heading: 'Order id',
            data: id,
            theme: theme,
          ),
          buildHeadingDataPair(
            heading: 'Ordered on',
            data: DateFormat('dd MMM, yyyy • hh:mm a').format(order.dateTime),
            theme: theme,
          ),
          const Divider(),
          buildSectionTitle(title: 'Invoice details'),
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.withOpacity(0.3)),
              top: BorderSide(color: Colors.grey[850]),
              bottom: BorderSide(color: Colors.grey[850]),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: {
              0: FlexColumnWidth(2.2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(0.7),
              3: FlexColumnWidth(0.7),
              4: FlexColumnWidth(0.7),
              5: FlexColumnWidth(1.3),
            },
            children: [
              TableRow(
                children: [
                  buildHeaderCell('Product'),
                  buildHeaderCell('Price (₹)'),
                  buildHeaderCell('Tax (%)'),
                  buildHeaderCell('S. C. (₹)'),
                  buildHeaderCell('Qty'),
                  buildHeaderCell('Amount (₹)'),
                ],
              ),
              for (var item in order.products)
                TableRow(
                  children: [
                    buildDataCell(item.name, TextAlign.left),
                    buildDataCell(
                      Constants.numberFormat.format(item.price),
                      TextAlign.center,
                    ),
                    buildDataCell(item.tax.toString(), TextAlign.center),
                    buildDataCell(
                      item.shippingCharge.toString(),
                      TextAlign.center,
                    ),
                    buildDataCell(item.quantity.toString(), TextAlign.center),
                    buildDataCell(
                      Constants.numberFormat.format(
                        double.parse(
                          ((item.price +
                                      item.shippingCharge +
                                      item.price * item.tax / 100) *
                                  item.quantity)
                              .toStringAsFixed(2),
                        ),
                      ),
                      TextAlign.center,
                    ),
                  ],
                ),
              TableRow(
                children: [
                  buildTotalCell('Total'),
                  buildTotalCell(Constants.numberFormat
                      .format(double.parse(totalPrice.toStringAsFixed(0)))),
                  buildTotalCell(totalTax.toString()),
                  buildTotalCell(totalShippingCharge.toString()),
                  buildTotalCell(totalQuantity.toString()),
                  buildTotalCell(Constants.numberFormat
                      .format(double.parse(totalAmount.toStringAsFixed(2)))),
                ],
              ),
            ],
          ),
          Text(
            '*S. C. = Shipping charge, Qty = Quantity',
            style: TextStyle(
              fontSize: 10.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Displays heading of a section.
  Text buildSectionTitle({String title}) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20.0,
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Displays total information for the total row of the invoice table.
  TableCell buildTotalCell(String total) {
    return TableCell(
      child: Text(
        total,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Displays information for the data rows of the invoice table.
  TableCell buildDataCell(String data, TextAlign textAlign) {
    return TableCell(
      child: Text(data, textAlign: textAlign),
    );
  }

  /// Displays heading for the header row of the invoice table.
  TableCell buildHeaderCell(String heading) {
    return TableCell(
      child: Text(
        heading,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Displays heading and data for the section details.
  Text buildHeadingDataPair({String heading, String data, ThemeData theme}) {
    return Text.rich(
      TextSpan(
        text: '$heading: ',
        children: [
          TextSpan(
            text: data,
            style: theme.textTheme.bodyText2,
          ),
        ],
      ),
      style: const TextStyle(
        fontSize: 17.0,
        color: Colors.blue,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.justify,
    );
  }
}
