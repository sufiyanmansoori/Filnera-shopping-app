import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AutoplayVideoReel extends StatefulWidget {
  const AutoplayVideoReel({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.subtitle,
  });

  final String videoUrl;
  final String title;
  final String subtitle;

  @override
  State<AutoplayVideoReel> createState() => _AutoplayVideoReelState();
}

class _AutoplayVideoReelState extends State<AutoplayVideoReel> {
  late final VideoPlayerController _controller;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color(0xCC000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              children: [
                IconButton(
                  tooltip: _muted ? 'Unmute video' : 'Mute video',
                  onPressed: () {
                    setState(() => _muted = !_muted);
                    _controller.setVolume(_muted ? 0 : 1);
                  },
                  icon: Icon(
                    _muted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                IconButton(
                  tooltip: _controller.value.isPlaying
                      ? 'Pause video'
                      : 'Play video',
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 24,
            left: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  'LIVE VIDEO',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
