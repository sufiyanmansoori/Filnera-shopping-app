import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider<Object> productImageProvider(String source) {
  if (source.startsWith('http://') || source.startsWith('https://')) {
    return NetworkImage(source);
  }
  return FileImage(File(source));
}
