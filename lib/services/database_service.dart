import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static const String baseUrl = 'https://your-api-url.com/api';
  final http.Client client = http.Client();

  Future<Map<String, dynamic>> loginWithPhone(
      String phone, String password) async {
    try {
      final response = await client
          .post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Connection timeout');
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return {'success': true, 'token': data['token']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Connection timeout. Please check your network'
      };
    } on http.ClientException catch (e) {
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } on http.Response catch (e) {
      if (e.statusCode == 401) {
        return {'success': false, 'message': 'Wrong phone number or password'};
      }
      return {'success': false, 'message': 'Login failed (${e.statusCode})'};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}'
      };
    }
  }
}
