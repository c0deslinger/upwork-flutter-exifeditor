import 'package:get/get.dart';

import 'en.dart';
import 'ja.dart';

class AppTranslation implements Translations {
  @override
  Map<String, Map<String, String>> get keys =>
      {"ja": languageJa, "en": languageEn};
}
