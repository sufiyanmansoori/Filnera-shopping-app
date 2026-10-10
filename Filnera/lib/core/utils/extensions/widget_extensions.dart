import 'package:flutter/material.dart';
extension WidgetExtensions on Widget { Widget padded([EdgeInsets padding = const EdgeInsets.all(8)]) => Padding(padding: padding, child: this); }
