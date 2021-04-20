import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

import '../../helpers/snackbar_helper.dart';
import '../../models/product.dart';
import '../../providers/carts_data.dart';

/// Returns page with details of a specific product.
class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final bool fromCart;
  final int quantity;

  const ProductDetailsPage(
      {Key key, this.product, this.quantity: 1, this.fromCart: false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: MediaQuery.of(context).orientation == Orientation.portrait
          ? Column(
              children: [
                buildImage(16 / 9, product.imageUrl),
                Builder(
                  builder: (context) => buildDetails(context, product),
                ),
              ],
            )
          : Row(
              children: [
                buildImage(1, product.imageUrl),
                Builder(
                  builder: (context) => buildDetails(context, product),
                ),
              ],
            ),
    );
  }

  /// Displays product image.
  Widget buildImage(double aspectRatio, String imgUrl) {
    return Hero(
      tag: imgUrl,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 6.0,
        margin: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image.network(
            imgUrl,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                wasSynchronouslyLoaded
                    ? child
                    : AnimatedOpacity(
                        child: child,
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeOut,
                      ),
            loadingBuilder: (context, child, loadingProgress) =>
                loadingProgress == null
                    ? child
                    : Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      ),
            errorBuilder: (context, exception, stackTrace) => Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                exception.toString(),
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Displays a card with other product details.
  Widget buildDetails(BuildContext context, Product product) {
    final theme = Theme.of(context);
    int _quantity = quantity;
    return Expanded(
      child: Hero(
        tag: product.name,
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10.0),
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              elevation: 5.0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                clipBehavior: Clip.antiAlias,
                width: double.infinity,
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildHeadingDataPair(
                      heading: 'Id',
                      data: product.id,
                      theme: theme,
                    ),
                    const SizedBox(height: 15.0),
                    buildHeadingDataPair(
                      heading: 'Description',
                      data: product.longDescription,
                      theme: theme,
                    ),
                    const SizedBox(height: 5.0),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          buildHeadingDataPair(
                            heading: 'Price',
                            data: '₹ ${product.price}',
                            theme: theme,
                          ),
                          const Spacer(),
                          const VerticalDivider(indent: 10.0, endIndent: 10.0),
                          const Spacer(),
                          Text(
                            'Quantity: ',
                            style: TextStyle(
                              color: theme.accentColor,
                              fontSize: 18.0,
                            ),
                          ),
                          QuantityPicker(
                            initialQuantity: _quantity,
                            setQuantity: (value) => _quantity = value,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15.0),
            MaterialButton(
              onPressed: () {
                try {
                  fromCart
                      ? Provider.of<CartsData>(context, listen: false)
                          .updateQuantity(product.id, _quantity)
                      : Provider.of<CartsData>(context, listen: false)
                          .addToCart(product, quantity: _quantity);
                  SnackBarHelper.showSnackBar(
                    context,
                    '${product.name} added to your cart',
                  );
                } catch (e) {
                  SnackBarHelper.showSnackBar(context, e.message);
                }
              },
              color: theme.accentColor,
              padding: const EdgeInsets.all(15.0),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: const Text(
                'Add To Cart',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
      style: TextStyle(color: theme.accentColor, fontSize: 17.0),
      textAlign: TextAlign.justify,
    );
  }
}

/// Displays a scrollable quantity picker.
class QuantityPicker extends StatefulWidget {
  final Function setQuantity;
  final int initialQuantity;

  const QuantityPicker({Key key, this.setQuantity, this.initialQuantity})
      : super(key: key);

  @override
  _QuantityPickerState createState() => _QuantityPickerState();
}

class _QuantityPickerState extends State<QuantityPicker> {
  int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return NumberPicker(
      minValue: 1,
      maxValue: 8,
      value: _quantity,
      itemWidth: 20.0,
      haptics: true,
      axis: Axis.horizontal,
      onChanged: (value) {
        setState(() => _quantity = value);
        widget.setQuantity(value);
      },
    );
  }
}
