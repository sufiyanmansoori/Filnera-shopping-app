import 'package:flutter/material.dart';

import 'product_image_web.dart'
    if (dart.library.io) 'product_image_io.dart'
    as platform;

ImageProvider<Object> productImageProvider(String source) =>
    platform.productImageProvider(source);
