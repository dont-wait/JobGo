import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _locale = _locale.languageCode == 'vi'
        ? const Locale('en')
        : const Locale('vi');
    notifyListeners();
  }
}
