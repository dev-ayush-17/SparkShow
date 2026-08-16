class Product {
  final String id;
  final String title;
  final String category;
  final List<String> keywords;
  final String video;
  final String thumbnail;
  final String description;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.keywords,
    required this.video,
    required this.thumbnail,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      keywords: List<String>.from(json['keywords'] as List),
      video: json['video'] as String,
      thumbnail: json['thumbnail'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'keywords': keywords,
      'video': video,
      'thumbnail': thumbnail,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, title: $title, category: $category)';
  }
}
