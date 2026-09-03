# SparkShow Admin Dashboard — Complete Setup Guide

This guide walks you through setting up Firebase and deploying the admin dashboard
so you can manage the product catalog and push OTA updates to all shop devices.

---

## 🔒 Security First — Credential Files Are Gitignored

The following files contain real API keys and are **excluded from git** (`.gitignore`).
They will **never** be pushed to GitHub:

| Gitignored (your real keys) | Template in repo (safe to commit) |
|---|---|
| `lib/firebase_options.dart` | `lib/firebase_options.dart.example` |
| `android/app/google-services.json` | `android/app/google-services.json.example` |
| `admin_dashboard/firebase-config.js` | `admin_dashboard/firebase-config.js.example` |

**Every time you clone the repo on a new machine**, copy the `.example` files and fill in your values:

```bash
# Flutter app credentials
cp lib/firebase_options.dart.example lib/firebase_options.dart
cp android/app/google-services.json.example android/app/google-services.json

# Admin dashboard credentials
cp admin_dashboard/firebase-config.js.example admin_dashboard/firebase-config.js
```

Then fill in the real values (from Firebase Console) in each copied file.

---

## Why Firebase?

Before Firebase, updating the app meant:
1. Editing `products.json` locally
2. Rebuilding the APK (`flutter build apk`)
3. Physically sending the new APK to every shop device via USB/WhatsApp/email
4. Manually installing it on each device

**With Firebase, the new flow is:**
1. Open the admin dashboard in your browser
2. Add/edit a product in 30 seconds — it's live instantly
3. Build and upload a new APK from the dashboard when you have code changes
4. Every device gets an update notification the next time the app is opened — no USB, no manual sending

### What Firebase provides that we can't do without it:

| Problem | Firebase Solution |
|---|---|
| Product catalog changes need an APK rebuild | **Firestore** stores the catalog remotely; app fetches it dynamically |
| APK must be physically distributed | **Firebase Storage** hosts new APKs; app downloads and installs automatically |
| No way to control what devices see | **Firestore `app_config`** documents let you push settings, maintenance messages, and force-update flags |
| Admin dashboard needs secure login | **Firebase Authentication** ensures only you can access the dashboard |
| Dashboard needs to be hosted somewhere | **Firebase Hosting** gives you a free HTTPS URL (e.g. `your-project.web.app`) |

---

## Step 1 — Create a Firebase Project

1. Go to **https://console.firebase.google.com**
2. Click **"Add project"**
3. Name it (e.g. `sparkshow-admin`) — this becomes your Project ID
4. Disable Google Analytics (not needed) → Click **"Create project"**
5. Wait for it to finish → Click **"Continue"**

---

## Step 2 — Enable Firestore Database

