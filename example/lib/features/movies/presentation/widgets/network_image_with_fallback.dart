import 'package:flutter/material.dart';

class NetworkImageWithFallback extends StatelessWidget {
  const NetworkImageWithFallback({
    required this.url,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.showLoader = false,
    this.loaderStrokeWidth = 4.0,
    super.key,
  });

  final String? url;
  final Widget fallback;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool showLoader;
  final double loaderStrokeWidth;

  @override
  Widget build(BuildContext context) {
    final String? url = this.url;
    if (url == null || url.isEmpty) {
      return fallback;
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: showLoader
          ? (BuildContext context, Widget child, ImageChunkEvent? progress) {
              if (progress == null) {
                return child;
              }
              return ColoredBox(
                color: Colors.black12,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: loaderStrokeWidth,
                  ),
                ),
              );
            }
          : null,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) =>
              fallback,
    );
  }
}
