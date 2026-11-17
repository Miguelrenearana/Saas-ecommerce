import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/network/api_exception.dart';
import '../../core/storage/local_catalog_db.dart';
import '../../core/storage/local_image_cache.dart';
import 'catalog_api.dart';
import 'catalog_models.dart';

enum CatalogStatus { idle, loading, ready, error }

enum GenderFilter {
  all('Todos'),
  women('Damas'),
  men('Caballeros');

  const GenderFilter(this.label);
  final String label;
}

class CatalogController extends ChangeNotifier {
  CatalogController({
    CatalogApi? api,
    LocalCatalogDb? localDb,
  })  : _api = api ?? CatalogApi(),
        _localDb = localDb ?? LocalCatalogDb();

  final CatalogApi _api;
  final LocalCatalogDb _localDb;

  CatalogStatus status = CatalogStatus.idle;
  String? errorMessage;
  GenderFilter genderFilter = GenderFilter.all;
  List<Product> _rawProducts = const [];
  List<Product> products = const [];
  List<Category> categories = const [];
  List<Size> sizes = const [];
  List<CatalogColor> colors = const [];
  List<Season> seasons = const [];
  List<Collection> collections = const [];
  List<Branch> branches = const [];
  List<TenantCompany> tenants = const [];
  String searchQuery = '';
  String? tenantId;
  String? branchId;
  String? categoryId;
  String? sizeId;
  String? colorId;
  String? seasonId;
  String? collectionId;

  // Estado Offline (CU08 / CU09)
  bool isOffline = false;
  bool isDownloadingOffline = false;
  OfflineSyncMeta? syncMeta;
  int cachedProductCount = 0;

  Future<void> load() async {
    errorMessage = null;

    // 1. Cargar datos locales de SQLite inmediatamente (renderizado instantáneo en 0.05s)
    await loadOfflineMeta();
    final localProducts = await _localDb.queryProducts(
      query: searchQuery,
      categoryId: categoryId,
      sizeId: sizeId,
      colorId: colorId,
    );

    if (localProducts.isNotEmpty) {
      products = localProducts;
      branches = await _localDb.getCachedBranches();
      categories = await _localDb.getCachedCategories();
      branchId ??= branches
          .where((b) => b.isDefault && b.isActive)
          .firstOrNull
          ?.id;
      status = CatalogStatus.ready;
      notifyListeners();
    } else {
      status = CatalogStatus.loading;
      notifyListeners();
    }

    // 2. Refrescar desde la API central
    try {
      final results = await Future.wait([
        _api.getBranches(),
        _api.getTenants(),
      ]);
      branches = results[0] as List<Branch>;
      tenants = results[1] as List<TenantCompany>;
      branchId ??= branches
          .where((branch) => branch.isDefault && branch.isActive)
          .firstOrNull
          ?.id;
      await Future.wait([_loadProducts(), _loadFilters()]);
      isOffline = false;
      status = CatalogStatus.ready;
      notifyListeners();

      // Guardar en SQLite sucursales y categorías para que los filtros funcionen offline
      await _localDb.saveBranches(branches);
      await _localDb.saveCategories(categories);

      // Precargar imágenes en almacenamiento interno para navegación offline resiliente
      _precacheProductImages();

      // Si la caché local tiene menos productos o está vacía, sincronizar catálogo en segundo plano
      if (cachedProductCount < products.length) {
        downloadOfflineCatalog();
      }
    } catch (error) {
      // Fallback resiliente a SQLite cuando no hay red o está en Modo Avión
      await _fallbackToLocalDatabase(error);
    }
  }

  Future<void> loadOfflineMeta() async {
    try {
      syncMeta = await _localDb.getSyncMeta();
      cachedProductCount = await _localDb.getCachedProductCount();
    } catch (_) {
      // Ignorar errores de lectura inicial
    }
    notifyListeners();
  }

