import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');
    if (code.isEmpty) return;
    _hasScanned = true;
    _controller.stop();
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Scan product code'),
      actions: [
        ValueListenableBuilder<MobileScannerState>(
          valueListenable: _controller,
          builder: (context, state, _) => IconButton(
            onPressed: _controller.toggleTorch,
            tooltip: 'Toggle flashlight',
            icon: Icon(
              state.torchState == TorchState.on
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
          ),
        ),
      ],
    ),
    body: Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(controller: _controller, onDetect: _onDetect),
        Center(
          child: Container(
            width: 260,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 36,
          child: Text(
            'Scan a QR code or product barcode',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
