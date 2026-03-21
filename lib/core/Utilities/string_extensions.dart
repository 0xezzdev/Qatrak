import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

extension TrainDataTranslator on String {
  String translateTrainData(BuildContext context) {
    if (context.locale.languageCode == 'en') return this;

    final Map<String, String> dictionary = {
      "luxury russian 2nd class": "روسي مكيف درجة ثانية",
      "high dam": "السد العالي",
      "cairo": "القاهرة",
      "aswan": "أسوان",
      "alexandria": "الإسكندرية",
      "luxor": "الأقصر",
      "sohag": "سوهاج",
      "quna": "قنا",
      "all": "الكل",
      "russian ac": "روسي مكيف",
      "russian": "روسي",
      "talgo": "تالجو",
      "vip": "VIP",
      "upgraded spanish": "أسباني مطور",
      "sleeper & seating": "نوم ومقاعد",
      "southbound": "متجه جنوباً (قبلي)",
      "northbound": "متجه شمالاً (بحري)",
    };

    String result = this.toLowerCase();

    dictionary.forEach((key, value) {
      if (result.contains(key)) {
        result = result.replaceAll(key, value);
      }
    });

    return result.replaceAll(" - ", " - ");
  }
}