  Future<bool> downloadOfflineCatalog() async {
    isDownloadingOffline = true;
    notifyListeners();

    try {
      final pack = await _api.getOfflinePack(branchId: branchId);
      final count = await _localDb.saveOfflinePack(pack);
      cachedProductCount = count;
      syncMeta = await _localDb.getSyncMeta();
      isDownloadingOffline = false;
      notifyListeners();
      _precacheProductImages();
      return true;
    } catch (e) {
      isDownloadingOffline = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleSimulatedOffline() async {
    isOffline = !isOffline;
    if (isOffline) {
      final localProducts = await _localDb.queryProducts(
        query: searchQuery,
        categoryId: categoryId,
        sizeId: sizeId,
        colorId: colorId,
      );
      products = localProducts;
      status = CatalogStatus.ready;
      errorMessage = null;
    } else {
      await _reloadProducts();
    }
    notifyListeners();
  }

  Future<void> updateFilters({
    String? tenantId,
    String? branchId,
    String? categoryId,
    String? sizeId,
    String? colorId,
    String? seasonId,
    String? collectionId,
  }) async {
    this.tenantId = tenantId;
    this.branchId = branchId;
    this.categoryId = categoryId;
    this.sizeId = sizeId;
    this.colorId = colorId;
    this.seasonId = seasonId;
    this.collectionId = collectionId;
    await _reloadProducts();
  }

  Future<void> search(String value) async {
    searchQuery = value.trim();
    await _reloadProducts();
  }

  void setGenderFilter(GenderFilter filter) {
    if (genderFilter == filter) return;
    genderFilter = filter;
    products = _applyGenderFilter(_rawProducts);
    notifyListeners();
  }

  List<Product> _applyGenderFilter(List<Product> source) {
    if (genderFilter == GenderFilter.all) return source;
    final categoryById = {
      for (final cat in categories) cat.id: cat.name.toLowerCase(),
    };

    return source.where((product) {
      final name = product.name.toLowerCase();
      final desc = (product.description ?? '').toLowerCase();
      final cat = categoryById[product.categoryId] ?? '';
      final text = '$name $desc $cat';

      if (genderFilter == GenderFilter.women) {
        const womenWords = [
          'mujer',
          'mujeres',
          'dama',
          'damas',
          'women',
          'woman',
          'female',
          'blusa',
          'vestido',
          'falda',
          'top',
          'tacones',
          'tacos',
          'chica',
          'chicas',
        ];
        return womenWords.any((w) => text.contains(w));
      }

      if (genderFilter == GenderFilter.men) {
        const menWords = [
          'hombre',
          'hombres',
          'caballero',
          'caballeros',
          'men',
          'man',
          'male',
          'camisa',
          'pantalon',
          'pantalón',
          'corbata',
          'traje',
          'polera',
          'chico',
          'chicos',
        ];
        return menWords.any((w) => text.contains(w));
      }

      return true;
    }).toList(growable: false);
  }

  Future<void> clearFilters() {
    searchQuery = '';
    genderFilter = GenderFilter.all;
    return updateFilters();
  }

  Future<void> _loadProducts() async {
    if (isOffline) {
      _rawProducts = await _localDb.queryProducts(
        query: searchQuery,
        categoryId: categoryId,
        sizeId: sizeId,
        colorId: colorId,
      );
    } else {
      _rawProducts = await _api.getProducts(
        query: searchQuery,
        tenantId: tenantId,
        branchId: branchId,
        categoryId: categoryId,
        sizeId: sizeId,
        colorId: colorId,
        seasonId: seasonId,
        collectionId: collectionId,
      );
    }
    products = _applyGenderFilter(_rawProducts);
    _precacheProductImages();
  }

  void _precacheProductImages() {
    final urls = <String>{};
    for (final p in products) {
      if (p.imageUrl != null && p.imageUrl!.trim().isNotEmpty) {
        urls.add(p.imageUrl!.trim());
      }
      final vars = p.variants;
      if (vars != null) {
        for (final v in vars) {
          if (v.imageUrl != null && v.imageUrl!.trim().isNotEmpty) {
            urls.add(v.imageUrl!.trim());
          }
        }
      }
    }
    if (urls.isNotEmpty) {
      LocalImageCache.instance.precacheUrls(urls.toList());
    }
  }

  Future<void> _loadFilters() async {
    final results = await Future.wait([
      _api.getCategories(),
      _api.getSizes(),
      _api.getColors(),
      _api.getSeasons(),
      _api.getCollections(),
    ]);
    categories = results[0] as List<Category>;
    sizes = results[1] as List<Size>;
    colors = results[2] as List<CatalogColor>;
    seasons = results[3] as List<Season>;
    collections = results[4] as List<Collection>;
  }

  Future<void> _reloadProducts() async {
    if (isOffline) {
      products = await _localDb.queryProducts(
        query: searchQuery,
        categoryId: categoryId,
        sizeId: sizeId,
        colorId: colorId,
      );
      status = CatalogStatus.ready;
      notifyListeners();
      return;
    }

    status = CatalogStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await _loadProducts();
      isOffline = false;
      status = CatalogStatus.ready;
    } catch (error) {
      await _fallbackToLocalDatabase(error);
    }
    notifyListeners();
  }

  Future<void> _fallbackToLocalDatabase(Object originalError) async {
    final localProducts = await _localDb.queryProducts(
      query: searchQuery,
      categoryId: categoryId,
      sizeId: sizeId,
      colorId: colorId,
    );

    if (localProducts.isNotEmpty || cachedProductCount > 0) {
      _rawProducts = localProducts;
      products = _applyGenderFilter(localProducts);
      final cachedB = await _localDb.getCachedBranches();
      if (cachedB.isNotEmpty) branches = cachedB;
      final cachedC = await _localDb.getCachedCategories();
      if (cachedC.isNotEmpty) categories = cachedC;
      isOffline = true;
      status = CatalogStatus.ready;
      errorMessage = null;
    } else if (products.isNotEmpty) {
      isOffline = true;
      status = CatalogStatus.ready;
      errorMessage = null;
    } else {
      status = CatalogStatus.error;
      errorMessage = _messageFor(originalError);
    }
  }

  static String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo cargar el catálogo.';
  }
}
