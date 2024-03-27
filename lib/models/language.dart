import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {

  LanguageProvider({
    required this.languageItems,
  });

  final List<LanguageItem> languageItems;

  LanguageItem? _languageItem;

  get currentLanguageItem => _languageItem;

  void setLocale(int index) {
    if (_languageItem == languageItems[index]) return;
    _languageItem = languageItems[index];
    notifyListeners();
  }
}

class LanguageItem {
  LanguageItem({required this.name, required this.locale});

  final String name;
  final Locale locale;
}
