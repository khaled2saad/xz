import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _prefKey = 'selected_language';

  LanguageCubit() : super(const Locale('en')) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_prefKey) ?? 'en';
    emit(Locale(langCode));
  }

  Future<void> toggleLanguage() async {
    final newLang = state.languageCode == 'ar' ? 'en' : 'ar';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newLang);
    emit(Locale(newLang));
  }

  Future<void> setLanguage(String langCode) async {
    if (state.languageCode != langCode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, langCode);
      emit(Locale(langCode));
    }
  }
}
