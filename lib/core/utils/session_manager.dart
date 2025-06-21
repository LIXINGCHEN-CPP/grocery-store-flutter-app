import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_info';

  /// 保存登录成功返回的数据
  static Future<void> saveLoginData(Map<String, dynamic> resJson) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 获取 token 和 user 对象
    final token = resJson['data']['token'];
    final user = resJson['data']['user'];

    await prefs.setString(_tokenKey, token ?? '');
    await prefs.setString(_userKey, jsonEncode(user));
  }

  /// 获取 token
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// 获取用户信息 (Map 格式)
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  /// 判断用户是否已登录
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 注销登录
  static Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
