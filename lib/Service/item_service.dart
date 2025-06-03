import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sisfo_sarpras_users/model/item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<List<Item>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/item'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Gagal Memuat Barang');
    }
  }

  static Future<List<String>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/category'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data.map((category) => category['name']));
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

}

