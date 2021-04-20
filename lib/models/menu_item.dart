import 'package:flutter/material.dart';

/// Model for menu item.
class MenuItem {
  final String name;
  final IconData iconData;
  final Function action;

  MenuItem({this.iconData, this.name, this.action});
}
