import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class MediaPreview extends StatefulWidget {
  final String filePath;
  final bool isVideo;
  final VoidCallback? onRemove;

  const MediaPreview({
    super.key,
    required this.filePath,
    required this.isVideo,
    this.onRemove,
  });

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.isVideo
                ? _videoController?.value.isInitialized ?? false
                    ? VideoPlayer(_videoController!)
                    : const Center(child: CircularProgressIndicator())
                : Image.file(
                    File(widget.filePath),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        if (widget.onRemove != null)
          Positioned(
            right: 4,
            top: 4,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        if (widget.isVideo)
          const Positioned(
            bottom: 4,
            right: 4,
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 24,
            ),
          ),
      ],
    );
  }
}