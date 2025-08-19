# Platform-Specific Imports Troubleshooting

## Problem: dart:html and dart:js Not Available on Mobile Platforms

### Error Description
```
Error: Dart library 'dart:html' is not available on this platform.
Error: Dart library 'dart:js' is not available on this platform.
```

### Root Cause
Library `dart:html` dan `dart:js` hanya tersedia di platform web, tidak di Android atau iOS. Ketika aplikasi mobile mencoba mengimport library ini, akan terjadi error.

### Solution: Conditional Imports

#### 1. Create Platform-Specific Files

**For Web Platform:**
File: `lib/controllers/web_exif_controller_web.dart`
```dart
import 'dart:html' as html;
import 'dart:js' as js;

class WebExifController {
  static Future<Map<String, dynamic>> readExifData(html.File imageFile) async {
    // Web-specific implementation
  }
}
```

**For Mobile Platforms:**
File: `lib/controllers/web_exif_controller_stub.dart`
```dart
class WebExifController {
  static Future<Map<String, dynamic>> readExifData(dynamic imageFile) async {
    return {
      'error': 'Web EXIF reading not available on mobile platform',
      'success': false,
    };
  }
}
```

#### 2. Use Conditional Imports

File: `lib/controllers/universal_exif_controller.dart`
```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'native_exif_controller.dart';

// Conditional imports
import 'web_exif_controller_web.dart' if (dart.library.io) 'web_exif_controller_stub.dart';

class UniversalExifController {
  static Future<Map<String, dynamic>> readExifData(dynamic imageFile) async {
    if (kIsWeb) {
      // Web platform
      return await WebExifController.readExifData(imageFile);
    } else {
      // Mobile platforms
      if (imageFile is File) {
        return await NativeExifController.readExifData(imageFile.path);
      }
    }
  }
}
```

### Alternative Solution: Platform Detection

#### 1. Simple Platform Detection
```dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class UniversalExifController {
  static Future<Map<String, dynamic>> readExifData(dynamic imageFile) async {
    if (kIsWeb) {
      // Web platform - return error for mobile
      return {
        'error': 'Web EXIF reading not available on mobile platform',
        'success': false,
      };
    } else {
      // Mobile platforms (Android/iOS)
      if (imageFile is File) {
        return await NativeExifController.readExifData(imageFile.path);
      } else if (imageFile is String) {
        return await NativeExifController.readExifData(imageFile);
      }
    }
  }
}
```

#### 2. Platform-Specific Methods
```dart
class UniversalExifController {
  static Future<Map<String, dynamic>> readExifData(dynamic imageFile) async {
    if (kIsWeb) {
      return _readExifDataWeb(imageFile);
    } else {
      return _readExifDataMobile(imageFile);
    }
  }

  static Future<Map<String, dynamic>> _readExifDataWeb(dynamic imageFile) async {
    // Web implementation (stub for mobile)
    return {
      'error': 'Web EXIF reading not available on mobile platform',
      'success': false,
    };
  }

  static Future<Map<String, dynamic>> _readExifDataMobile(dynamic imageFile) async {
    // Mobile implementation
    if (imageFile is File) {
      return await NativeExifController.readExifData(imageFile.path);
    } else if (imageFile is String) {
      return await NativeExifController.readExifData(imageFile);
    }
    return {
      'error': 'Invalid file type for mobile platform',
      'success': false,
    };
  }
}
```

### Best Practices

#### 1. Always Check Platform
```dart
if (kIsWeb) {
  // Web-specific code
} else {
  // Mobile-specific code
}
```

#### 2. Use Stub Implementations
```dart
// For web features on mobile, always provide stub implementations
static String getOrientationText(Map<String, dynamic> exifData) {
  if (kIsWeb) {
    return "Web EXIF not implemented";
  } else {
    return NativeExifController.getOrientationText(exifData);
  }
}
```

#### 3. Handle Errors Gracefully
```dart
static Future<Map<String, dynamic>> readExifData(dynamic imageFile) async {
  try {
    if (kIsWeb) {
      return {'error': 'Web not supported', 'success': false};
    } else {
      return await NativeExifController.readExifData(imageFile.path);
    }
  } catch (e) {
    return {'error': e.toString(), 'success': false};
  }
}
```

### File Structure

```
lib/controllers/
├── native_exif_controller.dart      # Android/iOS implementation
├── web_exif_controller_web.dart     # Web implementation (dart:html, dart:js)
├── web_exif_controller_stub.dart    # Mobile stub (no web imports)
└── universal_exif_controller.dart   # Platform detection and routing
```

### Testing

#### 1. Test on Mobile
```bash
flutter run -d android
flutter run -d ios
```

#### 2. Test on Web
```bash
flutter run -d chrome
```

#### 3. Check Platform Info
```dart
print('Platform: ${UniversalExifController.getPlatformInfo()}');
```

### Common Issues and Solutions

#### Issue 1: Import Error on Mobile
**Problem:**
```
Error: Dart library 'dart:html' is not available on this platform.
```

**Solution:**
- Remove direct imports of `dart:html` and `dart:js`
- Use conditional imports or platform detection
- Provide stub implementations for mobile

#### Issue 2: Missing Web Implementation
**Problem:**
```
Web EXIF reading not available on mobile platform
```

**Solution:**
- This is expected behavior on mobile
- Web implementation is only available when running on web
- Use native implementation for mobile platforms

#### Issue 3: Type Errors
**Problem:**
```
Type 'html.File' not found
```

**Solution:**
- Use `dynamic` type for cross-platform compatibility
- Check platform before using platform-specific types
- Use stub implementations for unsupported platforms

### Summary

1. **Never import `dart:html` or `dart:js` directly** in files used by mobile platforms
2. **Use platform detection** (`kIsWeb`) to route to appropriate implementations
3. **Provide stub implementations** for web features on mobile
4. **Use conditional imports** when possible for better code organization
5. **Test on all platforms** to ensure compatibility

### Example Implementation

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'native_exif_controller.dart';

class UniversalExifController {
  static Future<Map<String, dynamic>> readExifData(dynamic imageFile) async {
    if (kIsWeb) {
      return {
        'error': 'Web EXIF reading not available on mobile platform',
        'success': false,
      };
    } else {
      if (imageFile is File) {
        return await NativeExifController.readExifData(imageFile.path);
      } else if (imageFile is String) {
        return await NativeExifController.readExifData(imageFile);
      } else {
        return {
          'error': 'Invalid file type for mobile platform',
          'success': false,
        };
      }
    }
  }

  static String getPlatformInfo() {
    if (kIsWeb) {
      return 'Web Platform (EXIF not implemented)';
    } else if (Platform.isAndroid) {
      return 'Android Platform';
    } else if (Platform.isIOS) {
      return 'iOS Platform';
    } else {
      return 'Unknown Platform';
    }
  }
}
``` 