import 'package:intl/intl.dart';

/// Provides different constants used in the application.
class Constants {
  /// Formats number in "1,234.00" pattern.
  static final numberFormat = NumberFormat('#,##,###.##');

  /// Validates for official email pattern.
  static final emailRegex =
      RegExp(r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)');

  /// Validates for password witch should have at least
  /// 1 capital letter,
  /// 1 small letter,
  /// 1 number,
  /// 1 special Character from "@#$%^&-+=()"
  static final passRegex = RegExp(
      r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&-+=()])(?=\S+$).{8,}$');

  /// List of states of India.
  static final states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jammu and kashmir',
    'Ladakh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttarakhand',
    'Uttar Pradesh',
    'West Bengal',
  ];
}
