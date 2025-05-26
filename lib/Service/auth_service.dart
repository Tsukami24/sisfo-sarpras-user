import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<bool> login(String name, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'name': name,
        'password': password,
      },
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Decoded JSON: $data');

      final token = data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      if (data['user'] != null && data['user']['id'] != null) {
        await prefs.setInt('userId', data['user']['id']);
        return true;
      } else {
        print("Data user tidak ditemukan dalam response.");
        return false;
      }
    }


    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print("Logout: ${response.statusCode}");

    await prefs.remove('token');
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("TOKEN (getUser): $token");

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("GET USER STATUS: ${response.statusCode}");
    print("GET USER BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      }
    }

    return null;
  }
}
