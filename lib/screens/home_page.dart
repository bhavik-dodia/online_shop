import 'package:flutter/material.dart';

import '../widgets/home/home.dart';
import '../widgets/home/menu.dart';

/// Displays page with hidden menu behind the product details page.
class HomePage extends StatefulWidget {
  static const routeName = 'home-page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  double screenWidth, screenHeight;

  final Duration duration = const Duration(milliseconds: 300);

  AnimationController _controller;

  Animation<double> _homeScaleAnimation, _menuScaleAnimation;
  Animation<Offset> _menuSlideAnimation, _homeSlideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: duration);
    _menuScaleAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _menuSlideAnimation =
        Tween<Offset>(begin: Offset(-0.5, 0), end: Offset(0, 0))
            .animate(_controller);
    _homeScaleAnimation =
        Tween<double>(begin: 1, end: 0.8).animate(_controller);
    _homeSlideAnimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0.6, 0)).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Handles opening and closing of the hidden menu.
  manageDrawer() {
    if (isCollapsed)
      _controller.forward();
    else
      _controller.reverse();
    setState(() => isCollapsed = !isCollapsed);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Menu(
            slideAnimation: _menuSlideAnimation,
            menuScaleAnimation: _menuScaleAnimation,
            manageDrawer: manageDrawer,
          ),
          GestureDetector(
            onVerticalDragUpdate: (details) {},
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 0) {
                if (isCollapsed) _controller.forward();
                setState(() => isCollapsed = false);
              } else {
                if (isCollapsed) _controller.reverse();
                setState(() => isCollapsed = true);
              }
            },
            child: SlideTransition(
              position: _homeSlideAnimation,
              child: ScaleTransition(
                scale: _homeScaleAnimation,
                child: AnimatedContainer(
                  duration: duration,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isCollapsed ? 5 : 30),
                    color: Theme.of(context).accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.4),
                        offset: const Offset(8.0, 8.0),
                        blurRadius: 20.0,
                      ),
                    ],
                  ),
                  child: Home(
                    manageDrawer: manageDrawer,
                    controller: _controller,
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
