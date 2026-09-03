import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'firebase_initializer.dart';

/// Fetches the product catalog from Firebase Firestore when online.
///
/// The Firestore structure expected by this service:
///   Collection: "products"
///     Document ID: product.id  (e.g. "001", "021")
///     Fields:
///       id          : String
///       title       : String
///       category    : String
///       keywords    : List<String>
///       video       : String  (e.g. "assets/videos/peacock_fountain.mp4")
///       thumbnail   : String  (e.g. "assets/thumbnails/peacock_fountain.jpg")
///       description : String
///
/// Falls back silently to null when:
///   - Firebase is not initialized (credentials not yet filled in)
///   - Device is offline
///   - Firestore collection is empty / doesn't exist yet
class RemoteCatalogService {
  static const String _productsCollection = 'products';

  /// Returns the latest product list from Firestore, or null on any failure.
  /// Callers should fall back to the bundled JSON when this returns null.
  Future<List<Product>?> fetchProducts() async {
    if (!FirebaseInitializer.isInitialized) return null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_productsCollection)
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) return null;

      final products = snapshot.docs
          .map((doc) {
            try {
              return Product.fromJson(doc.data());
            } catch (_) {
              return null;
            }
          })
          .whereType<Product>()
          .toList();

      return products.isEmpty ? null : products;
    } catch (_) {
      // Network error, permission error, etc. — caller uses bundled data.
      return null;
    }
  }

  /// Writes a single product to Firestore (used by admin dashboard sync).
  Future<void> upsertProduct(Product product) async {
    if (!FirebaseInitializer.isInitialized) return;

    await FirebaseFirestore.instance
        .collection(_productsCollection)
        .doc(product.id)
        .set(product.toJson());
  }

  /// Deletes a product from Firestore.
  Future<void> deleteProduct(String productId) async {
    if (!FirebaseInitializer.isInitialized) return;

    await FirebaseFirestore.instance
        .collection(_productsCollection)
        .doc(productId)
        .delete();
  }
}
