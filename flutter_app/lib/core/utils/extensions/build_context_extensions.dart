import 'package:flutter/material.dart';
extension BuildContextExtensions on BuildContext { Size get screenSize => MediaQuery.sizeOf(this); }
