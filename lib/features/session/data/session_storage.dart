import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const _userNameKey = 'alien_reader_user_name';
  static const _connectedKey = 'alien_reader_connected';
  static const _pageCountKey = 'alien_reader_page_count';

  Future<void> saveSession({
    required String userName,
    required bool connected,
    required int pageCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userNameKey, userName);
    await prefs.setBool(
      _connectedKey,
      false,
    ); // Never persist connected as true across restarts
    await prefs.setInt(_pageCountKey, pageCount);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<bool> isConnected() async {
    return false; // Connection status must be established fresh on each app launch
  }

  Future<int> getPageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pageCountKey) ?? 0;
  }

  Future<void> savePageCount(int pageCount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pageCountKey, pageCount);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userNameKey);
    await prefs.remove(_connectedKey);
    await prefs.remove(_pageCountKey);
  }
}
