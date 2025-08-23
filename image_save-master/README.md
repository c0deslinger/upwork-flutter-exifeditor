# image_save

[![version](https://img.shields.io/pub/v/image_save)](https://pub.dartlang.org/packages/image_save)
![platform](https://img.shields.io/badge/platform-Android%7CiOS-green)
[![starts](https://img.shields.io/github/stars/samoy/image_save?style=social)](https://github.com/Samoy/image_save)

Save image to album, support Android and iOS.

## Permission

* ### Android

Add the following statement in `AndroidManifest.xml`:
```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
* ### iOS

Add the following statement in `Info.plist`
```
<key>NSPhotoLibraryUsageDescription</key>
<string>Add the description of the permission you need here.</string>
```

## Usage
See [Example](https://github.com/Samoy/image_save/tree/master/example)

```
// Save to album.
bool success = await ImageSave.saveImage(data, "demo.gif", albumName: "demo");

// Save to sandbox.
// Notice: Image saved in this way will be deleted when the application is uninstalled.
bool success = await ImageSave.saveImageToSandbox(data, "demo.gif");

// Get images from Sandbox.
List<Uint8List> imageDatas = await ImageSave.getImagesFromSandbox();
```
