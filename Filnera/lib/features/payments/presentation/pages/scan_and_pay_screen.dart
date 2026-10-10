import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/upi_payment_service.dart';

class ScanAndPayScreen extends StatefulWidget {
  const ScanAndPayScreen({super.key, this.productId});

  final String? productId;

  @override
  State<ScanAndPayScreen> createState() => _ScanAndPayScreenState();
}

class _ScanAndPayScreenState extends State<ScanAndPayScreen> {
  CameraController? _cameraController;
  Future<void>? _cameraInitFuture;
  bool _isScanning = false;
  bool _cameraReady = false;
  bool _cameraPermissionGranted = false;
  String? _detectedQr;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission.isGranted || cameraPermission.isLimited) {
      _cameraPermissionGranted = true;
    } else {
      _cameraPermissionGranted = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan.'),
          ),
        );
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera found on this device.')),
        );
      }
      return;
    }

    final first = cameras.first;
    _cameraController = CameraController(
      first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _cameraInitFuture = _cameraController!.initialize();
    await _cameraInitFuture;

    if (!mounted) return;
    setState(() {
      _cameraReady = true;
    });

    _cameraController!.startImageStream(_processFrame);
  }

  void _processFrame(CameraImage image) {
    if (_isScanning || !_cameraPermissionGranted) return;

    _isScanning = true;
    Future.microtask(() async {
      try {
        final rawQr = _decodeQrFromFrame(image);
        if (rawQr != null && rawQr.isNotEmpty && rawQr != _detectedQr) {
          _detectedQr = rawQr;
          if (mounted) {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('QR scanned: $rawQr')));
          }
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barcode scan could not be processed.'),
            ),
          );
        }
      } finally {
        _isScanning = false;
      }
    });
  }

  String? _decodeQrFromFrame(CameraImage image) {
    final bytes = image.planes.first.bytes;
    if (bytes.isEmpty) return null;

    final qrLike = String.fromCharCodes(bytes.take(64).toList());
    if (qrLike.contains('order') || qrLike.contains('product')) {
      return qrLike.trim();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan to Pay')),
      body: SafeArea(
        child: _cameraPermissionGranted && _cameraReady
            ? Stack(
                children: [
                  Positioned.fill(child: CameraPreview(_cameraController!)),
                  Positioned(
                    top: 50,
                    left: 48,
                    right: 48,
                    child: Container(
                      height: 240,
                      width: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 16,
                    right: 16,
                    child: _buildPaymentSheet(),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildPaymentSheet() {
    final amount = 499.00;
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product scan result',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _detectedQr ?? 'Scan product/order QR',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount'),
              Text('₹ ${amount.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final service = UpiPaymentService.instance;
                    final link = service.buildUpiLink(
                      orderId: orderId,
                      amount: amount,
                    );

                    final canOpen = await canLaunchUrl(Uri.parse(link));
                    if (!canOpen && mounted) {
                      if (!mounted) return;
                      await showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('UPI app not installed'),
                          content: service.buildQrFallback(
                            orderId: orderId,
                            amount: amount,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    final launched = await service.launchUpiIntent(
                      orderId: orderId,
                      amount: amount,
                    );
                    if (!launched && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to open a UPI app.'),
                        ),
                      );
                    } else if (mounted) {
                      await showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Payment returned?'),
                          content: const Text(
                            'Please verify your UPI payment confirmation or upload a screenshot of the successful transaction.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('I’ll confirm later'),
                            ),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Upload Screenshot'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay via UPI'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
