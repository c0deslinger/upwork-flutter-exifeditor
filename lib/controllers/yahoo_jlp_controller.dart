// controllers/yahoo_jlp_controller.dart

import 'package:drug_search/model/yahoo_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class YahooJlpController extends GetxController {
  final String apiUrl =
      "https://jlp.yahooapis.jp/MAService/V2/parse"; // Update if the API URL has changed
  final String apiKey =
      "Yahoo AppID: dj00aiZpPVdmNG55V05vQkt2cCZzPWNvbnN1bWVyc2VjcmV0Jng9OGE-"; // Replace with your actual API key

  Future<YahooJlpResponse?> fetchYahooJlpData(String text) async {
    YahooJlpResponse? responseYahoo;
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "User-Agent": apiKey,
        },
        body: jsonEncode({
          "id": "1234-1",
          "jsonrpc": "2.0",
          "method": "jlp.furiganaservice.furigana",
          "params": {"q": text}
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        debugPrint("response yahoo: ${response.body}");
        responseYahoo = YahooJlpResponse.fromJson(data);
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      return responseYahoo;
    }
  }
}
