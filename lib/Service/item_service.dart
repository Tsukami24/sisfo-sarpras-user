import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sisfo_sarpras_users/model/item_model.dart';

class ItemService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<List<Item>> getItems() async {
    final response = await http.get(Uri.parse('$baseUrl/item'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }
}

