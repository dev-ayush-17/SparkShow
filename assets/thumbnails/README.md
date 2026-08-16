# Thumbnail Placeholders

This directory should contain thumbnail images for each product.

## File Naming Convention

Thumbnails should be named to match their corresponding video files:

```
peacock_fountain.jpg
golden_rain.jpg
dragon_rocket.jpg
...
```

## Recommended Specifications

- **Format**: JPG or PNG
- **Resolution**: 320x180 pixels (16:9 aspect ratio)
- **File Size**: Keep under 100KB per thumbnail
- **Quality**: Medium to high quality for clear product preview

## How to Add Thumbnails

1. Create or obtain thumbnail images for each product
2. Name them to match the video file names (without extension)
3. Place them in this directory
4. Ensure the filenames match the `thumbnail` field in `products.json`

## Placeholder Note

During development, you can use placeholder images. The app will handle missing thumbnails gracefully by showing a default placeholder icon.
