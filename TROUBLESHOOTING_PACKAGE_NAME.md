# Troubleshooting Package Name Issues

## Problem: ClassNotFoundException for MainActivity

### Error Description
```
java.lang.ClassNotFoundException: Didn't find class "space.tombstone.imagerotator.MainActivity"
```

### Root Cause
Error ini terjadi karena ada ketidaksesuaian antara:
1. Package name di `build.gradle` (`applicationId`)
2. Package name di `MainActivity.kt`
3. Lokasi file `MainActivity.kt` di direktori

### Solution Steps

#### 1. Check Package Name in build.gradle
File: `android/app/build.gradle`
```gradle
android {
    namespace "space.tombstone.imagerotator"
    
    defaultConfig {
        applicationId "space.tombstone.imagerotator"
        // ...
    }
}
```

#### 2. Update MainActivity.kt Package Declaration
File: `android/app/src/main/kotlin/space/tombstone/exifeditor/MainActivity.kt`
```kotlin
package space.tombstone.imagerotator  // Must match applicationId
```

#### 3. Ensure Correct File Location
File structure harus sesuai dengan package name:
```
android/app/src/main/kotlin/
└── space/
    └── tombstone/
        └── exifeditor/
            └── MainActivity.kt
```

#### 4. Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Common Package Name Issues

#### Issue 1: Wrong Package Declaration
❌ **Wrong:**
```kotlin
package space.tombstone.imagerotator
```

✅ **Correct:**
```kotlin
package space.tombstone.imagerotator
```

#### Issue 2: Wrong File Location
❌ **Wrong:**
```
android/app/src/main/kotlin/space/tombstone/exifeditor/MainActivity.kt
```

✅ **Correct:**
```
android/app/src/main/kotlin/space/tombstone/exifeditor/MainActivity.kt
```

#### Issue 3: Mismatched Application ID
❌ **Wrong:**
```gradle
applicationId "space.tombstone.imagerotator"
```

✅ **Correct:**
```gradle
applicationId "space.tombstone.imagerotator"
```

### Verification Steps

1. **Check build.gradle:**
   ```bash
   grep -n "applicationId" android/app/build.gradle
   ```

2. **Check MainActivity.kt:**
   ```bash
   grep -n "package" android/app/src/main/kotlin/space/tombstone/exifeditor/MainActivity.kt
   ```

3. **Check file location:**
   ```bash
   find android/app/src/main/kotlin -name "MainActivity.kt"
   ```

### Complete Fix Example

#### Step 1: Update build.gradle
```gradle
android {
    namespace "space.tombstone.imagerotator"
    
    defaultConfig {
        applicationId "space.tombstone.imagerotator"
        minSdkVersion 22
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

#### Step 2: Update MainActivity.kt
```kotlin
package space.tombstone.imagerotator

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.ExifInterface
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "exif_reader_channel"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "readExifData" -> {
                    val imagePath = call.argument<String>("imagePath")
                    if (imagePath != null) {
                        val exifData = readExifData(imagePath)
                        result.success(exifData)
                    } else {
                        result.error("INVALID_ARGUMENT", "Image path is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun readExifData(imagePath: String): Map<String, Any> {
        // Implementation here...
    }
}
```

#### Step 3: Ensure Correct Directory Structure
```bash
mkdir -p android/app/src/main/kotlin/space/tombstone/exifeditor
mv android/app/src/main/kotlin/space/tombstone/exifeditor/MainActivity.kt android/app/src/main/kotlin/space/tombstone/exifeditor/
rmdir android/app/src/main/kotlin/space/tombstone/exifeditor
```

#### Step 4: Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Prevention Tips

1. **Always check package name consistency** when adding native code
2. **Use the same package name** across all Android files
3. **Follow the directory structure** that matches the package name
4. **Clean project** after making package name changes
5. **Test on a fresh device/emulator** to avoid cache issues

### Additional Debugging

If the issue persists:

1. **Check AndroidManifest.xml:**
   ```xml
   <activity android:name=".MainActivity" />
   ```

2. **Check for duplicate MainActivity files:**
   ```bash
   find android -name "MainActivity.kt"
   ```

3. **Check for cached builds:**
   ```bash
   rm -rf android/app/build
   flutter clean
   ```

4. **Check for conflicting plugins:**
   ```bash
   flutter doctor -v
   ```

### Related Files to Check

- `android/app/build.gradle` - Application ID
- `android/app/src/main/AndroidManifest.xml` - Activity declaration
- `android/app/src/main/kotlin/space/tombstone/exifeditor/MainActivity.kt` - Main activity
- `pubspec.yaml` - App name and version

### Summary

The key is ensuring consistency between:
1. `applicationId` in build.gradle
2. `package` declaration in MainActivity.kt
3. File location in the directory structure

Always clean and rebuild after making package name changes to avoid cache-related issues. 