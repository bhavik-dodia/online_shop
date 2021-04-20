import 'package:flutter/material.dart';

/// Displays a badge to show cart item count.
class Badge extends StatelessWidget {
  const Badge({
    Key key,
    @required this.child,
    @required this.value,
  }) : super(key: key);

  final Widget child;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Visibility(
          visible: int.parse(value) != 0,
          child: Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.amberAccent,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black),
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        )
      ],
    );
  }
}
