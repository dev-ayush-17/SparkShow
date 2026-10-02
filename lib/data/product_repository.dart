import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../services/remote_catalog_service.dart';

typedef DataLoader = Future<String> Function();

/// Repository that serves product data to the UI.
///
/// Data source priority:
///   1. Firestore (remote) — used when Firebase is configured and device is online
///   2. Bundled assets/data/products.json — always-available offline fallback
///
/// The UI layer never needs to know which source was used.
class ProductRepository {
  static const String _productsPath = 'assets/data/products.json';

  final DataLoader _dataLoader;
  final RemoteCatalogService _remoteService;
  List<Product>? _cachedProducts;

  ProductRepository({
    DataLoader? dataLoader,
    RemoteCatalogService? remoteService,
  })  : _dataLoader = dataLoader ?? _defaultLoader,
        _remoteService = remoteService ?? RemoteCatalogService();

  static Future<String> _defaultLoader() {
    return rootBundle.loadString(_productsPath);
  }

  /// Loads products from Firestore if available, otherwise from bundled JSON.
  Future<List<Product>> getProducts() async {
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }

    // Try remote first (no-op if Firebase not yet configured)
    final remoteProducts = await _remoteService.fetchProducts();
    if (remoteProducts != null && remoteProducts.isNotEmpty) {
      _cachedProducts = remoteProducts;
      return _cachedProducts!;
    }

    // Fallback to bundled assets
    return _loadFromAssets();
  }

  /// Bypasses cache and re-fetches (used after an OTA catalog update).
  Future<List<Product>> refreshProducts() async {
    _cachedProducts = null;
    return getProducts();
  }

  Future<List<Product>> _loadFromAssets() async {
    try {
      final String jsonString = await _dataLoader();
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      _cachedProducts = jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      return _cachedProducts!;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    final products = await getProducts();
    final categories = products.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<List<Product>> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      return await getProducts();
    }

    final products = await getProducts();
    final lowerQuery = query.toLowerCase();

    return products.where((product) {
      if (product.title.toLowerCase().contains(lowerQuery)) return true;
      if (product.category.toLowerCase().contains(lowerQuery)) return true;
      if (product.description.toLowerCase().contains(lowerQuery)) return true;
      if (product.keywords
          .any((keyword) => keyword.toLowerCase().contains(lowerQuery))) {
        return true;
      }
      return false;
    }).toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final products = await getProducts();

    if (category.isEmpty || category == 'All') {
      return products;
    }

    return products.where((p) => p.category == category).toList();
  }

  Future<List<Product>> getFilteredProducts({
    String? category,
    String? searchQuery,
  }) async {
    List<Product> products = await getProducts();

    if (category != null && category.isNotEmpty && category != 'All') {
      products = products.where((p) => p.category == category).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      products = products.where((product) {
        if (product.title.toLowerCase().contains(lowerQuery)) return true;
        if (product.category.toLowerCase().contains(lowerQuery)) return true;
        if (product.description.toLowerCase().contains(lowerQuery)) return true;
        if (product.keywords
            .any((keyword) => keyword.toLowerCase().contains(lowerQuery))) {
          return true;
        }
        return false;
      }).toList();
    }

    return products;
  }

  void clearCache() {
    _cachedProducts = null;
  }
}
