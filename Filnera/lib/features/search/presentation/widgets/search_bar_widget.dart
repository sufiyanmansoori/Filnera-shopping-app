import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/constants/app_colors.dart';
import '../pages/barcode_scanner_page.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.onTap,
    this.onChanged,
    this.initialQuery = '',
  });

  final ValueChanged<String> onSearch;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String initialQuery;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();
  final _imagePicker = ImagePicker();
  final _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openVisualSearch() async {
    final image = await showModalBottomSheet<XFile>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () async {
                final cameras = await availableCameras();
                if (!sheetContext.mounted || cameras.isEmpty) return;
                final captured = await Navigator.of(sheetContext).push<XFile>(
                  MaterialPageRoute(
                    builder: (_) => CameraCapturePage(camera: cameras.first),
                  ),
                );
                if (sheetContext.mounted && captured != null) {
                  Navigator.pop(sheetContext, captured);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Upload from Gallery'),
              onTap: () async {
                final selected = await _imagePicker.pickImage(
                  source: ImageSource.gallery,
                );
                if (sheetContext.mounted && selected != null) {
                  Navigator.pop(sheetContext, selected);
                }
              },
            ),
          ],
        ),
      ),
    );
    if (!mounted || image == null) return;
    debugPrint('Image search endpoint payload: ${image.path}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image ready for visual product search')),
    );
  }

  Future<void> _startVoiceSearch() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    final available = await _speech.initialize(
      onStatus: (status) {
        if (mounted && status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (!mounted) return;
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice search is not available')),
      );
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          widget.onSearch(result.recognizedWords.trim());
        }
      },
    );
  }

  Future<void> _openScanner() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (!mounted || code == null || code.trim().isEmpty) return;
    _controller.text = code;
    widget.onSearch(code);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onSearch('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.search, color: AppColors.textSecondary),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  setState(() {});
                },
                onSubmitted: (value) => widget.onSearch(value.trim()),
                decoration: const InputDecoration(
                  hintText: 'Search for products...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_controller.text.isNotEmpty)
              IconButton(
                onPressed: _clearSearch,
                tooltip: 'Clear search',
                color: AppColors.textSecondary,
                icon: const Icon(Icons.clear, size: 20),
              ),
            IconButton(
              onPressed: _openVisualSearch,
              tooltip: 'Visual search',
              color: Colors.black87,
              icon: const Icon(Icons.camera_alt_outlined, size: 22),
            ),
            IconButton(
              onPressed: _startVoiceSearch,
              tooltip: 'Voice search',
              color: _isListening ? AppColors.primary : Colors.black87,
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 22),
            ),
            IconButton(
              onPressed: _openScanner,
              tooltip: 'Scan barcode or QR code',
              color: Colors.black87,
              icon: const Icon(Icons.qr_code_scanner, size: 22),
            ),
          ],
        ),
      ),
    ),
  );
}

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key, required this.camera});

  final CameraDescription camera;

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  late final CameraController _cameraController;
  late final Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      if (mounted) Navigator.pop(context, image);
    } on CameraException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to capture image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Take photo')),
    body: FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_cameraController),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: FloatingActionButton(
                  onPressed: _takePicture,
                  child: const Icon(Icons.camera),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
