// ============================================================
// FIREBASE CONFIGURATION — FILL IN YOUR VALUES
// ============================================================
// Steps to get these values:
//   1. Go to https://console.firebase.google.com
//   2. Open your SparkShow project → ⚙️ Project Settings → General
//   3. Scroll to "Your apps" → click "Web" app (create one if needed)
//   4. Copy the firebaseConfig object values below
//
// See admin_dashboard/SETUP_GUIDE.md for the full step-by-step guide.
// ============================================================

const firebaseConfig = {
  apiKey:            "YOUR_WEB_API_KEY",
  authDomain:        "YOUR_PROJECT_ID.firebaseapp.com",
  projectId:         "YOUR_PROJECT_ID",
  storageBucket:     "YOUR_PROJECT_ID.firebasestorage.app",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId:             "YOUR_WEB_APP_ID",
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Expose services globally for use across other JS files
const db      = firebase.firestore();
const storage = firebase.storage();
const auth    = firebase.auth();
