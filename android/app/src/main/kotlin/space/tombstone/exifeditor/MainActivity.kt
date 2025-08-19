package space.tombstone.exifeditor

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.ExifInterface
import java.io.File
import org.json.JSONObject
import org.json.JSONArray

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
                "readExifDataAdvanced" -> {
                    val imagePath = call.argument<String>("imagePath")
                    if (imagePath != null) {
                        val exifData = readExifDataAdvanced(imagePath)
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
        val result = mutableMapOf<String, Any>()
        
        try {
            val file = File(imagePath)
            if (!file.exists()) {
                result["error"] = "File does not exist"
                return result
            }

            val exifInterface = ExifInterface(imagePath)
            
            // Read all available EXIF tags
            val allTags = mutableMapOf<String, String>()
            
            // Orientation tag
            val orientation = exifInterface.getAttribute(ExifInterface.TAG_ORIENTATION)
            if (orientation != null) {
                allTags["Orientation"] = orientation
                result["Orientation"] = orientation
            }
            
            // Camera make and model
            val make = exifInterface.getAttribute(ExifInterface.TAG_MAKE)
            if (make != null) {
                allTags["Make"] = make
                result["Make"] = make
            }
            
            val model = exifInterface.getAttribute(ExifInterface.TAG_MODEL)
            if (model != null) {
                allTags["Model"] = model
                result["Model"] = model
            }
            
            // Date and time
            val dateTime = exifInterface.getAttribute(ExifInterface.TAG_DATETIME)
            if (dateTime != null) {
                allTags["DateTime"] = dateTime
                result["DateTime"] = dateTime
            }
            
            val dateTimeOriginal = exifInterface.getAttribute(ExifInterface.TAG_DATETIME_ORIGINAL)
            if (dateTimeOriginal != null) {
                allTags["DateTimeOriginal"] = dateTimeOriginal
                result["DateTimeOriginal"] = dateTimeOriginal
            }
            
            // GPS data
            val gpsLatitude = exifInterface.getAttribute(ExifInterface.TAG_GPS_LATITUDE)
            if (gpsLatitude != null) {
                allTags["GPSLatitude"] = gpsLatitude
                result["GPSLatitude"] = gpsLatitude
            }
            
            val gpsLongitude = exifInterface.getAttribute(ExifInterface.TAG_GPS_LONGITUDE)
            if (gpsLongitude != null) {
                allTags["GPSLongitude"] = gpsLongitude
                result["GPSLongitude"] = gpsLongitude
            }
            
            // Image dimensions
            val imageWidth = exifInterface.getAttribute(ExifInterface.TAG_IMAGE_WIDTH)
            if (imageWidth != null) {
                allTags["ImageWidth"] = imageWidth
                result["ImageWidth"] = imageWidth
            }
            
            val imageLength = exifInterface.getAttribute(ExifInterface.TAG_IMAGE_LENGTH)
            if (imageLength != null) {
                allTags["ImageLength"] = imageLength
                result["ImageLength"] = imageLength
            }
            
            // Exposure settings
            val exposureTime = exifInterface.getAttribute(ExifInterface.TAG_EXPOSURE_TIME)
            if (exposureTime != null) {
                allTags["ExposureTime"] = exposureTime
                result["ExposureTime"] = exposureTime
            }
            
            val fNumber = exifInterface.getAttribute(ExifInterface.TAG_F_NUMBER)
            if (fNumber != null) {
                allTags["FNumber"] = fNumber
                result["FNumber"] = fNumber
            }
            
            val iso = exifInterface.getAttribute(ExifInterface.TAG_ISO_SPEED_RATINGS)
            if (iso != null) {
                allTags["ISO"] = iso
                result["ISO"] = iso
            }
            
            // Focal length
            val focalLength = exifInterface.getAttribute(ExifInterface.TAG_FOCAL_LENGTH)
            if (focalLength != null) {
                allTags["FocalLength"] = focalLength
                result["FocalLength"] = focalLength
            }
            
            // Software
            val software = exifInterface.getAttribute(ExifInterface.TAG_SOFTWARE)
            if (software != null) {
                allTags["Software"] = software
                result["Software"] = software
            }
            
            // Artist
            val artist = exifInterface.getAttribute(ExifInterface.TAG_ARTIST)
            if (artist != null) {
                allTags["Artist"] = artist
                result["Artist"] = artist
            }
            
            // Copyright
            val copyright = exifInterface.getAttribute(ExifInterface.TAG_COPYRIGHT)
            if (copyright != null) {
                allTags["Copyright"] = copyright
                result["Copyright"] = copyright
            }
            
            // Add all tags to result
            result["allTags"] = allTags
            result["totalTags"] = allTags.size
            
            // Success indicator
            result["success"] = true
            
        } catch (e: Exception) {
            result["error"] = e.message ?: "Unknown error"
            result["success"] = false
        }
        
        return result
    }

    private fun readExifDataAdvanced(imagePath: String): Map<String, Any> {
        val result = mutableMapOf<String, Any>()
        
        try {
            val file = File(imagePath)
            if (!file.exists()) {
                result["error"] = "File does not exist"
                result["success"] = false
                return result
            }

            val exifInterface = ExifInterface(imagePath)
            val allTags = mutableMapOf<String, Any>()
            
            // Check if file has EXIF data
            if (!exifInterface.hasAttribute(ExifInterface.TAG_ORIENTATION) && 
                !exifInterface.hasAttribute(ExifInterface.TAG_MAKE) &&
                !exifInterface.hasAttribute(ExifInterface.TAG_MODEL)) {
                result["warning"] = "No EXIF data found in image"
            }
            
            // ===== ORIENTATION & IMAGE INFO =====
            val orientation = exifInterface.getAttribute(ExifInterface.TAG_ORIENTATION)
            if (orientation != null) {
                allTags["Orientation"] = orientation
                result["Orientation"] = orientation
                result["OrientationValue"] = orientation.toIntOrNull() ?: 0
            }
            
            // ===== CAMERA INFO =====
            val make = exifInterface.getAttribute(ExifInterface.TAG_MAKE)
            if (make != null) {
                allTags["Make"] = make
                result["Make"] = make
            }
            
            val model = exifInterface.getAttribute(ExifInterface.TAG_MODEL)
            if (model != null) {
                allTags["Model"] = model
                result["Model"] = model
            }
            
            val deviceSettingDescription = exifInterface.getAttribute(ExifInterface.TAG_DEVICE_SETTING_DESCRIPTION)
            if (deviceSettingDescription != null) {
                allTags["DeviceSettingDescription"] = deviceSettingDescription
                result["DeviceSettingDescription"] = deviceSettingDescription
            }
            
            // ===== DATE & TIME INFO =====
            val dateTime = exifInterface.getAttribute(ExifInterface.TAG_DATETIME)
            if (dateTime != null) {
                allTags["DateTime"] = dateTime
                result["DateTime"] = dateTime
            }
            
            val dateTimeOriginal = exifInterface.getAttribute(ExifInterface.TAG_DATETIME_ORIGINAL)
            if (dateTimeOriginal != null) {
                allTags["DateTimeOriginal"] = dateTimeOriginal
                result["DateTimeOriginal"] = dateTimeOriginal
            }
            
            val dateTimeDigitized = exifInterface.getAttribute(ExifInterface.TAG_DATETIME_DIGITIZED)
            if (dateTimeDigitized != null) {
                allTags["DateTimeDigitized"] = dateTimeDigitized
                result["DateTimeDigitized"] = dateTimeDigitized
            }
            
            // ===== GPS DATA =====
            val gpsLatitude = exifInterface.getAttribute(ExifInterface.TAG_GPS_LATITUDE)
            val gpsLatitudeRef = exifInterface.getAttribute(ExifInterface.TAG_GPS_LATITUDE_REF)
            if (gpsLatitude != null) {
                allTags["GPSLatitude"] = gpsLatitude
                allTags["GPSLatitudeRef"] = gpsLatitudeRef ?: "N"
                result["GPSLatitude"] = gpsLatitude
                result["GPSLatitudeRef"] = gpsLatitudeRef ?: "N"
            }
            
            val gpsLongitude = exifInterface.getAttribute(ExifInterface.TAG_GPS_LONGITUDE)
            val gpsLongitudeRef = exifInterface.getAttribute(ExifInterface.TAG_GPS_LONGITUDE_REF)
            if (gpsLongitude != null) {
                allTags["GPSLongitude"] = gpsLongitude
                allTags["GPSLongitudeRef"] = gpsLongitudeRef ?: "E"
                result["GPSLongitude"] = gpsLongitude
                result["GPSLongitudeRef"] = gpsLongitudeRef ?: "E"
            }
            
            val gpsAltitude = exifInterface.getAttribute(ExifInterface.TAG_GPS_ALTITUDE)
            val gpsAltitudeRef = exifInterface.getAttribute(ExifInterface.TAG_GPS_ALTITUDE_REF)
            if (gpsAltitude != null) {
                allTags["GPSAltitude"] = gpsAltitude
                allTags["GPSAltitudeRef"] = gpsAltitudeRef ?: "0"
                result["GPSAltitude"] = gpsAltitude
                result["GPSAltitudeRef"] = gpsAltitudeRef ?: "0"
            }
            
            val gpsTimestamp = exifInterface.getAttribute(ExifInterface.TAG_GPS_TIMESTAMP)
            if (gpsTimestamp != null) {
                allTags["GPSTimestamp"] = gpsTimestamp
                result["GPSTimestamp"] = gpsTimestamp
            }
            
            val gpsProcessingMethod = exifInterface.getAttribute(ExifInterface.TAG_GPS_PROCESSING_METHOD)
            if (gpsProcessingMethod != null) {
                allTags["GPSProcessingMethod"] = gpsProcessingMethod
                result["GPSProcessingMethod"] = gpsProcessingMethod
            }
            
            // ===== IMAGE DIMENSIONS =====
            val imageWidth = exifInterface.getAttribute(ExifInterface.TAG_IMAGE_WIDTH)
            if (imageWidth != null) {
                allTags["ImageWidth"] = imageWidth
                result["ImageWidth"] = imageWidth
            }
            
            val imageLength = exifInterface.getAttribute(ExifInterface.TAG_IMAGE_LENGTH)
            if (imageLength != null) {
                allTags["ImageLength"] = imageLength
                result["ImageLength"] = imageLength
            }
            
            // ===== EXPOSURE SETTINGS =====
            val exposureTime = exifInterface.getAttribute(ExifInterface.TAG_EXPOSURE_TIME)
            if (exposureTime != null) {
                allTags["ExposureTime"] = exposureTime
                result["ExposureTime"] = exposureTime
            }
            
            val fNumber = exifInterface.getAttribute(ExifInterface.TAG_F_NUMBER)
            if (fNumber != null) {
                allTags["FNumber"] = fNumber
                result["FNumber"] = fNumber
            }
            
            val exposureProgram = exifInterface.getAttribute(ExifInterface.TAG_EXPOSURE_PROGRAM)
            if (exposureProgram != null) {
                allTags["ExposureProgram"] = exposureProgram
                result["ExposureProgram"] = exposureProgram
            }
            
            val spectralSensitivity = exifInterface.getAttribute(ExifInterface.TAG_SPECTRAL_SENSITIVITY)
            if (spectralSensitivity != null) {
                allTags["SpectralSensitivity"] = spectralSensitivity
                result["SpectralSensitivity"] = spectralSensitivity
            }
            
            val iso = exifInterface.getAttribute(ExifInterface.TAG_ISO_SPEED_RATINGS)
            if (iso != null) {
                allTags["ISO"] = iso
                result["ISO"] = iso
            }
            
            val oecf = exifInterface.getAttribute(ExifInterface.TAG_OECF)
            if (oecf != null) {
                allTags["OECF"] = oecf
                result["OECF"] = oecf
            }
            
            // ===== FLASH INFO =====
            val flash = exifInterface.getAttribute(ExifInterface.TAG_FLASH)
            if (flash != null) {
                allTags["Flash"] = flash
                result["Flash"] = flash
            }
            
            // ===== FOCAL LENGTH & LENS INFO =====
            val focalLength = exifInterface.getAttribute(ExifInterface.TAG_FOCAL_LENGTH)
            if (focalLength != null) {
                allTags["FocalLength"] = focalLength
                result["FocalLength"] = focalLength
            }
            
            val subjectArea = exifInterface.getAttribute(ExifInterface.TAG_SUBJECT_AREA)
            if (subjectArea != null) {
                allTags["SubjectArea"] = subjectArea
                result["SubjectArea"] = subjectArea
            }
            
            val makerNote = exifInterface.getAttribute(ExifInterface.TAG_MAKER_NOTE)
            if (makerNote != null) {
                allTags["MakerNote"] = makerNote
                result["MakerNote"] = makerNote
            }
            
            val userComment = exifInterface.getAttribute(ExifInterface.TAG_USER_COMMENT)
            if (userComment != null) {
                allTags["UserComment"] = userComment
                result["UserComment"] = userComment
            }
            
            // ===== SOFTWARE & ARTIST INFO =====
            val software = exifInterface.getAttribute(ExifInterface.TAG_SOFTWARE)
            if (software != null) {
                allTags["Software"] = software
                result["Software"] = software
            }
            
            val artist = exifInterface.getAttribute(ExifInterface.TAG_ARTIST)
            if (artist != null) {
                allTags["Artist"] = artist
                result["Artist"] = artist
            }
            
            val copyright = exifInterface.getAttribute(ExifInterface.TAG_COPYRIGHT)
            if (copyright != null) {
                allTags["Copyright"] = copyright
                result["Copyright"] = copyright
            }
            
            // ===== THUMBNAIL INFO =====
            if (exifInterface.hasThumbnail()) {
                allTags["HasThumbnail"] = "true"
                result["HasThumbnail"] = true
                
                if (exifInterface.isThumbnailCompressed()) {
                    allTags["ThumbnailCompressed"] = "true"
                    result["ThumbnailCompressed"] = true
                } else {
                    allTags["ThumbnailCompressed"] = "false"
                    result["ThumbnailCompressed"] = false
                }
                
                val thumbnailRange = exifInterface.thumbnailRange
                if (thumbnailRange != null) {
                    allTags["ThumbnailOffset"] = thumbnailRange[0].toString()
                    allTags["ThumbnailLength"] = thumbnailRange[1].toString()
                    result["ThumbnailOffset"] = thumbnailRange[0]
                    result["ThumbnailLength"] = thumbnailRange[1]
                }
            } else {
                allTags["HasThumbnail"] = "false"
                result["HasThumbnail"] = false
            }
            
            // ===== ADVANCED GPS METHODS =====
            val latLong = FloatArray(2)
            if (exifInterface.getLatLong(latLong)) {
                allTags["Latitude"] = latLong[0].toString()
                allTags["Longitude"] = latLong[1].toString()
                result["Latitude"] = latLong[0]
                result["Longitude"] = latLong[1]
            }
            
            // ===== TIMESTAMP METHODS =====
            val dateTimeOriginalMs = exifInterface.dateTimeOriginal
            if (dateTimeOriginalMs != -1L) {
                allTags["DateTimeOriginalMs"] = dateTimeOriginalMs.toString()
                result["DateTimeOriginalMs"] = dateTimeOriginalMs
            }
            
            val dateTimeDigitizedMs = exifInterface.dateTimeDigitized
            if (dateTimeDigitizedMs != -1L) {
                allTags["DateTimeDigitizedMs"] = dateTimeDigitizedMs.toString()
                result["DateTimeDigitizedMs"] = dateTimeDigitizedMs
            }
            
            val gpsDateTimeMs = exifInterface.gpsDateTime
            if (gpsDateTimeMs != -1L) {
                allTags["GPSDateTimeMs"] = gpsDateTimeMs.toString()
                result["GPSDateTimeMs"] = gpsDateTimeMs
            }
            
            // ===== FILE INFO =====
            allTags["FileSize"] = file.length().toString()
            result["FileSize"] = file.length()
            
            allTags["FileLastModified"] = file.lastModified().toString()
            result["FileLastModified"] = file.lastModified()
            
            // ===== SUPPORTED MIME TYPE CHECK =====
            val mimeType = when {
                imagePath.endsWith(".jpg", true) || imagePath.endsWith(".jpeg", true) -> "image/jpeg"
                imagePath.endsWith(".png", true) -> "image/png"
                imagePath.endsWith(".webp", true) -> "image/webp"
                else -> "unknown"
            }
            
            val isSupported = ExifInterface.isSupportedMimeType(mimeType)
            allTags["SupportedMimeType"] = isSupported.toString()
            result["SupportedMimeType"] = isSupported
            
            // Add all tags to result
            result["allTags"] = allTags
            result["totalTags"] = allTags.size
            result["success"] = true
            
        } catch (e: Exception) {
            result["error"] = e.message ?: "Unknown error"
            result["success"] = false
        }
        
        return result
    }
}
