import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemModel extends ChangeNotifier {
  SystemModel({required SharedPreferences? prefs}) {
    _prefs = prefs;
    init();
  }

  Language _languageItem = Language.system;
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;

  get currentLanguage => _languageItem;

  get currentThemeMode => _themeMode;

  Map<Type, Enum> get currentSystemValue => {
        Language: currentLanguage,
        ThemeMode: currentThemeMode,
      };

  Future<void> init() async {
    if (_prefs != null) {
      if (_prefs!.containsKey('language')) {
        String language = _prefs!.getString('language')!;
        Language languageItem = Language.values.firstWhere(
          (element) => element.name == language,
          orElse: () => Language.system,
        );
        setLanguage(languageItem);
      }
      if (_prefs!.containsKey('themeMode')) {
        String themeMode = _prefs!.getString('themeMode')!;
        ThemeMode themeModeItem = ThemeMode.values.firstWhere(
          (element) => element.name == themeMode,
          orElse: () => ThemeMode.system,
        );
        setThemeMode(themeModeItem);
      }
    }
  }

  void setLanguage(Language item) async {
    if (_languageItem == item) return;
    _languageItem = item;
    await _prefs?.setString('language', item.name);
    notifyListeners();
  }

  void setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    _themeMode = themeMode;
    await _prefs?.setString('themeMode', themeMode.name);
    notifyListeners();
  }

  void setSystemValue(Enum systemValue) async {
    if (systemValue is Language) {
      setLanguage(systemValue);
    } else if (systemValue is ThemeMode) {
      setThemeMode(systemValue);
    }
  }
}

enum Language implements Enum {
  system(Locale('system', 'Auto')),
  en(Locale('en', 'US')),
  zh(Locale('zh', 'CN'));

  const Language(this.locale);

  final Locale locale;
}
