# Koji EXIF Editor

A Flutter application for reading and editing EXIF metadata from images.

## Features

- **Multiple EXIF Libraries**: Supports various EXIF reading libraries for maximum compatibility
- **Orientation Detection**: Advanced orientation detection with support for all standard EXIF orientation values
- **Comprehensive EXIF Reading**: Reads all available EXIF tags from images
- **Cross-Platform**: Works on iOS, Android, and Web

## EXIF Libraries Supported

The app includes multiple EXIF reading libraries to ensure maximum compatibility:

1. **Native EXIF** (`native_exif: ^0.6.2`) - Fast native implementation
2. **EXIF Reader** (`exif_reader: ^3.16.1`) - Comprehensive EXIF reader
3. **EXIF Package** (`exif: ^3.3.0`) - Traditional EXIF package
4. **Metadata** (`metadata: ^2.0.0`) - Metadata EXIF reader
5. **Simple EXIF** (`simple_exif: ^0.0.2`) - Simple EXIF reader
6. **Image Library** (`image: ^4.1.7`) - Image library with EXIF support
7. **Combined Approach** - Uses all libraries for best results
8. **Native Platform** - Platform-specific EXIF reading using Android/iOS native APIs
9. **Native Platform Advanced** - Advanced Android ExifInterface features with comprehensive EXIF data including GPS, thumbnails, and file metadata
10. **Universal Approach** - Best method for current platform with automatic fallback

## Orientation Detection

The app can detect and display the following orientation values:

- **Normal** (1) - No rotation
- **Mirror Horizontal** (2) - Mirror horizontally
- **Rotate 180** (3) - Rotate 180 degrees
- **Mirror Vertical** (4) - Mirror vertically
- **Mirror Horizontal and Rotate 270 CW** (5) - Mirror horizontally and rotate 270° clockwise
- **Rotate 90 CW** (6) - Rotate 90° clockwise
- **Mirror Horizontal and Rotate 90 CW** (7) - Mirror horizontally and rotate 90° clockwise
- **Rotate 270 CW** (8) - Rotate 270° clockwise

## Usage

1. Select an image from your gallery
2. Choose an EXIF library to use for reading
3. View the detected EXIF data including orientation
4. The app will display all available EXIF tags and their values

## Troubleshooting

If you're having trouble reading EXIF data, especially orientation:

1. **Try the Combined Approach**: This uses all available libraries and should give the best results
2. **Check Debug Logs**: The app provides detailed debug information about what EXIF tags are found
3. **Different Libraries**: Different libraries may work better with different image formats or devices

## Technical Details

### EXIF Orientation Tag

The orientation information is stored in the EXIF tag with ID 274 (0x0112). The app looks for this tag using various key names:

- `Image Orientation`
- `Orientation`
- `EXIF Orientation`
- `IFD0 Orientation`

### Library Comparison

Each library has different strengths:

- **Native EXIF**: Fastest, good for basic EXIF data
- **EXIF Reader**: Most comprehensive, reads many EXIF tags
- **EXIF Package**: Traditional approach, reliable
- **Image Library**: Good for image processing with EXIF
- **Combined**: Uses all libraries for maximum coverage
- **Native Platform**: Platform-specific, optimized performance
- **Native Platform Advanced**: Most comprehensive native implementation with GPS, thumbnails, and advanced features
- **Universal**: Cross-platform with automatic platform detection

## Dependencies

```yaml
dependencies:
  native_exif: ^0.6.2
  exif_reader: ^3.16.1
  exif: ^3.3.0
  simple_exif: ^0.0.2
  image: ^4.1.7
  metadata: ^2.0.0
  flutter_exif_rotation: ^0.5.2
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app
4. Select an image and choose an EXIF library to test

## Contributing

Feel free to contribute by:
- Reporting bugs
- Suggesting new features
- Improving EXIF reading capabilities
- Adding support for more image formats
