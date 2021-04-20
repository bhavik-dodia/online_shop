import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../helpers/constants_helper.dart';
import '../../helpers/snackbar_helper.dart';

/// Asks user to enter email for sending password reset link.
class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _userEmail;

  /// Sends password reset link to the specific email.
  void _trySubmit() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _userEmail)
            .whenComplete(() => Navigator.of(context).pop());
      } on FirebaseAuthException catch (e) {
        var message = 'An error occurred, please check your credentials!';
        if (e.message != null) message = e.message;
        SnackBarHelper.showSnackBar(context, message);
      } catch (e) {
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: _trySubmit,
          child: const Text('Send'),
        ),
      ],
      actionsPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: const Text('Forgot Password ?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'Email Id',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
                cursorColor: theme.accentColor,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value.isEmpty) return 'Please enter an email id';
                  if (!Constants.emailRegex.hasMatch(value))
                    return 'Please enter valid email id';
                  return null;
                },
                onSaved: (value) => _userEmail = value.trim(),
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Password reset link will be sent on this email.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 15.0),
            ),
          ],
        ),
      ),
    );
  }
}
