import 'package:flutter/material.dart';

OutlineInputBorder inputBorder(Color color) {
  return OutlineInputBorder(
    borderSide: BorderSide(
      color: color,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(7),
  );
}
