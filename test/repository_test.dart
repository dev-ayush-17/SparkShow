import 'package:flutter_test/flutter_test.dart';
import 'package:fireworks_showcase/data/product_repository.dart';

const String testProductsJson = '''
[
  {
    "id": "001",
    "title": "Peacock Fountain",
    "category": "Fountain",
    "keywords": ["peacock", "fountain", "colorful", "decorative", "ground"],
    "video": "assets/videos/peacock_fountain.mp4",
    "thumbnail": "assets/thumbnails/peacock_fountain.jpg",
    "description": "A beautiful peacock-shaped fountain with colorful LED lights"
  },
  {
    "id": "002",
    "title": "Golden Rain",
    "category": "Fountain",
    "keywords": ["golden", "rain", "sparkle", "fountain", "ground"],
    "video": "assets/videos/golden_rain.mp4",
    "thumbnail": "assets/thumbnails/golden_rain.jpg",
    "description": "Golden sparkles cascade down like rain"
  },
  {
    "id": "003",
    "title": "Dragon Rocket",
    "category": "Rocket",
    "keywords": ["dragon", "rocket", "aerial", "fire", "flight"],
    "video": "assets/videos/dragon_rocket.mp4",
    "thumbnail": "assets/thumbnails/dragon_rocket.jpg",
    "description": "Dragon-shaped rocket with fire trail effects"
  },
  {
    "id": "004",
    "title": "Sky Blossom",
    "category": "Rocket",
    "keywords": ["sky", "blossom", "flower", "aerial", "bloom"],
    "video": "assets/videos/sky_blossom.mp4",
    "thumbnail": "assets/thumbnails/sky_blossom.jpg",
    "description": "Blooming flower effect in the sky"
  },
  {
    "id": "005",
    "title": "Ground Spinner",
    "category": "Ground",
    "keywords": ["ground", "spinner", "spinning", "ground_effect", "rotating"],
    "video": "assets/videos/ground_spinner.mp4",
    "thumbnail": "assets/thumbnails/ground_spinner.jpg",
    "description": "Fast-spinning ground firework with color trails"
  },
  {
    "id": "006",
    "title": "Thunder Crackers",
    "category": "Ground",
    "keywords": ["thunder", "crackers", "loud", "noise", "ground"],
    "video": "assets/videos/thunder_crackers.mp4",
    "thumbnail": "assets/thumbnails/thunder_crackers.jpg",
    "description": "Traditional firecrackers with thunderous sound"
  },
  {
    "id": "007",
    "title": "Royal Crown",
    "category": "Decorative",
    "keywords": ["royal", "crown", "decorative", "elegant", "display"],
    "video": "assets/videos/royal_crown.mp4",
    "thumbnail": "assets/thumbnails/royal_crown.jpg",
    "description": "Crown-shaped decorative firework"
  },
  {
    "id": "008",
    "title": "Christmas Tree",
    "category": "Decorative",
    "keywords": ["christmas", "tree", "holiday", "decorative", "festive"],
    "video": "assets/videos/christmas_tree.mp4",
    "thumbnail": "assets/thumbnails/christmas_tree.jpg",
    "description": "Christmas tree shaped firework with lights"
  },
  {
    "id": "009",
    "title": "Mega Combo Pack",
    "category": "Combo",
    "keywords": ["mega", "combo", "pack", "variety", "multiple"],
    "video": "assets/videos/mega_combo.mp4",
    "thumbnail": "assets/thumbnails/mega_combo.jpg",
    "description": "Multiple fireworks in one package"
  },
  {
    "id": "010",
    "title": "Family Celebration Pack",
    "category": "Combo",
    "keywords": ["family", "celebration", "pack", "safe", "variety"],
    "video": "assets/videos/family_celebration.mp4",
    "thumbnail": "assets/thumbnails/family_celebration.jpg",
    "description": "Safe family-friendly combination pack"
  }
]
''';

