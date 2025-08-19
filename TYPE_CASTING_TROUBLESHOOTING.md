# Type Casting Troubleshooting for Platform Channels

## Problem: Map Type Casting Errors

### Error Description
```
type '_Map<Object?, Object?>' is not a subtype of type 'Map<String, dynamic>'
```

### Root Cause
Platform channels di Flutter mengembalikan `Map<Object?, Object?>` dari native code (Kotlin/Java), tetapi Dart code mengharapkan `Map<String, dynamic>`. Ini menyebabkan type casting error.

### Solution: Safe Type Conversion

#### 1. Safe Map Conversion
```dart
static Future<Map<String, dynamic>> readExifData(String imagePath) async {
  try {
    final dynamic rawResult = await _channel.invokeMethod('readExifData', {
      'imagePath': imagePath,
    });

    // Convert the result to the correct type
    Map<String, dynamic> result;
    if (rawResult is Map) {
      result = Map<String, dynamic>.from(rawResult);
    } else {
      result = {
        'error': 'Invalid result type from native platform',
        'success': false,
      };
    }

    return result;
  } catch (e) {
    return {
      'error': e.toString(),
      'success': false,
    };
  }
}
```

#### 2. Safe Value Extraction
```dart
/// Get specific EXIF tag value
static String? getTagValue(Map<String, dynamic> exifData, String tagName) {
  if (exifData['success'] != true) {
    return null;
  }

  final value = exifData[tagName];
  if (value is String) {
    return value;
  } else if (value != null) {
    return value.toString();
  }
  return null;
}
```

#### 3. Safe Map Extraction
```dart
/// Get all EXIF tags as a formatted map
static Map<String, dynamic> getAllTags(Map<String, dynamic> exifData) {
  if (exifData['success'] != true) {
    return {};
  }

  final allTags = exifData['allTags'];
  if (allTags is Map) {
    return Map<String, dynamic>.from(allTags);
  }
  return {};
}
```

#### 4. Safe Number Conversion
```dart
/// Get total number of EXIF tags found
static int getTotalTags(Map<String, dynamic> exifData) {
  if (exifData['success'] != true) {
    return 0;
  }

  final totalTags = exifData['totalTags'];
  if (totalTags is int) {
    return totalTags;
  } else if (totalTags is String) {
    return int.tryParse(totalTags) ?? 0;
  }
  return 0;
}
```

### Best Practices

#### 1. Always Use Dynamic First
```dart
// ❌ Wrong - Direct casting
final Map<String, dynamic> result = await _channel.invokeMethod('method');

// ✅ Correct - Safe conversion
final dynamic rawResult = await _channel.invokeMethod('method');
Map<String, dynamic> result;
if (rawResult is Map) {
  result = Map<String, dynamic>.from(rawResult);
}
```

#### 2. Check Types Before Casting
```dart
// ❌ Wrong - Direct casting
final value = exifData[tagName] as String?;

// ✅ Correct - Type checking
final value = exifData[tagName];
if (value is String) {
  return value;
} else if (value != null) {
  return value.toString();
}
```

#### 3. Handle Null Values
```dart
// ❌ Wrong - No null check
return exifData['totalTags'] as int;

// ✅ Correct - Null safe
final totalTags = exifData['totalTags'];
if (totalTags is int) {
  return totalTags;
} else if (totalTags is String) {
  return int.tryParse(totalTags) ?? 0;
}
return 0;
```

#### 4. Provide Default Values
```dart
// Always provide fallback values
Map<String, dynamic> result;
if (rawResult is Map) {
  result = Map<String, dynamic>.from(rawResult);
} else {
  result = {
    'error': 'Invalid result type',
    'success': false,
  };
}
```

### Common Type Conversion Patterns

#### 1. String Conversion
```dart
static String safeString(dynamic value) {
  if (value is String) {
    return value;
  } else if (value != null) {
    return value.toString();
  }
  return '';
}
```

#### 2. Integer Conversion
```dart
static int safeInt(dynamic value) {
  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? 0;
  } else if (value is double) {
    return value.toInt();
  }
  return 0;
}
```

#### 3. Boolean Conversion
```dart
static bool safeBool(dynamic value) {
  if (value is bool) {
    return value;
  } else if (value is String) {
    return value.toLowerCase() == 'true';
  } else if (value is int) {
    return value != 0;
  }
  return false;
}
```

#### 4. Map Conversion
```dart
static Map<String, dynamic> safeMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return {};
}
```

### Error Handling Patterns

#### 1. Try-Catch with Type Checking
```dart
static Future<Map<String, dynamic>> safeMethodCall() async {
  try {
    final dynamic rawResult = await _channel.invokeMethod('method');
    
    if (rawResult is Map) {
      return Map<String, dynamic>.from(rawResult);
    } else {
      return {
        'error': 'Invalid result type',
        'success': false,
      };
    }
  } catch (e) {
    return {
      'error': e.toString(),
      'success': false,
    };
  }
}
```

#### 2. Null-Safe Access
```dart
static String? getValue(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value == null) return null;
  
  if (value is String) {
    return value;
  }
  return value.toString();
}
```

#### 3. Default Value Pattern
```dart
static T getValueOrDefault<T>(Map<String, dynamic> data, String key, T defaultValue) {
  final value = data[key];
  if (value is T) {
    return value;
  }
  return defaultValue;
}
```

### Testing Type Conversions

#### 1. Unit Tests
```dart
void testTypeConversions() {
  // Test string conversion
  expect(safeString('test'), 'test');
  expect(safeString(123), '123');
  expect(safeString(null), '');
  
  // Test int conversion
  expect(safeInt(123), 123);
  expect(safeInt('123'), 123);
  expect(safeInt('abc'), 0);
  
  // Test map conversion
  final testMap = {'key': 'value'};
  expect(safeMap(testMap), {'key': 'value'});
}
```

#### 2. Integration Tests
```dart
void testPlatformChannel() async {
  final result = await NativeExifController.readExifData('test.jpg');
  
  expect(result, isA<Map<String, dynamic>>());
  expect(result['success'], isA<bool>());
  
  if (result['success'] == true) {
    expect(result['Orientation'], isA<String>());
  }
}
```

### Debugging Tips

#### 1. Print Raw Results
```dart
final dynamic rawResult = await _channel.invokeMethod('method');
print('Raw result type: ${rawResult.runtimeType}');
print('Raw result: $rawResult');
```

#### 2. Check Individual Values
```dart
final orientation = exifData['Orientation'];
print('Orientation type: ${orientation.runtimeType}');
print('Orientation value: $orientation');
```

#### 3. Use Type Checking
```dart
if (value is String) {
  print('Value is String: $value');
} else if (value is int) {
  print('Value is int: $value');
} else {
  print('Value is other type: ${value.runtimeType}');
}
```

### Summary

1. **Never cast directly** from platform channel results
2. **Always check types** before conversion
3. **Provide fallback values** for all conversions
4. **Handle null values** safely
5. **Use type-safe conversion methods**
6. **Test thoroughly** with different data types
7. **Debug with print statements** to understand data types

### Example Implementation

```dart
class SafeTypeConverter {
  static Map<String, dynamic> convertMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }
  
  static String convertString(dynamic value) {
    if (value is String) {
      return value;
    } else if (value != null) {
      return value.toString();
    }
    return '';
  }
  
  static int convertInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
  
  static bool convertBool(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }
}
``` 