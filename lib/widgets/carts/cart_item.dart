import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants_helper.dart';
import '../../helpers/dialog_helper.dart';
import '../../models/cart.dart';
import '../../providers/carts_data.dart';
import '../../providers/products_data.dart';
import '../../screens/products/product_details_page.dart';

/// Displays a card with cart item details and options to change quantity, view more details and delete from cart.
class CartItem extends StatelessWidget {
  final Cart cart;
  final String productId;

  const CartItem({Key key, this.cart, this.productId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cart.id),
      background: buildBackground(Alignment.centerLeft),
      secondaryBackground: buildBackground(Alignment.centerRight),
      dismissThresholds: {
        DismissDirection.startToEnd: 0.2,
        DismissDirection.endToStart: 0.2,
      },
      confirmDismiss: (direction) => DialogHelper.showAlertDialog(
        context,
        'Are you sure?',
        'All the quantities of "${cart.name}" will be removed from your cart.',
      ),
      onDismissed: (direction) {
        Provider.of<CartsData>(context, listen: false)
            .removeFromCart(productId);
      },
      child: Card(
        elevation: 8.0,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(
                product: Provider.of<ProductsData>(context)
                    .getProductFromId(cart.id),
                quantity: cart.quantity,
                fromCart: true,
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(cart.imageUrl),
          ),
          title: Text(
            cart.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          subtitle: Text(
            'Unit Price: ₹ ${Constants.numberFormat.format(cart.price)} • Tax: ${cart.tax} %\nShipping Charge: ₹ ${cart.shippingCharge}\nTotal: ₹ ${Constants.numberFormat.format(double.parse(((cart.price + cart.shippingCharge + cart.price * cart.tax / 100) * cart.quantity).toStringAsFixed(2)))}',
            style: const TextStyle(fontSize: 12.0),
          ),
          trailing: QuantityPicker(
            initialValue: cart.quantity,
            setQuantity: (value) =>
                Provider.of<CartsData>(context, listen: false)
                    .updateQuantity(productId, value),
          ),
        ),
      ),
    );
  }

  /// Draws a background behind the cart item card.
  Container buildBackground(Alignment alignment) {
    return Container(
      color: Colors.redAccent,
      alignment: alignment,
      padding: const EdgeInsets.all(15.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: const Icon(Icons.delete_forever_rounded, size: 30.0),
    );
  }
}

/// Displays a scrollable quantity picker.
class QuantityPicker extends StatefulWidget {
  final int initialValue;
  final Function setQuantity;
  const QuantityPicker({
    Key key,
    this.initialValue,
    this.setQuantity,
  }) : super(key: key);
  @override
  _QuantityPickerState createState() => _QuantityPickerState();
}

class _QuantityPickerState extends State<QuantityPicker> {
  @override
  Widget build(BuildContext context) {
    int _quantity = widget.initialValue;
    return NumberPicker(
      minValue: 1,
      maxValue: 8,
      value: _quantity,
      itemHeight: 20.0,
      itemWidth: 40.0,
      haptics: true,
      axis: Axis.vertical,
      zeroPad: true,
      selectedTextStyle: TextStyle(
        height: 1.3,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
      textMapper: (value) => '${value}x',
      onChanged: (value) {
        setState(() => _quantity = value);
        widget.setQuantity(value);
      },
    );
  }
}
