// ============================================================
// FIREBASE CONFIGURATION - PLACEHOLDER
// ============================================================
// This file contains your Firebase project credentials.
// Follow admin_dashboard/SETUP_GUIDE.md to:
//   1. Create a Firebase project at console.firebase.google.com
//   2. Add an Android app with package name: com.example.fireworks_showcase
//   3. Download google-services.json and place it at android/app/google-services.json
//   4. Replace ALL placeholder values below with your actual values
//
// TO GET THESE VALUES:
//   Firebase Console → Project Settings → General → Your apps → Android
//   Click "google-services.json" and open the file; all values are there.
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'SparkShow is Android-only in V1. iOS not supported.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ──────────────────────────────────────────────────────────
  // ANDROID — fill these in from your google-services.json
  // ──────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    // Found in google-services.json → client[0].api_key[0].current_key
    apiKey: 'YOUR_ANDROID_API_KEY',
    // Found in google-services.json → project_info.project_id
    appId: 'YOUR_ANDROID_APP_ID',  // format: 1:xxxxxxxxxx:android:xxxxxxxxxx
    // Found in google-services.json → project_info.project_number
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    // Found in google-services.json → project_info.project_id
    projectId: 'YOUR_PROJECT_ID',
    // Format: YOUR_PROJECT_ID.firebasestorage.app
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
  );

  // ──────────────────────────────────────────────────────────
  // WEB — only needed if you use Firebase Hosting for dashboard
  // Fill from Firebase Console → Project Settings → Web app
  // ──────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.firebasestorage.app',
  );
}
