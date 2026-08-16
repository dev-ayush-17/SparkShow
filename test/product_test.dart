import 'package:flutter_test/flutter_test.dart';
import 'package:fireworks_showcase/models/product.dart';

void main() {
  group('Product Model', () {
    test('should create Product from JSON', () {
      final json = {
        'id': '001',
        'title': 'Test Product',
        'category': 'Fountain',
        'keywords': ['test', 'fountain'],
        'video': 'assets/videos/test.mp4',
        'thumbnail': 'assets/thumbnails/test.jpg',
        'description': 'Test description',
      };

      final product = Product.fromJson(json);

      expect(product.id, '001');
      expect(product.title, 'Test Product');
      expect(product.category, 'Fountain');
      expect(product.keywords, ['test', 'fountain']);
      expect(product.video, 'assets/videos/test.mp4');
      expect(product.thumbnail, 'assets/thumbnails/test.jpg');
      expect(product.description, 'Test description');
    });

    test('should convert Product to JSON', () {
      final product = Product(
        id: '002',
        title: 'Another Product',
        category: 'Rocket',
        keywords: ['rocket', 'aerial'],
        video: 'assets/videos/rocket.mp4',
        thumbnail: 'assets/thumbnails/rocket.jpg',
        description: 'Rocket description',
      );

      final json = product.toJson();

      expect(json['id'], '002');
      expect(json['title'], 'Another Product');
      expect(json['category'], 'Rocket');
      expect(json['keywords'], ['rocket', 'aerial']);
      expect(json['video'], 'assets/videos/rocket.mp4');
      expect(json['thumbnail'], 'assets/thumbnails/rocket.jpg');
      expect(json['description'], 'Rocket description');
    });

    test('should implement equality based on id', () {
      final product1 = Product(
        id: '001',
        title: 'Product 1',
        category: 'Fountain',
        keywords: [],
        video: 'video1.mp4',
        thumbnail: 'thumb1.jpg',
        description: 'Description 1',
      );

      final product2 = Product(
        id: '001',
        title: 'Different Title',
        category: 'Rocket',
        keywords: ['different'],
        video: 'different.mp4',
        thumbnail: 'different.jpg',
        description: 'Different description',
      );

      final product3 = Product(
        id: '002',
        title: 'Product 1',
        category: 'Fountain',
        keywords: [],
        video: 'video1.mp4',
        thumbnail: 'thumb1.jpg',
        description: 'Description 1',
      );

      expect(product1, equals(product2));
      expect(product1, isNot(equals(product3)));
    });
  });
}
