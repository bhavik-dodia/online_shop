import 'package:flutter/services.dart';

/// Manages method channels for the image picker.
class Channel {
  MethodChannel _channel = const MethodChannel('com.custom.imagepicker');

  /// Opens camera application to take a picture.
  getImageFromCamera() async {
    var data = await _channel.invokeMethod('camera');

    if (data != null && data != 'denied') {
      if (data.toString().endsWith('.png') ||
          data.toString().endsWith('.jpg') ||
          data.toString().endsWith('.jpeg')) {
        return data;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  /// Opens gallery to select an image.
  getImageFromGallery() async {
    return await _channel.invokeMethod('gallery');
  }
}
