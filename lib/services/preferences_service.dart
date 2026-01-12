import 'package:shared_preferences/shared_preferences.dart';

// Service used to store simple app preferences
/// like the user name (local storage)
class PreferencesService {
  static const _userNameKey = 'user_name';
  static const _initializedKey = 'initialized';
  static const _defaultCategoriesInsertedKey = 'default_categories_inserted';

  // Check if app was opened before
  Future<bool> isInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initializedKey) ?? false;
  }

  // Save username locally
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setBool(_initializedKey, true);
  }

  // Get stored user name
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? '';
  }

  // Check if app default categories are inserted (only in the first launch)
  Future<bool> areDefaultCategoriesInserted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_defaultCategoriesInsertedKey) ?? false;
  }
  // Mark default categories as inserted
  Future<void> markDefaultCategoriesInserted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_defaultCategoriesInsertedKey, true);
  }
}
