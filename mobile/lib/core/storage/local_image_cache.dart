import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Gestor de caché persistente de imágenes en disco (almacenamiento interno).
/// Permite que las imágenes de prendas y variantes carguen al 100% de forma
/// instantánea y permanezcan disponibles cuando el dispositivo se desconecta
/// o entra en Modo Avión.
class LocalImageCache {
  LocalImageCache._();
  static final LocalImageCache instance = LocalImageCache._();

  Directory? _cacheDir;
  final Set<String> _downloadingUrls = {};
  final Map<String, String> _urlToFilePath = {};

  Future<Directory> get _dir async {
    if (_cacheDir != null) return _cacheDir!;
    final baseDir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(p.join(baseDir.path, 'garment_images_cache'));
    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }
    _cacheDir = imgDir;
    return imgDir;
  }

  String _getFileName(String url) {
    final hash = md5.convert(utf8.encode(url.trim())).toString();
    return '$hash.jpg';
  }

  /// Verifica de forma síncrona/memoria si ya conocemos la ruta del archivo
  File? getCachedFileSync(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final path = _urlToFilePath[url.trim()];
    if (path != null) {
      final f = File(path);
      if (f.existsSync() && f.lengthSync() > 0) {
        return f;
      }
    }
    return null;
  }

  /// Devuelve el File si ya está descargado en disco, o null si no existe.
  Future<File?> getLocalImageFile(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    final cleanUrl = url.trim();

    final memoized = getCachedFileSync(cleanUrl);
    if (memoized != null) return memoized;

    try {
      final dir = await _dir;
      final file = File(p.join(dir.path, _getFileName(cleanUrl)));
      if (await file.exists() && await file.length() > 0) {
        _urlToFilePath[cleanUrl] = file.path;
        return file;
      }
    } catch (e) {
      debugPrint('[LocalImageCache] Error comprobando archivo en caché: $e');
    }
    return null;
  }

  /// Descarga la imagen y la guarda en disco de forma persistente.
  Future<File?> downloadAndCache(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    final cleanUrl = url.trim();

    final existing = await getLocalImageFile(cleanUrl);
    if (existing != null) return existing;

    if (_downloadingUrls.contains(cleanUrl)) {
      for (var i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        final f = getCachedFileSync(cleanUrl);
        if (f != null) return f;
        if (!_downloadingUrls.contains(cleanUrl)) break;
      }
      return getLocalImageFile(cleanUrl);
    }

    _downloadingUrls.add(cleanUrl);
    HttpClient? client;
    try {
      final dir = await _dir;
      final targetFile = File(p.join(dir.path, _getFileName(cleanUrl)));
      final tempFile = File(p.join(dir.path, '${_getFileName(cleanUrl)}.tmp'));

      client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
      final request = await client.getUrl(Uri.parse(cleanUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        if (bytes.isNotEmpty) {
          await tempFile.writeAsBytes(bytes, flush: true);
          await tempFile.rename(targetFile.path);
          _urlToFilePath[cleanUrl] = targetFile.path;
          return targetFile;
        }
      }
    } catch (_) {
      // Falla esperada si no hay conexión; se mantiene el fallback
    } finally {
      client?.close(force: true);
      _downloadingUrls.remove(cleanUrl);
    }
    return null;
  }

  /// Precarga un lote de URLs en segundo plano sin bloquear la interfaz
  Future<void> precacheUrls(List<String> urls) async {
    if (urls.isEmpty) return;
    final uniqueUrls =
        urls.map((u) => u.trim()).where((u) => u.isNotEmpty).toSet().toList();

    const batchSize = 3;
    for (var i = 0; i < uniqueUrls.length; i += batchSize) {
      final end =
          (i + batchSize < uniqueUrls.length) ? i + batchSize : uniqueUrls.length;
      final batch = uniqueUrls.sublist(i, end);
      await Future.wait(batch.map((url) => downloadAndCache(url)));
    }
  }
}
