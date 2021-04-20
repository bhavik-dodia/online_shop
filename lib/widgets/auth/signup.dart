import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helpers/constants_helper.dart';
import '../../helpers/snackbar_helper.dart';
import 'input_image.dart';

/// Displays sign up page for getting sign up information.
class SignUp extends StatefulWidget {
  final Function goToLogin;

  const SignUp({Key key, this.goToLogin}) : super(key: key);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailNode = FocusNode();
  final _passwordNode = FocusNode();
  final _addressNode = FocusNode();
  bool ot = true, _isLoading = false;
  String _userEmail = '',
      _userName = '',
      _userPassword = '',
      _userAddress = '',
      _userState = 'Gujarat';
  File _pickedImage;

  /// Sets the user profile image file.
  void _selectImage(File pickedImage) => _pickedImage = pickedImage;

  @override
  void dispose() {
    _emailNode.dispose();
    _passwordNode.dispose();
    _addressNode.dispose();
    super.dispose();
  }

  /// Registers new user to use the application and saves user profile data in the database.
  void _trySubmit() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();

      if (_pickedImage == null) {
        SnackBarHelper.showSnackBar(context, 'Please select an image');
        return;
      }

      _formKey.currentState.save();
      FirebaseApp tempApp;
      try {
        tempApp = await Firebase.initializeApp(
          name: 'tempApp',
          options: Firebase.app().options,
        );
        setState(() => _isLoading = true);
        final authResult = await FirebaseAuth.instanceFor(app: tempApp)
            .createUserWithEmailAndPassword(
              email: _userEmail,
              password: _userPassword,
            )
            .whenComplete(
              () => setState(() => _isLoading = false),
            );
        widget.goToLogin();
        final ref = FirebaseStorage.instanceFor(app: tempApp)
            .ref()
            .child('User Images')
            .child(authResult.user.uid + '.jpg');
        await ref.putFile(_pickedImage);
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instanceFor(app: tempApp)
            .collection('Users')
            .doc(authResult.user.uid)
            .set({
          'id': authResult.user.uid,
          'name': _userName,
          'email': _userEmail,
          'imageUrl': url,
        });
        await FirebaseFirestore.instanceFor(app: tempApp)
            .collection('Users')
            .doc(authResult.user.uid)
            .collection('Addresses')
            .add({
          'isDefault': true,
          'address': _userAddress,
          'state': _userState,
        });
      } on FirebaseAuthException catch (e) {
        var message = 'An error occurred, please check your credentials!';
        if (e.message != null) message = e.message;
        SnackBarHelper.showSnackBar(context, message);
        await tempApp?.delete();
      } catch (e) {
        print(e.message);
        await tempApp?.delete();
      } finally {
        await tempApp?.delete();
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
        const Text.rich(
          TextSpan(
            text: 'Sign up with\n',
            children: [
              TextSpan(
                text: 'SHOP',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  letterSpacing: 2,
                  height: 1,
                ),
              ),
            ],
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueAccent,
              height: 2,
            ),
          ),
        ),
        InputImage(onSelectImage: _selectImage),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                cursorColor: theme.accentColor,
                style: style(),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.blueAccent[100],
                  ),
                  hintText: 'Name',
                  hintStyle: hintStyle(),
                  errorStyle: errorStyle(),
                  border: border(),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  contentPadding: contentPadding(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _userName = value.trim(),
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailNode),
              ),
              const SizedBox(height: 16),
              TextFormField(
                cursorColor: theme.accentColor,
                style: style(),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.blueAccent[100],
                  ),
                  hintText: 'Email Id',
                  hintStyle: hintStyle(),
                  errorStyle: errorStyle(),
                  border: border(),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  contentPadding: contentPadding(),
                ),
                focusNode: _emailNode,
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
                style: style(),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.blueAccent[100],
                  ),
                  hintText: 'Password',
                  hintStyle: hintStyle(),
                  errorStyle: errorStyle(),
                  border: border(),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  contentPadding: const EdgeInsets.only(left: 16, right: 0),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => ot = !ot),
                    tooltip: ot ? 'show password' : 'hide password',
                    icon: Icon(
                      ot
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.blueAccent[100],
                    ),
                  ),
                ),
                focusNode: _passwordNode,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value.isEmpty) return 'Please enter a password';
                  if (!Constants.passRegex.hasMatch(value))
                    return 'Please enter a strong password';
                  return null;
                },
                onSaved: (value) => _userPassword = value.trim(),
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_addressNode),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          cursorColor: theme.accentColor,
          style: style(),
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_city_outlined,
              color: Colors.blueAccent[100],
            ),
            hintText: 'Address',
            hintStyle: hintStyle(),
            errorStyle: errorStyle(),
            border: border(),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.2),
            contentPadding: contentPadding(),
          ),
          minLines: 1,
          maxLines: 3,
          focusNode: _addressNode,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) =>
              value.isEmpty ? 'Please enter an address' : null,
          onSaved: (value) =>
              _userAddress = value.trim(), // ! onSaved never gets called!!
          onChanged: (value) => _userAddress = value.trim(),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField(
          style: GoogleFonts.laila(
            fontSize: 16,
            color: Colors.blueAccent,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: Colors.blueAccent[100],
            ),
            hintText: 'State',
            hintStyle: hintStyle(),
            errorStyle: errorStyle(),
            border: border(),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),
          ),
          iconEnabledColor: Colors.blueAccent[100],
          items: Constants.states
              .map(
                (state) => DropdownMenuItem(child: Text(state), value: state),
              )
              .toList(),
          value: _userState,
          onChanged: (value) => _userState = value,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => value == null ? 'Please select a state' : null,
        ),
        const SizedBox(height: 24),
        MaterialButton(
          onPressed: _isLoading ? null : _trySubmit,
          height: 40,
          elevation: 8.0,
          textColor: theme.canvasColor,
          color: theme.accentColor,
          splashColor: Colors.blueAccent[100],
          highlightColor: Colors.blueAccent[100].withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.5),
                  child: LinearProgressIndicator(),
                )
              : const Text(
                  "SIGN UP",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  EdgeInsets contentPadding() {
    return const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 0,
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
    return const TextStyle(fontWeight: FontWeight.bold);
  }

  TextStyle hintStyle() {
    return TextStyle(
      fontSize: 16,
      color: Colors.blueAccent[100],
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle style() {
    return const TextStyle(
      fontSize: 16,
      color: Colors.blueAccent,
      fontWeight: FontWeight.bold,
    );
  }
}
