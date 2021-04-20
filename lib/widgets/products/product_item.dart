import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../helpers/snackbar_helper.dart';
import '../../models/product.dart';
import '../../providers/carts_data.dart';
import '../../screens/products/product_details_page.dart';

/// Displays a card with product details and an option to add the product to cart.
class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({Key key, this.product}) : super(key: key);

  /// Adds a specific product to cart and displays a message.
  void _addToCart(BuildContext context, ThemeData theme) {
    try {
      Provider.of<CartsData>(context, listen: false).addToCart(product);
      SnackBarHelper.showSnackBar(
          context, '${product.name} added to your cart');
    } catch (e) {
      SnackBarHelper.showSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductDetailsPage(
            product: product,
          ),
        ),
      ),
      child: Stack(
        children: [
          Hero(
            tag: product.name,
            child: Card(
              elevation: 8.0,
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.68,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            product.shortDescription,
                            style: const TextStyle(height: 1.5),
                            textAlign: TextAlign.left,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            '₹ ${NumberFormat('#,##,###').format(product.price)}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: TextButton(
                            onPressed: () => _addToCart(context, theme),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: TextButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Hero(
              tag: product.imageUrl,
              child: FractionallySizedBox(
                widthFactor: 0.3,
                child: Card(
                  elevation: 6.0,
                  margin: EdgeInsets.only(
                    left: 10.0,
                    top: 10.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) =>
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
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                ),
                      errorBuilder: (context, exception, stackTrace) =>
                          Container(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
