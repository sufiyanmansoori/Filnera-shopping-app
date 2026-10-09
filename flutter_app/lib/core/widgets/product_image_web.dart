import 'package:flutter/material.dart';

ImageProvider<Object> productImageProvider(String source) =>
    NetworkImage(source);
