import 'package:festum/core/network/api_url_resolver.dart';
import 'package:flutter/material.dart';

class AppRemoteImage extends StatefulWidget {
  const AppRemoteImage({
    required this.imageUrl,
    required this.fit,
    required this.placeholder,
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.headers,
    this.onForbidden,
  });

  final String imageUrl;
  final BoxFit fit;
  final Widget placeholder;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Map<String, String>? headers;
  final Future<void> Function()? onForbidden;

  @override
  State<AppRemoteImage> createState() => _AppRemoteImageState();
}

class _AppRemoteImageState extends State<AppRemoteImage> {
  bool _didHandleForbidden = false;

  @override
  Widget build(BuildContext context) {
    final String resolvedImageUrl = resolveApiAssetUrl(widget.imageUrl);
    if (resolvedImageUrl.isEmpty) {
      return _wrap(widget.placeholder);
    }

    return _wrap(
      Image.network(
        resolvedImageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        headers: widget.headers,
        loadingBuilder:
            (
              BuildContext context,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) {
                return child;
              }
              return const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              _handleForbidden(error);
              return widget.placeholder;
            },
      ),
    );
  }

  Widget _wrap(Widget child) {
    if (widget.borderRadius == null) {
      return child;
    }
    return ClipRRect(borderRadius: widget.borderRadius!, child: child);
  }

  void _handleForbidden(Object error) {
    if (_didHandleForbidden || widget.onForbidden == null) {
      return;
    }
    final String message = error.toString().toLowerCase();
    if (!message.contains('403')) {
      return;
    }
    _didHandleForbidden = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onForbidden?.call();
    });
  }
}
