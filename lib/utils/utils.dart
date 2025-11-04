import 'package:flutter/material.dart';

class AppColors {
  static const background = Color.fromARGB(93, 0, 0, 0);       // Main background
  static const accent = Color(0xFFD0FF55);           // For highlight buttons
  static const inputField = Color(0xFF232323);       // For cards/fields
  static const textPrimary = Colors.white;           // For primary text
  static const textSecondary = Colors.grey;          // For secondary text
  static const iconColor = Colors.white;
}

class AppDimens {
 static var width=0.0;
  static var height = 0.0;
   AppDimens(BuildContext context){
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
  }

  double get blockSize => width / 100;
  double get blockSizeVertical => height / 100;

}
