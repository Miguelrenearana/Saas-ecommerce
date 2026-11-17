import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/core/storage/local_image_cache.dart';

class ProductImage extends StatefulWidget {
  const ProductImage({
    super.key,
    this.imageUrl,
    this.imageUrls = const [],
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.cacheWidth = 450,
    this.cacheHeight,
    this.enableCarousel = false,
  });

  final String? imageUrl;
  final List<String> imageUrls;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool enableCarousel;

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  final Map<String, File?> _cachedFiles = {};
  bool _disposed = false;

  List<String> get _urls {
    final primary = widget.imageUrl?.trim();
    return [
      if (primary != null && primary.isNotEmpty) primary,
      ...widget.imageUrls.map((url) => url.trim()).where((url) => url.isNotEmpty),
    ];
  }

  @override
  void initState() {
    super.initState();
    _checkAndCacheImages();
  }

  @override
  void didUpdateWidget(ProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.imageUrls != widget.imageUrls) {
      _checkAndCacheImages();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _checkAndCacheImages() {
    for (final url in _urls) {
      final syncFile = LocalImageCache.instance.getCachedFileSync(url);
      if (syncFile != null) {
        _cachedFiles[url] = syncFile;
      } else {
        LocalImageCache.instance.getLocalImageFile(url).then((file) {
          if (_disposed) return;
          if (file != null) {
            setState(() {
              _cachedFiles[url] = file;
            });
          } else {
            // Intenta descargar y persistir en disco si hay conexión a internet
            LocalImageCache.instance.downloadAndCache(url).then((downloaded) {
              if (_disposed) return;
              if (downloaded != null) {
                setState(() {
                  _cachedFiles[url] = downloaded;
                });
              }
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    if (urls.isEmpty) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: _placeholder(context),
      );
    }

    Widget content;
    if (widget.enableCarousel && urls.length > 1) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: urls.length,
            itemBuilder: (_, index) => _buildSingleImage(context, urls[index]),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var index = 0; index < urls.length; index++)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Si la URL principal aún no está en caché pero existe una alternativa precargada
      String activeUrl = urls.first;
      File? activeFile = _cachedFiles[activeUrl];
      if (activeFile == null) {
        for (final u in urls) {
          if (_cachedFiles[u] != null) {
            activeUrl = u;
            activeFile = _cachedFiles[u];
            break;
          }
        }
      }
      content = _buildSingleImage(context, activeUrl, fileOverride: activeFile);
    }

    return ClipRRect(borderRadius: widget.borderRadius, child: content);
  }

  Widget _buildSingleImage(BuildContext context, String url,
      {File? fileOverride}) {
    final file = fileOverride ?? _cachedFiles[url];
    if (file != null) {
      return Image.file(
        file,
        fit: widget.fit,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: widget.cacheWidth,
        cacheHeight: widget.cacheHeight,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }

    return Image.network(
      url,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => _placeholder(context),
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _placeholder(context, loading: true),
    );
  }

  Widget _placeholder(BuildContext context, {bool loading = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                ),
              )
            : Icon(
                Icons.image_outlined,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 28,
              ),
      ),
    );
  }
}
