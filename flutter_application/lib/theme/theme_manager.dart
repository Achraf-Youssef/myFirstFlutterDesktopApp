import 'package:fluent_ui/fluent_ui.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  get themeMode => _themeMode;

  toggleTheme(bool isDark) {
    _themeMode = isDark? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}