void main() {
  group('ProductRepository', () {
    late ProductRepository repository;

    setUp(() {
      repository = ProductRepository(
        dataLoader: () async => testProductsJson,
      );
    });

    test('should load products from JSON', () async {
      final products = await repository.getProducts();

      expect(products, isNotEmpty);
      expect(products.length, equals(10));
    });

    test('should return categories', () async {
      final categories = await repository.getCategories();

      expect(categories, isNotEmpty);
      expect(categories, contains('Fountain'));
      expect(categories, contains('Rocket'));
      expect(categories, contains('Ground'));
      expect(categories, contains('Decorative'));
      expect(categories, contains('Combo'));
    });

    test('should search products by title', () async {
      final results = await repository.searchProducts('peacock');

      expect(results, isNotEmpty);
      expect(results.any((p) => p.title.contains('Peacock')), isTrue);
    });

    test('should search products by category', () async {
      final results = await repository.searchProducts('fountain');

      expect(results, isNotEmpty);
      expect(results.every((p) => p.category == 'Fountain'), isTrue);
    });

    test('should search products by keywords', () async {
      final results = await repository.searchProducts('colorful');

      expect(results, isNotEmpty);
      expect(
        results.any((p) => p.keywords.contains('colorful')),
        isTrue,
      );
    });

    test('should be case-insensitive', () async {
      final results = await repository.searchProducts('PEACOCK');

      expect(results, isNotEmpty);
    });

    test('should return empty list for no matches', () async {
      final results = await repository.searchProducts('xyz123nonexistent');

      expect(results, isEmpty);
    });

    test('should return all products for empty query', () async {
      final allProducts = await repository.getProducts();
      final results = await repository.searchProducts('');

      expect(results.length, equals(allProducts.length));
    });

    test('should filter by category', () async {
      final results = await repository.getProductsByCategory('Rocket');

      expect(results, isNotEmpty);
      expect(results.every((p) => p.category == 'Rocket'), isTrue);
    });

    test('should return all products for "All" category', () async {
      final allProducts = await repository.getProducts();
      final results = await repository.getProductsByCategory('All');

      expect(results.length, equals(allProducts.length));
    });

    test('should combine search and category filter', () async {
      final results = await repository.getFilteredProducts(
        category: 'Fountain',
        searchQuery: 'golden',
      );

      expect(results, isNotEmpty);
      expect(
        results.every((p) =>
            p.category == 'Fountain' &&
            (p.title.toLowerCase().contains('golden') ||
                p.keywords.any((k) => k.toLowerCase().contains('golden')))),
        isTrue,
      );
    });

    test('should cache products after first load', () async {
      await repository.getProducts();
      await repository.getProducts();

      // Second call should use cache
      final products = await repository.getProducts();
      expect(products.length, equals(10));
    });

    test('should clear cache', () async {
      await repository.getProducts();
      repository.clearCache();
      
      // After clearing cache, it should reload
      final products = await repository.getProducts();
      expect(products.length, equals(10));
    });
  });

  group('ProductRepository - Edge Cases', () {
    test('should handle empty JSON array', () async {
      final repository = ProductRepository(
        dataLoader: () async => '[]',
      );

      final products = await repository.getProducts();
      expect(products, isEmpty);
    });

    test('should handle invalid JSON gracefully', () async {
      final repository = ProductRepository(
        dataLoader: () async => 'not valid json',
      );

      final products = await repository.getProducts();
      expect(products, isEmpty);
    });

    test('should handle missing fields gracefully', () async {
      final repository = ProductRepository(
        dataLoader: () async => '''
      [
        {
          "id": "001",
          "title": "Test"
        }
      ]
      ''',
      );

      // Should not crash, but may return empty due to missing required fields
      final products = await repository.getProducts();
      // The repository catches exceptions and returns empty list
      expect(products, isA<List>());
    });
  });
}
