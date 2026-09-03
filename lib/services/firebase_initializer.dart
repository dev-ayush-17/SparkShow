import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Safely initializes Firebase.
///
/// If the credentials in firebase_options.dart are still placeholders
/// (YOUR_*), initialization is skipped and the app runs in full offline mode.
/// Once you fill in real credentials, Firebase will initialize automatically.
class FirebaseInitializer {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    // Guard: skip if credentials haven't been filled in yet
    if (_hasPlaceholderCredentials()) {
      // App continues in offline-only mode. All Firebase-dependent
      // services (remote catalog, OTA updates) will be skipped gracefully.
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
    } catch (e) {
      // Firebase initialization failed — continue in offline mode.
      // This ensures flutter run always works even with bad credentials.
      _isInitialized = false;
    }
  }

  /// Returns true if the user hasn't filled in their Firebase credentials yet.
  static bool _hasPlaceholderCredentials() {
    return DefaultFirebaseOptions.android.apiKey.startsWith('YOUR_');
  }
}
