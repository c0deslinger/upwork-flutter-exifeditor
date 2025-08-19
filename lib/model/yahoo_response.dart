import 'dart:convert';

class SubWord {
  final String? furigana;
  final String? roman;
  final String? surface;

  SubWord({
    this.furigana,
    this.roman,
    this.surface,
  });

  factory SubWord.fromJson(Map<String, dynamic> json) {
    return SubWord(
      furigana: json['furigana'] as String?,
      roman: json['roman'] as String?,
      surface: json['surface'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'furigana': furigana,
      'roman': roman,
      'surface': surface,
    };
  }
}

class Word {
  final String? furigana;
  final String? roman;
  final String? surface;
  final List<SubWord>? subword;

  Word({
    this.furigana,
    this.roman,
    this.surface,
    this.subword,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    var subwordJson = json['subword'] as List?;
    List<SubWord>? subwordList;
    if (subwordJson != null) {
      subwordList = subwordJson
          .map((sw) => SubWord.fromJson(sw as Map<String, dynamic>))
          .toList();
    }

    return Word(
      furigana: json['furigana'] as String?,
      roman: json['roman'] as String?,
      surface: json['surface'] as String?,
      subword: subwordList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'furigana': furigana,
      'roman': roman,
      'surface': surface,
      'subword': subword?.map((sw) => sw.toJson()).toList(),
    };
  }
}

class Result {
  final List<Word>? word;

  Result({this.word});

  factory Result.fromJson(Map<String, dynamic> json) {
    var wordJson = json['word'] as List?;
    List<Word>? wordList;
    if (wordJson != null) {
      wordList = wordJson
          .map((w) => Word.fromJson(w as Map<String, dynamic>))
          .toList();
    }

    return Result(word: wordList);
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word?.map((w) => w.toJson()).toList(),
    };
  }
}

class YahooJlpResponse {
  final String? id;
  final String? jsonrpc;
  final Result? result;

  YahooJlpResponse({
    this.id,
    this.jsonrpc,
    this.result,
  });

  factory YahooJlpResponse.fromJson(Map<String, dynamic> json) {
    return YahooJlpResponse(
      id: json['id'] as String?,
      jsonrpc: json['jsonrpc'] as String?,
      result: json['result'] != null
          ? Result.fromJson(json['result'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jsonrpc': jsonrpc,
      'result': result?.toJson(),
    };
  }

  // Helper method to create a YahooJlpResponse object from a JSON string
  static YahooJlpResponse? fromJsonString(String jsonString) {
    final Map<String, dynamic> data =
        json.decode(jsonString) as Map<String, dynamic>;
    return YahooJlpResponse.fromJson(data);
  }
}
