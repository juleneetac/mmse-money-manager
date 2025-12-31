import 'package:shared_preferences/shared_preferences.dart';

// Service used to store simple app preferences
/// like the user name (local storage)
class PreferencesService {
  static const _userNameKey = 'user_name';
  static const _initializedKey = 'initialized';

  // Save user name
  Future<void> saveProfile(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setBool(_initializedKey, true);
  }

  // Check if app was opened before
  Future<bool> isInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initializedKey) ?? false;
  }

  // Save user name locally
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  // Get stored user name
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? '';
  }
}
