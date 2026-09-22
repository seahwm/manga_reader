import 'dart:io';
import 'package:flutter/material.dart';

class AutoCropImage extends StatefulWidget {
  final File file;
  final bool autoCrop;

  const AutoCropImage({Key? key, required this.file, required this.autoCrop}) : super(key: key);

  @override
  _AutoCropImageState createState() => _AutoCropImageState();
}

class _AutoCropImageState extends State<AutoCropImage> {
  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  ImageInfo? _imageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(AutoCropImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file.path != oldWidget.file.path) {
      _removeListener();
      _loadImage();
    }
  }

  void _loadImage() {
    setState(() {
      _isLoading = true;
      _imageInfo = null;
    });

    _imageProvider = FileImage(widget.file);
    _imageStream = _imageProvider!.resolve(const ImageConfiguration());
    _imageListener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (mounted) {
          setState(() {
            _imageInfo = info;
            _isLoading = false;
          });
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
    _imageStream!.addListener(_imageListener!);
  }

  void _removeListener() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
  }

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_imageInfo == null) {
      return const Center(child: Icon(Icons.error));
    }

    final double width = _imageInfo!.image.width.toDouble();
    final double height = _imageInfo!.image.height.toDouble();
    final double aspectRatio = width / height;

    if (widget.autoCrop && aspectRatio > 1.2) {
      // It's a combined page, crop it into two
      return LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Right half (usually read right-to-left in manga)
              ClipRect(
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 0.5,
                  child: Image(
                    image: _imageProvider!,
                    width: constraints.maxWidth * 2,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              // Left half
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.5,
                  child: Image(
                    image: _imageProvider!,
                    width: constraints.maxWidth * 2,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // Default: show the full image
    return Image(image: _imageProvider!);
  }
}
