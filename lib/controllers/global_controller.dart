import 'dart:io';
import 'package:drug_search/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_storage/get_storage.dart';

class GlobalController extends GetxController {
  Locale locale = const Locale("en");
  String? cameraResolution;
  int currentTicket = 5;
  int requestRewardAdCounter = 0;

  int fontSize = 20; // Default font size
  int rubyFontSize = 12; // Default ruby font size
  bool isDarkMode = false; // Default mode
  bool isVertical = false; // Default layout (Horizontal)

  bool isFirstTimeOpen = false;
  DateTime? lastShowReview; // Variabel untuk menyimpan tanggal terakhir review
  String currency = "usd";
  String? savedZip;
  final box = GetStorage();
  String? savedPath;
  int requestReviewCounter = 0;
  bool isBackFromSelectImages = false;

  @override
  void onInit() {
    super.onInit();
    _getLastSetting();
    _getLastShowReview();
  }

  // ---------------------------------------------------------------------------
  // SECTION: Review
  // ---------------------------------------------------------------------------

  // Mengambil lastShowReview dari SharedPreferences
  Future<void> _getLastShowReview() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedDate = prefs.getString("lastShowReview");
    if (storedDate != null) {
      lastShowReview = DateTime.parse(storedDate);
    }
    update();
  }

  // Menyimpan lastShowReview ke SharedPreferences
  Future<void> _setLastShowReview(DateTime dateTime) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    lastShowReview = dateTime;
    prefs.setString("lastShowReview", dateTime.toIso8601String());
    update();
  }

  // Mengecek apakah lastShowReview sudah lebih dari satu bulan
  bool isLastShowReviewMoreThanOneMonth() {
    if (lastShowReview == null) {
      return true; // Jika null, dianggap lebih dari 1 bulan yang lalu
    }
    DateTime oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastShowReview!.isBefore(oneMonthAgo);
  }

  // Menambah satu bulan ke lastShowReview
  Future<void> addOneMonthToLastShowReview() async {
    if (lastShowReview != null) {
      DateTime newDate = DateTime(
        lastShowReview!.year,
        lastShowReview!.month + 1,
        lastShowReview!.day,
      );
      await _setLastShowReview(newDate);
    } else {
      // Jika lastShowReview null, set ke waktu sekarang plus satu bulan
      await _setLastShowReview(DateTime.now().add(const Duration(days: 30)));
    }
  }

  // ---------------------------------------------------------------------------
  // SECTION: Setting
  // ---------------------------------------------------------------------------

  // Mengambil semua setting terakhir dari SharedPreferences
  Future<void> _getLastSetting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Deteksi bahasa device
    String currentLocale = Platform.localeName;
    bool isDeviceUseJapan = currentLocale.contains("ja");

    // Ambil data SharedPreferences
    String? storedLangCode = prefs.getString("locale");
    String? storedResolution = prefs.getString("resolution");
    int? storedCurrentTicket = prefs.getInt("currentTicket");
    int? storedRequestRewardAdCounter = prefs.getInt("requestRewardAdCounter");
    int? storedFontSize = prefs.getInt("fontSize");
    int? storedRubyFontSize = prefs.getInt("rubyFontSize");
    bool? storedIsDarkMode = prefs.getBool("isDarkMode");
    bool? storedIsVertical = prefs.getBool("isVertical");
    String? storedCurrency = prefs.getString("currency");
    isFirstTimeOpen = prefs.getBool("isFirstTimeOpen") ?? true;
    requestReviewCounter = prefs.getInt("requestReviewCounter") ?? 0;

    // Set nilai-nilai GlobalController
    locale = Locale(storedLangCode ?? (isDeviceUseJapan ? "ja" : "en"));
    cameraResolution = storedResolution ?? "Medium";
    currentTicket = storedCurrentTicket ?? 5;
    requestRewardAdCounter = storedRequestRewardAdCounter ?? 0;
    fontSize = storedFontSize ?? 20;
    rubyFontSize = storedRubyFontSize ?? 12;
    isDarkMode = storedIsDarkMode ?? false;
    isVertical = storedIsVertical ?? false;
    currency = storedCurrency ?? "usd";
    getSavedZip();
    getSavedPath();

    // Update bahasa dan tema
    Get.updateLocale(locale);
    Get.changeTheme(isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme);

    update();
  }

  // Ganti bahasa
  Future<void> changeLanguage({required String changeToLangeuage}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("locale", changeToLangeuage);
    locale = Locale(changeToLangeuage);
    Get.updateLocale(locale);
    update();
    // Refresh setting agar data sinkron
    _getLastSetting();
  }

  // Ganti currency
  Future<void> changeCurrency({required String changeToCurrency}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("currency", changeToCurrency);
    currency = changeToCurrency;
    update();
    // Refresh setting agar data sinkron
    _getLastSetting();
  }

  // Ganti resolusi kamera
  Future<void> setResolution({required String resolution}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("resolution", resolution);
    cameraResolution = resolution;
    update();
  }

  // ---------------------------------------------------------------------------
  // SECTION: Ticket
  // ---------------------------------------------------------------------------

  Future<void> decreaseCurrentTicket() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (currentTicket > 0) {
      currentTicket--;
      prefs.setInt("currentTicket", currentTicket);
      update();
    }
  }

  Future<void> resetCurrentTicket() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    currentTicket = 5;
    prefs.setInt("currentTicket", currentTicket);
    update();
  }

  void addMoreTicket(int i) {
    SharedPreferences.getInstance().then((prefs) {
      currentTicket += i;
      prefs.setInt("currentTicket", currentTicket);
      update();
    });
  }

  void addRequestRewardAdCounter() {
    SharedPreferences.getInstance().then((prefs) {
      requestRewardAdCounter++;
      prefs.setInt("requestRewardAdCounter", requestRewardAdCounter);
      update();
    });
  }

  // ---------------------------------------------------------------------------
  // SECTION: Font & Layout
  // ---------------------------------------------------------------------------

  // Mengubah ukuran font
  Future<void> setFontSize(int size) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    fontSize = size;
    prefs.setInt("fontSize", size);
    update();
  }

  // Mengubah ukuran font rubi
  Future<void> setRubyFontSize(int size) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    rubyFontSize = size;
    prefs.setInt("rubyFontSize", size);
    update();
  }

  // Mengaktifkan / menonaktifkan Dark Mode
  Future<void> toggleDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode = !isDarkMode;
    prefs.setBool("isDarkMode", isDarkMode);
    Get.changeTheme(isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme);
    update();
  }

  // Mengubah layout (Vertical / Horizontal)
  Future<void> toggleLayout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isVertical = !isVertical;
    prefs.setBool("isVertical", isVertical);
    update();
  }

  Future<void> setNotFirstTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isFirstTimeOpen", false);
    isFirstTimeOpen = prefs.getBool("isFirstTimeOpen") ?? true;
    update();
  }

  Future<bool> checkIsFirstTimeOpen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isFirstTimeOpen = prefs.getBool("isFirstTimeOpen") ?? true;
    return isFirstTimeOpen;
  }

  Future<String?> getSavedZip() async {
    savedZip = box.read("savedZip");
    update();
    return savedZip;
  }

  Future<void> setSavedPath({required String path}) async {
    box.write("savedPath", path);
    savedPath = path;
    update();
  }

  Future<String?> getSavedPath() async {
    savedPath = box.read("savedPath");
    update();
    return savedPath;
  }

  void addRequestReviewCounter() async {
    requestReviewCounter++;
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("requestReviewCounter", requestReviewCounter);
    update();
  }
}
