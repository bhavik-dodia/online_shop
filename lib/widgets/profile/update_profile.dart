import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helpers/channel_helper.dart';
import '../../helpers/constants_helper.dart';
import '../../helpers/snackbar_helper.dart';

/// Displays page with options to update user profile details.
class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key key}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _url, _state;
  File _selectedImage;
  bool _isLoading = false;
  Channel channel = Channel();
  TextEditingController _nameController, _addressController;

  User get user => FirebaseAuth.instance.currentUser;

  /// Displays a material dialog to choose between Select image from gallery or take a picture from camera.
  /// Fetches and sets users current profile details from database.
  void setProfileDetails() async {
    _nameController = TextEditingController(text: user.displayName);
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Addresses')
        .where('isDefault', isEqualTo: true)
        .get();
    if (snapshot.docs.isEmpty) {
      setState(() {
        _addressController = TextEditingController();
        _state = 'Gujarat';
      });
    } else {
      setState(() {
        _addressController =
            TextEditingController(text: snapshot.docs.first.get('address'));
        _state = snapshot.docs.first.get('state');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setProfileDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Displays a material dialog to choose between Select image from gallery or take a picture from camera.
  _showPopup() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: const EdgeInsets.all(8.0),
        content: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a Picture'),
              onTap: () => Navigator.of(context).pop(true),
            ),
            const Divider(indent: 15.0, endIndent: 15.0),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }

  /// Sets image file to display.
  void _selectPicture() async {
    var isCamera = await _showPopup();
    if (isCamera == null && !(isCamera is bool)) {
      print('Nothing chosen');
      return;
    }
    final pickedImage = isCamera
        ? await channel.getImageFromCamera()
        : await channel.getImageFromGallery();
    if (pickedImage != null) {
      final imageFile = File(pickedImage);
      setState(() => _selectedImage = imageFile);
    } else {
      print('No image selected!!');
    }
  }

  /// Updates user profile details in database.
  void _trySubmit() async {
    if (_formKey.currentState.validate()) {
      var add = '', st = 'Gujarat';
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Addresses')
          .where('isDefault', isEqualTo: true)
          .get();
      if (snapshot.docs.isNotEmpty) {
        add = snapshot.docs.first.get('address');
        st = snapshot.docs.first.get('state');
      }
      FocusScope.of(context).unfocus();
      if (st == _state &&
          add == _addressController.text &&
          _selectedImage == null &&
          _nameController.text.trim() == user.displayName) return;
      _formKey.currentState.save();
      try {
        setState(() => _isLoading = true);
        if (_selectedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('User Images')
              .child(user.uid + '.jpg');
          await ref.putFile(_selectedImage);
          _url = await ref.getDownloadURL();
        }
        final snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('Addresses')
            .where('isDefault', isEqualTo: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          snapshot.docs.first.reference.set({
            'isDefault': true,
            'address': _addressController.text,
            'state': _state,
          });
        } else {
          FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .collection('Addresses')
              .add({
            'isDefault': true,
            'address': _addressController.text,
            'state': _state,
          });
        }
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'imageUrl': _selectedImage == null ? user.photoURL : _url,
        }).whenComplete(
          () => setState(() => _isLoading = false),
        );
        SnackBarHelper.showSnackBar(context, 'Profile updated successfully');
        Navigator.of(context).pop();
      } catch (e) {
        SnackBarHelper.showSnackBar(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 15.0,
        right: 15.0,
      ),
      children: [
        const Icon(
          Icons.horizontal_rule_rounded,
          size: 40.0,
          color: Colors.grey,
        ),
        Text(
          'Update Profile',
          textAlign: TextAlign.center,
          style: GoogleFonts.alice(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: theme.accentColor,
          ),
        ),
        isPortrait
            ? Column(
                children: [
                  buildImage(),
                  buildForm(theme),
                ],
              )
            : Row(
                children: [
                  buildImage(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: buildForm(theme),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Form buildForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
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
              labelText: 'Name',
              labelStyle: labelStyle(),
              errorStyle: errorStyle(),
              enabledBorder: enabledBorder(),
              focusedBorder: focusedBorder(),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.2),
              contentPadding: contentPadding(),
            ),
            controller: _nameController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value.isEmpty) return 'Please enter a name';
              return null;
            },
          ),
          const SizedBox(height: 10.0),
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
              labelText: 'Address',
              labelStyle: labelStyle(),
              errorStyle: errorStyle(),
              enabledBorder: enabledBorder(),
              focusedBorder: focusedBorder(),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.2),
              contentPadding: contentPadding(),
            ),
            minLines: 1,
            maxLines: 3,
            controller: _addressController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value.isEmpty) return 'Please enter a default address';
              return null;
            },
          ),
          const SizedBox(height: 10.0),
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
              labelText: 'State',
              labelStyle: labelStyle(),
              errorStyle: errorStyle(),
              enabledBorder: enabledBorder(),
              focusedBorder: focusedBorder(),
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
            value: _state,
            onChanged: (value) => _state = value,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
                value == null ? 'Please select a state' : null,
          ),
          const SizedBox(height: 10.0),
          MaterialButton(
            onPressed: _isLoading ? null : _trySubmit,
            height: 40,
            elevation: 8.0,
            textColor: theme.canvasColor,
            color: theme.accentColor,
            splashColor: Colors.blueAccent[100],
            highlightColor: Colors.blueAccent[100].withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.5),
                    child: LinearProgressIndicator(),
                  )
                : const Text(
                    "Update",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  EdgeInsets contentPadding() => const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      );

  OutlineInputBorder focusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.blueAccent),
    );
  }

  OutlineInputBorder enabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.blueAccent[100]),
    );
  }

  TextStyle errorStyle() {
    return const TextStyle(fontWeight: FontWeight.bold);
  }

  TextStyle labelStyle() {
    return const TextStyle(
      fontSize: 16,
      color: Colors.blueAccent,
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

  InkWell buildImage() {
    return InkWell(
      onTap: _selectPicture,
      child: Container(
        height: 150.0,
        width: 150.0,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueAccent[100]),
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.grey.withOpacity(0.2),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(19.0),
                child: Image.file(
                  _selectedImage,
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) =>
                          wasSynchronouslyLoaded
                              ? child
                              : AnimatedOpacity(
                                  child: child,
                                  opacity: frame == null ? 0 : 1,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(19.0),
                child: Image.network(
                  user.photoURL,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }
}
