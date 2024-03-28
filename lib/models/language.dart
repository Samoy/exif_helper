import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language extends ChangeNotifier {
  LanguageItem? _languageItem = LanguageItem.auto;

  get current => _languageItem;

  void initLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('language')) {
      String language = prefs.getString('language')!;
      LanguageItem languageItem = LanguageItem.values.firstWhere(
        (element) => element.name == language,
        orElse: () => LanguageItem.auto,
      );
      setLanguage(languageItem);
    }
  }

  void setLanguage(LanguageItem? item) async {
    if (_languageItem == item) return;
    _languageItem = item;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', item!.name);
    notifyListeners();
  }
}

enum LanguageItem {
  auto(
    "Auto",
    Locale('auto', 'Auto'),
  ),
  english(
    "English",
    Locale('en', 'US'),
  ),
  chinese(
    "简体中文",
    Locale('zh', 'CN'),
  );

  const LanguageItem(this.name, this.locale);

  final String name;
  final Locale locale;
}
