import 'package:flutter/material.dart';

/// Shows a dialog box in the application.
class DialogHelper {
  /// Displays material alert dialog with two confirmation buttons "yes" and "no".
  static Future<bool> showAlertDialog(
      BuildContext context, String title, String content) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        elevation: 8.0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(title),
        content: Text(content, textAlign: TextAlign.justify),
        titlePadding: const EdgeInsets.all(15.0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
        actionsPadding: EdgeInsets.zero,
        actions: [
          TextButton(
            child: const Text('No', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            autofocus: true,
            child: const Text('Yes'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