1. In the left sidebar, click **"Firestore Database"**
2. Click **"Create database"**
3. Choose **"Start in production mode"** (we'll set rules next)
4. Select a region close to you — **`asia-south1` (Mumbai)** is ideal for India
5. Click **"Enable"**

### Set Firestore Security Rules

In Firestore → **Rules** tab, replace the default rules with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Products — readable by all (the app reads this), writable only by admin
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    // App config — readable by all (the app polls this), writable only by admin
    match /app_config/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

Click **"Publish"**.

---

## Step 3 — Enable Firebase Storage

1. In the left sidebar, click **"Storage"**
2. Click **"Get started"**
3. Choose **"Start in production mode"** → Select the same region → **"Done"**

### Set Storage Security Rules

In Storage → **Rules** tab, replace with:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // APK releases — anyone can download (needed for OTA), only admin can upload
    match /releases/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

Click **"Publish"**.

---

## Step 4 — Enable Firebase Authentication

1. In the left sidebar, click **"Authentication"**
2. Click **"Get started"**
3. Under **"Sign-in method"**, click **"Email/Password"** → Enable → Save
4. Go to the **"Users"** tab → Click **"Add user"**
5. Enter your email and a strong password → Click **"Add user"**

> This creates your admin account. Only this account can log into the dashboard.

---

## Step 5 — Register the Android App

1. In Project Overview, click the **Android icon** (</>) to add a new app
2. **Android package name**: `com.fireworks.fireworks_showcase`
   (This must match exactly — found in `android/app/build.gradle.kts`)
3. App nickname: `SparkShow` (optional)
4. Click **"Register app"**
5. Click **"Download google-services.json"**
6. **Replace** the placeholder file at `android/app/google-services.json` with this downloaded file
7. Click "Next" through the remaining steps (the SDK is already added to the project)

---

## Step 6 — Register the Web App (for the Dashboard)

1. In Project Overview, click the **Web icon** (</>)  to add a new web app
2. App nickname: `SparkShow Dashboard`
3. ✅ **Check "Also set up Firebase Hosting"** if you want a public URL
4. Click **"Register app"**
5. You'll see the `firebaseConfig` object. Copy the values.

---

## Step 7 — Fill in Credentials

### In the Flutter app (`lib/firebase_options.dart`):

Replace all `YOUR_*` values using the values from `google-services.json`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey:            'your-android-api-key',        // google-services.json → client[0].api_key[0].current_key
  appId:             '1:xxxxxxxxx:android:xxxxxxx', // google-services.json → client[0].client_info.mobilesdk_app_id
  messagingSenderId: 'your-sender-id',              // google-services.json → project_info.project_number
  projectId:         'your-project-id',             // google-services.json → project_info.project_id
  storageBucket:     'your-project-id.firebasestorage.app',
);
```

### In the Admin Dashboard (`admin_dashboard/firebase-config.js`):

Replace all `YOUR_*` values using the web app config from Step 6:

```javascript
const firebaseConfig = {
  apiKey:            "your-web-api-key",
  authDomain:        "your-project-id.firebaseapp.com",
  projectId:         "your-project-id",
  storageBucket:     "your-project-id.firebasestorage.app",
  messagingSenderId: "your-sender-id",
  appId:             "your-web-app-id",
};
```

---

## Step 8 — Run the Admin Dashboard Locally

Just open the file in your browser:

```
admin_dashboard/index.html  →  double-click or drag into Chrome/Edge
```

> **Note**: Some browsers block Firebase when opening HTML files directly (`file://`).
> If you see CORS errors, use VS Code's **Live Server** extension, or deploy to Firebase Hosting (Step 9).

---

## Step 9 — Deploy Dashboard to Firebase Hosting (Recommended)

This gives you a permanent `https://your-project.web.app` URL.

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login:
   ```bash
   firebase login
   ```

3. In the `admin_dashboard/` folder, run:
   ```bash
   firebase init hosting
   ```
   - Select your SparkShow project
   - Public directory: `.` (current directory)
   - Single-page app: `No`
   - Overwrite `index.html`: `No`

4. Deploy:
   ```bash
   firebase deploy --only hosting
   ```

5. Your dashboard is now live at: `https://your-project-id.web.app`

---

## Step 10 — Test Flutter App with USB Debugging

After filling in credentials, test the app still works:

```bash
flutter pub get
flutter run
```

> The app will work exactly as before when offline.
> When online, it will fetch the product catalog from Firestore.

---

## Step 11 — First OTA Cycle (when you have a new APK)

1. Build the APK: `flutter build apk --release`
2. Open the admin dashboard
3. Go to **APK Releases** tab
4. Enter the new version number (must be higher than the current `pubspec.yaml` version)
5. Upload the APK file
6. Click **"Push Release to Devices"**
7. All shop devices will see an update dialog the next time the app is opened ✅

---

## Firestore Data Structure Reference

```
Firestore/
├── products/
│   ├── 001  → { id, title, category, keywords, video, thumbnail, description }
│   ├── 002  → { ... }
│   └── ...
│
└── app_config/
    ├── latest_version  → { version, download_url, release_notes, pushed_at, force_update }
    ├── settings        → { app_name, force_update, maintenance_msg, updated_at }
    └── releases/
        └── history/
            ├── <auto-id>  → { version, download_url, release_notes, pushed_at }
            └── ...
```

---

## Frequently Asked Questions

**Q: Will the app break if I haven't filled in Firebase credentials yet?**
A: No. The app detects placeholder credentials (`YOUR_*`) and skips Firebase entirely, running in full offline mode. `flutter run` always works.

**Q: What if a device is offline when I push an update?**
A: The update dialog only appears when the device is online. The next time the app opens with internet access, it will detect the new version.

**Q: Can my father's device install the APK by itself?**
A: No — Android requires user approval to install APKs. The app shows a dialog, user taps "Update Now," the APK downloads, and Android's standard install screen appears. One tap to confirm. No USB needed.

**Q: Is the dashboard safe from unauthorized access?**
A: Yes. Firebase Authentication ensures only your registered admin email can log in. Firestore rules prevent anyone without auth from writing data. The dashboard URL (if deployed) can be shared — it's protected by password.
