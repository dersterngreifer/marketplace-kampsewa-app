import 'package:shared_preferences/shared_preferences.dart';

class Authorization {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<int?> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<bool> deleteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('id');
  }

  Future<void> saveId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', id);
  }

  Future<void> saveType(int type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('type', type);
  }

  Future<int?> getType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('type');
  }

  Future<bool> deleteType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('type');
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('id');
    await prefs.remove('type');
  }
}
