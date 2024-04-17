import 'package:exif_helper/models/system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'system_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  group('test SystemModel', () {
    late MockSharedPreferences mockPrefs;
    late SystemModel systemModel;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      // 设置模拟数据
      when(mockPrefs.getString('language')).thenReturn('system');
      when(mockPrefs.getString('themeMode')).thenReturn('system');
      when(mockPrefs.containsKey('language')).thenReturn(true);
      when(mockPrefs.containsKey('themeMode')).thenReturn(true);
      // 初始化SystemModel
      systemModel = SystemModel(prefs: mockPrefs);
    });

    test('init should set language correctly', () async {
      verify(mockPrefs.getString('language'));
      verify(mockPrefs.getString('themeMode'));
      expect(systemModel.currentLanguage, Language.system);
      expect(systemModel.currentThemeMode, ThemeMode.system);
    });

    test('setLanguage should update language correctly', () async {
      when(mockPrefs.setString("language", 'zh'))
          .thenAnswer((realInvocation) async => true);
      systemModel.setLanguage(Language.zh);
      verify(mockPrefs.setString('language', 'zh'));
      expect(systemModel.currentLanguage, Language.zh);
    });

    test('setThemeMode should update themeMode and persist in preferences',
        () async {
      when(mockPrefs.setString("themeMode", 'dark'))
          .thenAnswer((realInvocation) async => true);
      // Set themeMode
      systemModel.setThemeMode(ThemeMode.dark);
      verify(mockPrefs.setString('themeMode', 'dark'));
      // Verify themeMode is updated
      expect(systemModel.currentThemeMode, ThemeMode.dark);
    });

    test(
        'setSystemValue should update language or themeMode based on the systemValue',
        () async {
      // Set language
      when(mockPrefs.setString('language', 'zh')).thenAnswer((_) async => true);
      systemModel.setSystemValue(Language.zh);
      verify(mockPrefs.setString('language', 'zh'));
      // Verify language is updated
      expect(systemModel.currentLanguage, Language.zh);
      when(mockPrefs.setString('themeMode', 'light'))
          .thenAnswer((_) async => true);
      // Set themeMode
      systemModel.setSystemValue(ThemeMode.light);
      verify(mockPrefs.setString('themeMode', 'light'));
      // Verify themeMode is updated
      expect(systemModel.currentThemeMode, ThemeMode.light);
      expect(systemModel.currentSystemValue[Language], equals(Language.zh));
      expect(
          systemModel.currentSystemValue[ThemeMode], equals(ThemeMode.light));
    });
  });
}
