import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  static AppColors? _instance;

  static AppColors get instance {
    return _instance ?? AppColors._internal();
  }

  AppColors._internal() {
    _instance = this;
  }

  static const primaryGreenDark1 = Color.fromRGBO(112, 112, 94, 1);
  static const primaryGreenLight1 = Color.fromRGBO(166, 169, 152, 1);
  static const tabColor = Color(0xFFC0D4DA);
  static const primayGold = Color(0xFFCC7E32);
  static const hintText = Color(0xFF5C6065);
  static const background = Color.fromRGBO(247, 247, 247, 1);
  static const backgroundBlack = Colors.black;
  static const greyShadow = Color(0xFF545B61);

  static const greyBase4 = Color.fromRGBO(103, 103, 103, 1);
  static const greyBase3 = Color.fromRGBO(170, 170, 170, 1);
  static const greyBase2 = Color.fromRGBO(230, 225, 229, 1);
  static const greyBase1 = Color.fromRGBO(242, 242, 242, 1);

  static const inputBorderColor = Color(0xFFD0D5DD);

  static const accentYellow = Color.fromRGBO(253, 196, 110, 1);
  static const accentRed = Color.fromRGBO(225, 63, 66, 1);
  static const limeGreen = Color.fromRGBO(117, 231, 176, 1);
  static const lightPurple = Color.fromRGBO(233, 228, 244, 1);
  static const lightBlue = Color.fromRGBO(184, 210, 250, 1);
  static const lightYellow = Color.fromRGBO(255, 234, 159, 1);
  static const purple = Color(0xFF6D4AB6);
  static const purpleDark = Color(0xFF312152);
  static const greenAccent = Color.fromRGBO(27, 140, 86, 1);
  static const titleBlack = Color(0xFF212226);
  static const titleGrey = Color(0xFF5C6065);
  static const lightGrey = Color(0xFFD0D5DD);
  static const lineGrey = Color(0xFFEEEEEE);
  static const lightGreyDarkMode = Color(0xFFAAAAAA);
  static const semiLightGrey = Color(0xFFEFEFEF);
  static const hintGrey = Color(0xFF9A9DA1);
  static const borderGrey = Color(0xFFDEDEDE);
  static const inputFieldDarkMode = Color(0xFF1C1C25);
  static const modalBgDarkMode = Color.fromARGB(255, 19, 19, 25);
  static const lineDark = Color(0xFF38383E);

  //DEFAULT

  static const bannerText = Color.fromRGBO(171, 56, 98, 1);

  static const neutralBlack100 = Color.fromRGBO(51, 51, 51, 1);
  static const neutralGrey100 = Color.fromRGBO(79, 79, 79, 1);
  static const neutralGrey80 = Color.fromRGBO(130, 130, 130, 1);
  static const neutralGrey60 = Color.fromRGBO(189, 189, 189, 1);
  static const neutralGrey40 = Color.fromRGBO(224, 224, 224, 1);
  static const neutralGrey20 = Color.fromRGBO(242, 242, 242, 1);
  static const lightGrey2 = Color.fromRGBO(187, 194, 210, 1);

  static const greyLight = Color.fromRGBO(187, 194, 210, 1);
  static const grey = Color.fromRGBO(187, 194, 210, 1);
  static const greenDark = Color.fromRGBO(33, 150, 83, 1);
  static const green = Color.fromRGBO(67, 174, 90, 1);
  static const greenLight = Color.fromRGBO(111, 207, 151, 1);
  static const greenHalu = Color.fromRGBO(7, 210, 200, 1);
  static const greenLightBanner = Color.fromRGBO(217, 248, 244, 1);

  static const danger = Color.fromRGBO(235, 87, 87, 1);
  static const danger32 = Color.fromRGBO(235, 87, 87, 0.32);
  static const dangerPink = Color.fromRGBO(229, 91, 141, 0.15);
  static const dangerYellow = Color.fromRGBO(255, 242, 222, 1);
  static const dangerLight = Color.fromRGBO(243, 25, 78, 1);

  static const backgroundWhite = Colors.white;
  static const backgroundGrey = Color.fromRGBO(248, 248, 254, 1);
  static const silver = Color.fromRGBO(234, 237, 245, 1);

  static const borderCardColor = Color.fromRGBO(98, 96, 109, 1);
  static const borderRadioNotSelected = Color.fromRGBO(110, 111, 120, 1);
  static const textGrey = Color.fromRGBO(133, 137, 149, 1);
  static const bluePrimary = Color.fromRGBO(41, 73, 157, 1);

  // static const layerOpacity3 = Color.fromRGBO(255, 255, 255, 0.08);
  static const layerOpacity3 = Color.fromRGBO(255, 255, 255, .08);

  //gradient
  static const gradientCardBackground = [
    Color.fromRGBO(0, 38, 76, 1),
    Color.fromRGBO(0, 28, 63, 1),
  ];

  Color getSecondaryBackgroundColor() =>
      Get.isDarkMode ? Colors.black : const Color.fromRGBO(247, 247, 247, 1);

  Color getTitleColor() => Get.isDarkMode ? Colors.white : AppColors.titleBlack;

  Color getFormTitleColor() =>
      Get.isDarkMode ? const Color(0xFFAAAAAA) : AppColors.titleBlack;

  Color getShippingColor() =>
      Get.isDarkMode ? AppColors.lightGreyDarkMode : const Color(0xFF212226);

  Color getBWColor() => Get.isDarkMode ? Colors.white : Colors.black;
  Color getWBColor() => Get.isDarkMode ? Colors.black : Colors.white;

  Color getInputText() =>
      Get.isDarkMode ? const Color(0xFF7D7D85) : AppColors.hintText;

  Color getBgCardColor() =>
      Get.isDarkMode ? AppColors.inputFieldDarkMode : const Color(0xFFF2F2F2);

  Color getBgNotifactionCardColor() => Get.isDarkMode
      ? AppColors.inputFieldDarkMode
      : const Color.fromRGBO(247, 247, 247, 1);

  Color getBgCardWhiteColor() =>
      Get.isDarkMode ? AppColors.inputFieldDarkMode : Colors.white;

  Color getBgCardSemiWhiteColor() =>
      Get.isDarkMode ? AppColors.inputFieldDarkMode : const Color(0xFFFCFCFC);

  Color getBgCardSemiWhite2Color() =>
      Get.isDarkMode ? AppColors.inputFieldDarkMode : const Color(0xFFF7F7F7);

  Color getComingSoonBgColor() =>
      Get.isDarkMode ? const Color(0xFF52525C) : const Color(0xFFEBEBEB);

  Color getComingSoonTitleColor() =>
      Get.isDarkMode ? AppColors.lightGreyDarkMode : const Color(0xFF212226);

  Color getSubtitleColor() =>
      (Get.isDarkMode) ? AppColors.lightGreyDarkMode : AppColors.titleGrey;

  Color getChatTextColor() =>
      (Get.isDarkMode) ? AppColors.lightGreyDarkMode : Colors.white;

  Color getSubOnDarkColor() =>
      (Get.isDarkMode) ? AppColors.lightGreyDarkMode : AppColors.titleBlack;

  Color getSubOnLightColor() =>
      (Get.isDarkMode) ? Colors.white : AppColors.titleGrey;

  Color getDisabledColor() =>
      (Get.isDarkMode) ? const Color(0xFF7D7D85) : const Color(0xFFB4B4B4);

  Color getLightGreyColor() =>
      (Get.isDarkMode) ? AppColors.lightGreyDarkMode : AppColors.lightGrey;

  Color getIconButtonColor() =>
      (Get.isDarkMode) ? AppColors.lightGreyDarkMode : AppColors.titleBlack;

  Color getBlackOrPurple() =>
      (Get.isDarkMode) ? AppColors.purple : AppColors.titleBlack;

  Color getModalColor() =>
      Get.isDarkMode ? const Color(0xFF101016) : Colors.white;
  Color getBorderColor() => const Color(0xFFAAAAAA);

  // Color getBubbleColorNotMe() =>
  //     Get.isDarkMode ? AppColors.inputFieldDarkMode : const Color(0xFFF0F0F0);

  Color getBubbleColor({bool? isDarkMode}) => (isDarkMode ?? Get.isDarkMode)
      ? AppColors.inputFieldDarkMode
      : const Color(0xFF161F67);

  Color getBubbleColorNotMe({bool? isDarkMode}) =>
      (isDarkMode ?? Get.isDarkMode)
          ? AppColors.inputFieldDarkMode
          : const Color(0xFFF0F0F0);

  Color getBubbleContentColorNotMe(bool isContentPlainText,
          {bool? isDarkMode}) =>
      isDarkMode ?? Get.isDarkMode
          ? AppColors.inputFieldDarkMode
          : isContentPlainText
              ? Colors.white
              : Colors.white.withOpacity(.5);

  Color labelColor({bool? isDarkMode}) => isDarkMode ?? Get.isDarkMode
      ? const Color.fromARGB(255, 215, 215, 215)
      : Colors.grey;
}
