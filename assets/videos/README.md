# Video Files

This directory should contain demonstration videos for each product.

## File Naming Convention

Videos should be named using snake_case matching the product:

```
peacock_fountain.mp4
golden_rain.mp4
dragon_rocket.mp4
...
```

## Recommended Specifications

- **Format**: MP4 (H.264 codec)
- **Resolution**: 720p (1280x720) or 1080p (1920x1080)
- **Frame Rate**: 30fps
- **Duration**: 30-40 seconds per video
- **File Size**: Aim for 5-15MB per video
- **Bitrate**: 2-4 Mbps for good quality at reasonable size

## Video Encoding Settings (FFmpeg Example)

```bash
# For 720p encoding
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -preset medium -vf scale=1280:720 -c:a aac -b:a 128k output.mp4

# For 1080p encoding
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -preset medium -vf scale=1920:1080 -c:a aac -b:a 128k output.mp4
```

## How to Add New Products

1. Add MP4 video file to this directory
2. Add thumbnail image to `assets/thumbnails/`
3. Add product entry to `assets/data/products.json`
4. Run/build the application
5. Install updated APK on each device

## Important Notes

- Videos must be bundled with the app (not downloaded at runtime)
- The app works completely offline
- Keep file sizes reasonable for mobile devices
- Test playback on actual Android devices before finalizing
