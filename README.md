# Fireworks Showcase

A professional Android application for fireworks retail businesses. This app allows salespersons to quickly find and demonstrate firework products to customers by playing local demonstration videos.

## Purpose

When a customer asks to see a particular decorative or famous firework in action, the salesperson can open this app, quickly find the product, and play its demonstration video immediately. The app is designed for speed at the point of sale.

## Key Features

- **100% Offline**: Works without internet, Wi-Fi, or mobile data
- **Fast Search**: Instant search across product titles, categories, and keywords
- **Category Filtering**: Quick filtering by firework type
- **Product Cards**: Visual cards with thumbnails for easy identification
- **Local Video Playback**: All videos stored and played locally
- **Professional UI**: Clean, modern design optimized for phone use

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **Platform**: Android (Version 1)
- **Video**: Local MP4 files
- **Data**: Local JSON metadata
- **Architecture**: Clean separation (Models, Data, Screens, Widgets, Services)

## Project Structure

```
lib/
├── models/          # Product data models
├── data/            # Repository and data loading
├── screens/         # App screens (Home, Video)
├── widgets/         # Reusable UI components
├── services/        # Video playback service
└── utils/           # Utility functions

assets/
├── data/           # Product metadata (products.json)
├── videos/         # Demonstration videos (MP4)
└── thumbnails/     # Product thumbnails (JPG/PNG)
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x or later
- Android Studio or VS Code with Flutter extension
- Android device or emulator

### Installation

1. Clone or download this project
2. Open terminal in project directory
3. Run:
   ```bash
   flutter pub get
   flutter run
   ```

### Building APK

```bash
flutter build apk --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## Adding New Products

### Step-by-Step Process

1. **Add Video**: Place MP4 file in `assets/videos/`
   - Use snake_case naming: `peacock_fountain.mp4`
   - Recommended: 720p or 1080p, 30-40 seconds, under 15MB

2. **Add Thumbnail**: Place image in `assets/thumbnails/`
   - Name matches video: `peacock_fountain.jpg`
   - Recommended: 320x180 pixels, under 100KB

3. **Update Metadata**: Edit `assets/data/products.json`
   ```json
   {
     "id": "021",
     "title": "New Firework",
     "category": "Fountain",
     "keywords": ["keyword1", "keyword2"],
     "video": "assets/videos/new_firework.mp4",
     "thumbnail": "assets/thumbnails/new_firework.jpg",
     "description": "Product description"
   }
   ```

4. **Rebuild App**:
   ```bash
   flutter build apk --release
   ```

5. **Install on Devices**: Install the new APK on all sales devices

### JSON Product Format

```json
{
  "id": "string - unique identifier",
  "title": "string - product display name",
  "category": "string - product category",
  "keywords": ["array", "of", "search", "terms"],
  "video": "string - path to MP4 file",
  "thumbnail": "string - path to image file",
  "description": "string - optional description"
}
```

## Video Specifications

For optimal performance on Android phones:

- **Format**: MP4 (H.264 codec)
- **Resolution**: 720p (1280x720) or 1080p (1920x1080)
- **Frame Rate**: 30fps
- **Duration**: 30-40 seconds
- **File Size**: 5-15MB per video
- **Bitrate**: 2-4 Mbps

### FFmpeg Encoding Example

```bash
# 720p encoding
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -preset medium -vf scale=1280:720 -c:a aac -b:a 128k output.mp4

# 1080p encoding
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -preset medium -vf scale=1920:1080 -c:a aac -b:a 128k output.mp4
```

## Testing Offline

To verify the app works completely offline:

1. Enable Airplane mode on your Android device
2. Disable Wi-Fi and mobile data
3. Launch the app
4. Verify:
   - App starts normally
   - Products load and display
   - Search works
   - Category filtering works
   - Videos play without buffering
   - All navigation works

## Installation on Android Devices

### For Development/Testing

1. Enable Developer Options on Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run`

### For Production

1. Build APK: `flutter build apk --release`
2. Transfer APK to device (USB, email, cloud storage)
3. On device, open APK file
4. Allow installation from unknown sources if prompted
5. Install and launch app

### Distributing to Multiple Devices

- Share APK file via USB drive, email, or internal file sharing
- Each device needs manual installation
- Consider using MDM (Mobile Device Management) for fleet deployment

## Known Limitations - Version 1

- **Android Only**: iOS support not included in V1
- **No Backend**: All data is local, no cloud sync
- **Manual Updates**: Must reinstall APK to add/update products
- **No Analytics**: No usage tracking or statistics
- **No User Accounts**: Single-user application
- **Fixed Catalog**: Requires app rebuild to change product catalog

## Future Expansion Ideas

- Backend API for remote content management
- Cloud database for product metadata
- Automatic content updates over Wi-Fi
- iOS support
- User accounts and permissions
- Analytics and usage tracking
- Multi-shop synchronization
- Customer-facing version
- Inventory management integration
- Online ordering capabilities

## Architecture Notes

The application uses a clean architecture pattern:

- **Models**: Pure Dart data classes
- **Data Layer**: Repository pattern for data access
- **UI Layer**: Screens and reusable widgets
- **Services**: Business logic and external integrations

This architecture allows for future expansion:
- Replace JSON with SQLite/Isar database
- Add API integration for cloud data
- Implement caching strategies
- Add offline-first synchronization

## Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Clean Build

```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Support

This is an internal business tool. For issues or feature requests, contact the development team.

## Version History

- **Version 1.0.0**: Initial release with offline catalog and video playback
