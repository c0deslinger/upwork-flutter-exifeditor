import UIKit
import Flutter
import ImageIO
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let exifChannel = FlutterMethodChannel(name: "exif_reader_channel",
                                              binaryMessenger: controller.binaryMessenger)
        exifChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "readExifData" {
                if let args = call.arguments as? [String: Any],
                   let imagePath = args["imagePath"] as? String {
                    self.readExifData(imagePath: imagePath, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT",
                                       message: "Image path is required",
                                       details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func readExifData(imagePath: String, result: @escaping FlutterResult) {
        guard let url = URL(string: imagePath) else {
            result(FlutterError(code: "INVALID_PATH",
                               message: "Invalid image path",
                               details: nil))
            return
        }
        
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            result(FlutterError(code: "IMAGE_LOAD_ERROR",
                               message: "Could not load image",
                               details: nil))
            return
        }
        
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] else {
            result(FlutterError(code: "NO_PROPERTIES",
                               message: "No properties found",
                               details: nil))
            return
        }
        
        var resultDict: [String: Any] = [:]
        var allTags: [String: String] = [:]
        
        // Get EXIF data
        if let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            // Orientation
            if let orientation = exif[kCGImagePropertyOrientation as String] as? Int {
                allTags["Orientation"] = String(orientation)
                resultDict["Orientation"] = String(orientation)
            }
            
            // Date and time
            if let dateTimeOriginal = exif[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                allTags["DateTimeOriginal"] = dateTimeOriginal
                resultDict["DateTimeOriginal"] = dateTimeOriginal
            }
            
            if let dateTimeDigitized = exif[kCGImagePropertyExifDateTimeDigitized as String] as? String {
                allTags["DateTimeDigitized"] = dateTimeDigitized
                resultDict["DateTimeDigitized"] = dateTimeDigitized
            }
            
            // Exposure settings
            if let exposureTime = exif[kCGImagePropertyExifExposureTime as String] as? Double {
                allTags["ExposureTime"] = String(exposureTime)
                resultDict["ExposureTime"] = String(exposureTime)
            }
            
            if let fNumber = exif[kCGImagePropertyExifFNumber as String] as? Double {
                allTags["FNumber"] = String(fNumber)
                resultDict["FNumber"] = String(fNumber)
            }
            
            if let iso = exif[kCGImagePropertyExifISOSpeedRatings as String] as? [Int] {
                if let firstIso = iso.first {
                    allTags["ISO"] = String(firstIso)
                    resultDict["ISO"] = String(firstIso)
                }
            }
            
            // Focal length
            if let focalLength = exif[kCGImagePropertyExifFocalLength as String] as? Double {
                allTags["FocalLength"] = String(focalLength)
                resultDict["FocalLength"] = String(focalLength)
            }
            
            // Flash
            if let flash = exif[kCGImagePropertyExifFlash as String] as? Int {
                allTags["Flash"] = String(flash)
                resultDict["Flash"] = String(flash)
            }
            
            // Metering mode
            if let meteringMode = exif[kCGImagePropertyExifMeteringMode as String] as? Int {
                allTags["MeteringMode"] = String(meteringMode)
                resultDict["MeteringMode"] = String(meteringMode)
            }
            
            // Light source
            if let lightSource = exif[kCGImagePropertyExifLightSource as String] as? Int {
                allTags["LightSource"] = String(lightSource)
                resultDict["LightSource"] = String(lightSource)
            }
        }
        
        // Get TIFF data (camera make and model)
        if let tiff = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            if let make = tiff[kCGImagePropertyTIFFMake as String] as? String {
                allTags["Make"] = make
                resultDict["Make"] = make
            }
            
            if let model = tiff[kCGImagePropertyTIFFModel as String] as? String {
                allTags["Model"] = model
                resultDict["Model"] = model
            }
            
            if let software = tiff[kCGImagePropertyTIFFSoftware as String] as? String {
                allTags["Software"] = software
                resultDict["Software"] = software
            }
            
            if let artist = tiff[kCGImagePropertyTIFFArtist as String] as? String {
                allTags["Artist"] = artist
                resultDict["Artist"] = artist
            }
            
            if let copyright = tiff[kCGImagePropertyTIFFCopyright as String] as? String {
                allTags["Copyright"] = copyright
                resultDict["Copyright"] = copyright
            }
        }
        
        // Get GPS data
        if let gps = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            if let latitude = gps[kCGImagePropertyGPSLatitude as String] as? Double {
                allTags["GPSLatitude"] = String(latitude)
                resultDict["GPSLatitude"] = String(latitude)
            }
            
            if let longitude = gps[kCGImagePropertyGPSLongitude as String] as? Double {
                allTags["GPSLongitude"] = String(longitude)
                resultDict["GPSLongitude"] = String(longitude)
            }
            
            if let altitude = gps[kCGImagePropertyGPSAltitude as String] as? Double {
                allTags["GPSAltitude"] = String(altitude)
                resultDict["GPSAltitude"] = String(altitude)
            }
        }
        
        // Get image dimensions
        if let width = properties[kCGImagePropertyPixelWidth as String] as? Int {
            allTags["ImageWidth"] = String(width)
            resultDict["ImageWidth"] = String(width)
        }
        
        if let height = properties[kCGImagePropertyPixelHeight as String] as? Int {
            allTags["ImageHeight"] = String(height)
            resultDict["ImageHeight"] = String(height)
        }
        
        // Add all tags and success indicator
        resultDict["allTags"] = allTags
        resultDict["totalTags"] = allTags.count
        resultDict["success"] = true
        
        result(resultDict)
    }
}
