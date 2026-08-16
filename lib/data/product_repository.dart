import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';

typedef DataLoader = Future<String> Function();

class ProductRepository {
  static const String _productsPath = 'assets/data/products.json';

  final DataLoader _dataLoader;
  List<Product>? _cachedProducts;

  ProductRepository({DataLoader? dataLoader})
      : _dataLoader = dataLoader ?? _defaultLoader;

  static Future<String> _defaultLoader() {
    return rootBundle.loadString(_productsPath);
  }

  Future<List<Product>> getProducts() async {
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }

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
