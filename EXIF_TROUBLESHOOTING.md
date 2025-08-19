# EXIF Orientation Troubleshooting Guide

## Problem: Cannot Read Orientation Tag

If you're having trouble reading the orientation tag from EXIF data, here are several solutions:

### 1. Use the Combined Approach

The **Combined Approach** library option tries all available EXIF libraries and combines their results. This is the most reliable method:

1. Select an image
2. Choose "Combined Approach" from the library selector
3. Check the debug logs to see which library found the orientation

### 2. Check Debug Logs

The app provides detailed debug information. Look for these log messages:

```
*** ORIENTATION TAG FOUND: [tag_name] = [value] ***
Found orientation tag with key: [key] = [value]
Native EXIF Orientation: [value]
```

### 3. Try Different Libraries

Different libraries work better with different image formats:

- **EXIF Reader**: Best for comprehensive EXIF reading
- **Native EXIF**: Fastest, good for basic data
- **EXIF Package**: Traditional approach, reliable
- **Image Library**: Good for image processing
- **Simple EXIF**: Lightweight option

### 4. Common Orientation Values

The orientation tag should contain one of these values:

| Value | Description |
|-------|-------------|
| 1 | Normal (no rotation) |
| 2 | Mirror Horizontal |
| 3 | Rotate 180° |
| 4 | Mirror Vertical |
| 5 | Mirror Horizontal + Rotate 270° CW |
| 6 | Rotate 90° CW |
| 7 | Mirror Horizontal + Rotate 90° CW |
| 8 | Rotate 270° CW |

### 5. EXIF Tag Names

The orientation information can be stored under different tag names:

- `Image Orientation`
- `Orientation`
- `EXIF Orientation`
- `IFD0 Orientation`
- `Image:Orientation`
- `IFD0:Orientation`

### 6. Technical Details

The orientation tag has:
- **Tag ID**: 274 (0x0112 in hexadecimal)
- **Location**: Usually in the IFD0 (Image File Directory 0)
- **Type**: SHORT (16-bit integer)

### 7. Testing with Sample Images

To test if the app is working correctly:

1. Use an image taken with an iPhone (they often have orientation tags)
2. Try images from different cameras/devices
3. Test with both JPEG and HEIC formats

### 8. Debug Information

The app logs detailed information about:

- Total EXIF tags found
- All available tag names
- Orientation tag detection attempts
- Parsing results
- Library-specific errors

### 9. Common Issues and Solutions

#### Issue: No orientation tag found
**Solution**: Try the Combined Approach or check if the image actually has EXIF data

#### Issue: Orientation value is a string instead of number
**Solution**: The app now handles string parsing and text matching

#### Issue: Different libraries show different results
**Solution**: This is normal - use the Combined Approach for best results

#### Issue: Orientation shows as "Normal" when it should be rotated
**Solution**: Check if the image was processed by another app that stripped EXIF data

### 10. Advanced Debugging

To get more detailed information:

1. Run the app in debug mode
2. Check the console output
3. Look for messages starting with `===` (library results)
4. Search for `*** ORIENTATION TAG FOUND ***` messages

### 11. Library-Specific Notes

#### Native EXIF
- Fastest library
- May not read all EXIF tags
- Good for basic orientation detection

#### EXIF Reader
- Most comprehensive
- Reads many EXIF tags
- Best for detailed EXIF analysis

#### EXIF Package
- Traditional approach
- Reliable but slower
- Good compatibility

#### Image Library
- Good for image processing
- May have limited EXIF support
- Useful for combined approach

### 12. Future Improvements

The app is designed to be extensible. Future versions may include:

- Support for more EXIF libraries
- Better error handling
- More detailed EXIF analysis
- Support for editing EXIF data
- Batch processing capabilities

## Getting Help

If you're still having issues:

1. Check the debug logs for specific error messages
2. Try different images to isolate the problem
3. Test with the Combined Approach first
4. Report specific issues with debug information 