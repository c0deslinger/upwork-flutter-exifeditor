import 'dart:convert';

/// OCRResponse class represents the top-level structure of the OCR.space API response
class OCRResponse {
  final List<ParsedResult>? parsedResults;
  final int? ocrExitCode;
  final bool? isErroredOnProcessing;
  final String? processingTimeInMilliseconds;
  final String? searchablePDFURL;

  OCRResponse({
    this.parsedResults,
    this.ocrExitCode,
    this.isErroredOnProcessing,
    this.processingTimeInMilliseconds,
    this.searchablePDFURL,
  });

  // Create an OCRResponse object from a JSON map
  factory OCRResponse.fromJson(Map<String, dynamic> json) {
    return OCRResponse(
      parsedResults: json['ParsedResults'] == null
          ? null
          : (json['ParsedResults'] as List<dynamic>)
              .map((e) => ParsedResult.fromJson(e as Map<String, dynamic>))
              .toList(),
      ocrExitCode: json['OCRExitCode'] as int?,
      isErroredOnProcessing: json['IsErroredOnProcessing'] as bool?,
      processingTimeInMilliseconds:
          json['ProcessingTimeInMilliseconds'] as String?,
      searchablePDFURL: json['SearchablePDFURL'] as String?,
    );
  }

  // Convert OCRResponse object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'ParsedResults': parsedResults?.map((e) => e.toJson()).toList(),
      'OCRExitCode': ocrExitCode,
      'IsErroredOnProcessing': isErroredOnProcessing,
      'ProcessingTimeInMilliseconds': processingTimeInMilliseconds,
      'SearchablePDFURL': searchablePDFURL,
    };
  }

  // A helper method to parse JSON string to OCRResponse object
  static OCRResponse? fromJsonString(String jsonString) {
    final Map<String, dynamic> data =
        json.decode(jsonString) as Map<String, dynamic>;
    return OCRResponse.fromJson(data);
  }
}

/// ParsedResult class represents each item in the "ParsedResults" array
class ParsedResult {
  final TextOverlay? textOverlay;
  final String? textOrientation;
  final int? fileParseExitCode;
  final String? parsedText;
  final String? errorMessage;
  final String? errorDetails;

  ParsedResult({
    this.textOverlay,
    this.textOrientation,
    this.fileParseExitCode,
    this.parsedText,
    this.errorMessage,
    this.errorDetails,
  });

  // Create a ParsedResult object from a JSON map
  factory ParsedResult.fromJson(Map<String, dynamic> json) {
    return ParsedResult(
      textOverlay: json['TextOverlay'] == null
          ? null
          : TextOverlay.fromJson(json['TextOverlay'] as Map<String, dynamic>),
      textOrientation: json['TextOrientation'] as String?,
      fileParseExitCode: json['FileParseExitCode'] as int?,
      parsedText: json['ParsedText'] as String?,
      errorMessage: json['ErrorMessage'] as String?,
      errorDetails: json['ErrorDetails'] as String?,
    );
  }

  // Convert ParsedResult object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'TextOverlay': textOverlay?.toJson(),
      'TextOrientation': textOrientation,
      'FileParseExitCode': fileParseExitCode,
      'ParsedText': parsedText,
      'ErrorMessage': errorMessage,
      'ErrorDetails': errorDetails,
    };
  }
}

/// TextOverlay class represents the "TextOverlay" field in the OCR response
class TextOverlay {
  final List<dynamic>? lines;
  final bool? hasOverlay;
  final String? message;

  TextOverlay({
    this.lines,
    this.hasOverlay,
    this.message,
  });

  // Create a TextOverlay object from a JSON map
  factory TextOverlay.fromJson(Map<String, dynamic> json) {
    return TextOverlay(
      lines: json['Lines'] as List<dynamic>?,
      hasOverlay: json['HasOverlay'] as bool?,
      message: json['Message'] as String?,
    );
  }

  // Convert TextOverlay object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'Lines': lines,
      'HasOverlay': hasOverlay,
      'Message': message,
    };
  }
}
