import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/snackbar_helper.dart';
import '../../providers/carts_data.dart';
import '../../providers/products_data.dart';
import '../../screens/carts_page.dart';
import '../../screens/products/products_overview_page.dart';
import '../carts/badge.dart';

/// Displays a page to show on top of hidden menu.
class Home extends StatefulWidget {
  final Function manageDrawer;
  final Animation<double> controller;

  const Home({
    Key key,
    this.manageDrawer,
    this.controller,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final duration = const Duration(milliseconds: 300);

  void loadData() {
    try {
      Provider.of<ProductsData>(context, listen: false).fetchProducts();
      Provider.of<CartsData>(context, listen: false).loadCartItems();
    } catch (e) {
      SnackBarHelper.showSnackBar(
          context, 'Something went wrong. Check your network and try again.');
    }
  }

  @override
  void initState() {
    super.initState();
    try {
      Provider.of<ProductsData>(context, listen: false).fetchProducts();
      Provider.of<CartsData>(context, listen: false).loadCartItems();
    } catch (e) {
      SnackBarHelper.showSnackBar(
          context, 'Something went wrong. Check your network and try again.');
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      Provider.of<CartsData>(context, listen: false).saveCartItems();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        leading: InkWell(
          onTap: widget.manageDrawer,
          child: Center(
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_arrow,
              progress:
                  Tween<double>(begin: 0, end: 1).animate(widget.controller),
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
        actions: [
          Consumer<CartsData>(
            builder: (context, cartsData, child) => Badge(
              child: child,
              value: cartsData.cartsCount.toString(),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartsPage.routeName),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh:
            Provider.of<ProductsData>(context, listen: false).fetchProducts,
        child: ProductsOverviewPage(),
      ),
    );
  }
}
