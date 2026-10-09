import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ProductImageProvider extends ChangeNotifier {
  ProductImageProvider._();

  static final ProductImageProvider instance = ProductImageProvider._();

  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> newProducts = <XFile>[];

  XFile? selectedImage;
  bool isLoading = false;
  String? errorMessage;

  Future<bool> requestGalleryPermission() async {
    try {
      PermissionStatus status;
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted || photosStatus.isLimited) {
          return true;
        }
        status = photosStatus;
      } else {
        status = await Permission.photos.request();
      }

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isPermanentlyDenied) {
        errorMessage =
            'Photo access is permanently disabled. Enable it in Settings.';
      } else {
        errorMessage = 'Photo access was not granted.';
      }
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Unable to request gallery permission.';
      notifyListeners();
      return false;
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    final hasPermission = await requestGalleryPermission();
    if (!hasPermission) {
      return null;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (picked == null) {
        isLoading = false;
        notifyListeners();
        return null;
      }

      final compressed = await compressImage(picked);
      if (compressed == null) {
        isLoading = false;
        errorMessage = 'The image could not be compressed.';
        notifyListeners();
        return null;
      }

      selectedImage = compressed;
      newProducts.add(compressed);
      isLoading = false;
      notifyListeners();
      return compressed;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Unable to access the device gallery.';
      notifyListeners();
      return null;
    }
  }

  Future<XFile?> compressImage(XFile file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/manara_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        minWidth: 1080,
        minHeight: 1080,
        quality: 80,
        rotate: 0,
      );

      if (result == null) {
        return null;
      }
      return XFile(result.path);
    } catch (_) {
      return null;
    }
  }

  void removeSelectedImage() {
    selectedImage = null;
    errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
