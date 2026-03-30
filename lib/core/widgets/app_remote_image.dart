import 'dart:io';

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
  void didUpdateWidget(covariant AppRemoteImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl.trim() != widget.imageUrl.trim()) {
      _didHandleForbidden = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String rawImageUrl = widget.imageUrl.trim();
    final bool isLocalFile = _isLocalFilePath(rawImageUrl);
    final String resolvedImageUrl = isLocalFile
        ? rawImageUrl
        : resolveApiAssetUrl(rawImageUrl);
    if (resolvedImageUrl.isEmpty) {
      return _wrap(widget.placeholder);
    }

    return _wrap(
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final _CacheTarget cacheTarget = _resolveCacheTarget(
            context: context,
            constraints: constraints,
          );

          if (isLocalFile) {
            return Image.file(
              _toLocalFile(resolvedImageUrl),
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              cacheWidth: cacheTarget.width,
              cacheHeight: cacheTarget.height,
              filterQuality: FilterQuality.low,
              gaplessPlayback: true,
              frameBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    int? frame,
                    bool wasSynchronouslyLoaded,
                  ) {
                    if (wasSynchronouslyLoaded || frame != null) {
                      return child;
                    }
                    return widget.placeholder;
                  },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return widget.placeholder;
                  },
            );
          }

          return Image.network(
            resolvedImageUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            headers: widget.headers,
            cacheWidth: cacheTarget.width,
            cacheHeight: cacheTarget.height,
            filterQuality: FilterQuality.low,
            gaplessPlayback: true,
            frameBuilder:
                (
                  BuildContext context,
                  Widget child,
                  int? frame,
                  bool wasSynchronouslyLoaded,
                ) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return child;
                  }
                  return widget.placeholder;
                },
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  _handleForbidden(error);
                  return widget.placeholder;
                },
          );
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

  bool _isLocalFilePath(String value) {
    if (value.isEmpty) {
      return false;
    }
    final String normalized = value.toLowerCase();
    if (normalized.startsWith('file:')) {
      return true;
    }
    if (value.contains('\\')) {
      return true;
    }
    if (RegExp(r'^[a-zA-Z]:[/\\]').hasMatch(value)) {
      return true;
    }
    return normalized.startsWith('/storage/') ||
        normalized.startsWith('/data/') ||
        normalized.startsWith('/private/') ||
        normalized.startsWith('/var/mobile/');
  }

  File _toLocalFile(String value) {
    if (value.toLowerCase().startsWith('file:')) {
      return File.fromUri(Uri.parse(value));
    }
    return File(value);
  }

  _CacheTarget _resolveCacheTarget({
    required BuildContext context,
    required BoxConstraints constraints,
  }) {
    final double dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2.0;
    final int? width = _resolveDimension(
      explicit: widget.width,
      constrained: constraints.hasBoundedWidth ? constraints.maxWidth : null,
      dpr: dpr,
    );
    final int? height = _resolveDimension(
      explicit: widget.height,
      constrained: constraints.hasBoundedHeight ? constraints.maxHeight : null,
      dpr: dpr,
    );
    return _CacheTarget(width: width, height: height);
  }

  int? _resolveDimension({
    required double? explicit,
    required double? constrained,
    required double dpr,
  }) {
    final double? logical = _firstFinitePositive(explicit) ??
        _firstFinitePositive(constrained);
    if (logical == null) {
      return null;
    }
    final int physical = (logical * dpr).round();
    if (physical <= 0) {
      return null;
    }
    return physical.clamp(64, 2048);
  }

  double? _firstFinitePositive(double? value) {
    if (value == null || value.isNaN || value.isInfinite || value <= 0) {
      return null;
    }
    return value;
  }
}

class _CacheTarget {
  const _CacheTarget({required this.width, required this.height});

  final int? width;
  final int? height;
}
