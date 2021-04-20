import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/products_data.dart';
import '../../widgets/products/product_item.dart';

/// Displays page with glimpse of all the products available.
class ProductsOverviewPage extends StatelessWidget {
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Consumer<ProductsData>(
      builder: (context, productsData, child) {
        final products = productsData.products;
        return productsData.products.isEmpty
            ? child
            : GridView.builder(
                padding: const EdgeInsets.all(15.0),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  childAspectRatio: 20 / 9,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15.0,
                  maxCrossAxisExtent: 400,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) => ProductItem(
                  product: products[index],
                ),
              );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              const LinearProgressIndicator(),
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get buildChildren {
    return [
      AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.asset(
          'images/explore_products.png',
        ),
      ),
      const Text(
        'You can explore products\nonce they are available.',
        textAlign: TextAlign.center,
        softWrap: true,
      ),
    ];
  }
}
