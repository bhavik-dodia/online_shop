import 'package:flutter/material.dart';

/// Displays a material list tile to show options of the menu.
class MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Function onTap;

  MenuTile({this.title, this.icon, this.isSelected, this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? theme.accentColor.withOpacity(0.3) : null,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
          ),
        ),
        onTap: onTap,
        selected: isSelected,
        leading: Icon(icon, color: isSelected ? theme.accentColor : null),
        title: Text(
          title,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: isSelected ? FontWeight.bold : null,
            color: isSelected ? theme.accentColor : null,
          ),
        ),
      ),
    );
  }
}
