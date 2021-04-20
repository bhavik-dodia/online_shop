import 'dart:io';

import 'package:flutter/material.dart';

import '../../helpers/channel_helper.dart';

/// Displays selected image and provides image selection option.
class InputImage extends StatefulWidget {
  final Function onSelectImage;

  const InputImage({Key key, this.onSelectImage}) : super(key: key);
  @override
  _InputImageState createState() => _InputImageState();
}

class _InputImageState extends State<InputImage> {
  Channel channel = Channel();
  File _selectedImage;

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
              title: const Text('Take Picture'),
              onTap: () => Navigator.of(context).pop(true),
            ),
            const Divider(indent: 15.0, endIndent: 15.0),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('From Gallery'),
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
      widget.onSelectImage(imageFile);
    } else {
      print('No image selected!!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: _selectPicture,
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              primary: Colors.blueAccent[100],
              backgroundColor: Colors.grey.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(
                vertical: 12.5,
                horizontal: 15.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text(
              'Insert an Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Container(
          height: 50.0,
          width: 50.0,
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: _selectedImage != null
              ? Image.file(
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
                )
              : Icon(
                  Icons.image_outlined,
                  color: Colors.blueAccent[100],
                ),
        ),
      ],
    );
  }
}
