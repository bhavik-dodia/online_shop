import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../helpers/constants_helper.dart';
import '../../helpers/snackbar_helper.dart';
import '../../providers/carts_data.dart';
import '../../widgets/auth/forgot_password.dart';
import '../../widgets/auth/google_log_in.dart';

/// Displays login page for getting login information.
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _passwordNode = FocusNode();
  bool ot = true, _isLoading = false;
  String _userEmail = '', _userPassword = '';

  @override
  void dispose() {
    _passwordNode.dispose();
    super.dispose();
  }

  /// Logs in the user.
  void _trySubmit() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      _formKey.currentState.save();
      try {
        setState(() => _isLoading = true);
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        )
            .whenComplete(
          () {
            setState(() => _isLoading = false);
            Provider.of<CartsData>(context, listen: false).loadCartItems();
          },
        );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text.rich(
          TextSpan(
            text: 'Welcome to\n',
            children: [
              TextSpan(
                text: 'SHOP\n',
                style: TextStyle(
                  height: 1,
                  fontSize: 36,
                  letterSpacing: 2,
                  color: theme.canvasColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Please login to continue',
                style: TextStyle(
                  height: 1,
                  fontSize: 16,
                  color: theme.canvasColor,
                ),
              ),
            ],
            style: TextStyle(
              height: 2,
              fontSize: 16,
              color: theme.canvasColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: theme.cardColor.withOpacity(0.8),
                  ),
                  hintText: 'Email Id',
                  hintStyle: hintStyle(theme),
                  errorStyle: errorStyle(),
                  border: border(),
                  filled: true,
                  fillColor: Colors.blueAccent[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                ),
                cursorColor: theme.accentColor,
                style: style(theme),
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
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordNode),
              ),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: ot,
                cursorColor: theme.accentColor,
                style: style(theme),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: theme.cardColor.withOpacity(0.8),
                  ),
                  hintText: 'Password',
                  hintStyle: hintStyle(theme),
                  errorStyle: errorStyle(),
                  border: border(),
                  filled: true,
                  fillColor: Colors.blueAccent[100],
                  contentPadding: const EdgeInsets.only(left: 16, right: 0),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => ot = !ot),
                    tooltip: ot ? 'show password' : 'hide password',
                    icon: Icon(
                      ot
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: theme.cardColor.withOpacity(0.8),
                    ),
                  ),
                ),
                focusNode: _passwordNode,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value.isEmpty) return 'Please enter a password';
                  if (!Constants.passRegex.hasMatch(value))
                    return 'Enter a strong password';
                  return null;
                },
                onSaved: (value) => _userPassword = value.trim(),
                onFieldSubmitted: (_) => _trySubmit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        MaterialButton(
          onPressed: _isLoading ? null : _trySubmit,
          height: 40,
          elevation: 8.0,
          color: theme.canvasColor,
          textColor: Colors.blueAccent,
          splashColor: Colors.grey.withOpacity(0.2),
          highlightColor: Colors.grey.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.5),
                  child: LinearProgressIndicator(),
                )
              : const Text(
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 10.0),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ForgotPassword(),
                ),
                child: const Text('Forgot Password'),
                style: TextButton.styleFrom(primary: theme.cardColor),
              ),
              VerticalDivider(
                width: 5.0,
                indent: 10.0,
                endIndent: 10.0,
                color: theme.cardColor,
              ),
              TextButton(
                onPressed: () {
                  try {
                    GoogleLogIn.signInWithGoogle();
                  } catch (e) {
                    SnackBarHelper.showSnackBar(context, e.message);
                  }
                },
                child: const Text('Sign in with Google'),
                style: TextButton.styleFrom(primary: theme.cardColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle style(ThemeData theme) {
    return TextStyle(
      fontSize: 16,
      color: theme.cardColor,
      fontWeight: FontWeight.bold,
    );
  }

  OutlineInputBorder border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(
        width: 0,
        style: BorderStyle.none,
      ),
    );
  }

  TextStyle errorStyle() {
    return const TextStyle(
      color: Colors.deepOrangeAccent,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle hintStyle(ThemeData theme) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: theme.cardColor.withOpacity(0.8),
    );
  }
}
