import 'dart:io';
import 'package:drug_search/model/ocr_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class OcrController extends GetxController {
  final String _apiKey = 'K89467531888957'; // Your OCR.space API key
  final String _ocrApiUrl = 'https://api.ocr.space/parse/image';

  var isLoading = false.obs;
  var ocrResult = ''.obs;

  /// Process OCR on a given image file.
  ///
  /// [file]: The image file to process with OCR.
  /// [language]: The language code for OCR (default: 'jpn').
  /// [detectOrientation]: Whether to detect image orientation (default: true).
  ///
  /// Returns: The recognized text from the image or null if an error occurred.
  Future<String?> processFileOcr(
    File file, {
    String language = 'jpn',
    bool detectOrientation = true,
  }) async {
    isLoading.value = true;
    final fileName = path.basename(file.path);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_ocrApiUrl))
        ..fields['apikey'] = _apiKey
        ..fields['language'] = language
        ..fields['detectOrientation'] = detectOrientation.toString()
        ..files.add(await http.MultipartFile.fromPath('file', file.path,
            filename: fileName));

      debugPrint("apikey $_apiKey $_ocrApiUrl");

      var response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      debugPrint("res: ${responseBody.body}");

      if (response.statusCode == 200) {
        final ocrResponse = OCRResponse.fromJsonString(responseBody.body);

        if (ocrResponse == null) {
          ocrResult.value = 'Failed to parse OCR response.';
          return null;
        }

        // Check for errors in processing
        if (ocrResponse.isErroredOnProcessing == true) {
          String errorMessage =
              'An unknown error occurred during OCR processing.';
          // If error details are available in the response, use them
          if (ocrResponse.parsedResults != null &&
              ocrResponse.parsedResults!.isNotEmpty) {
            final firstResult = ocrResponse.parsedResults![0];
            if (firstResult.errorMessage != null &&
                firstResult.errorMessage!.isNotEmpty) {
              errorMessage = firstResult.errorMessage!;
            }
          }
          ocrResult.value = 'Error: $errorMessage';
          return null;
        }

        // Extract parsed text from the first ParsedResult
        if (ocrResponse.parsedResults == null ||
            ocrResponse.parsedResults!.isEmpty) {
          ocrResult.value = 'No parsed results found.';
          return null;
        }

        final firstParsedResult = ocrResponse.parsedResults![0];
        String parsedText = firstParsedResult.parsedText ?? '';

        // Replace occurrences of \r\n with spaces and trim whitespace
        parsedText = parsedText.replaceAll('\r\n', ' ').trim();

        ocrResult.value = parsedText;
        return parsedText;
      } else {
        ocrResult.value =
            'Error: ${response.statusCode} - ${response.reasonPhrase}';
        return null;
      }
    } catch (e) {
      ocrResult.value = 'Exception: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }
}
