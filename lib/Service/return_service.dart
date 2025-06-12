import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sisfo_sarpras_users/model/return_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ReturnService {
  final String baseUrl;

  ReturnService(this.baseUrl);

  Future<bool> returnItems(List<ReturnItem> items) async {
    final loanId = items.isNotEmpty ? items[0].loanId : null;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/returns'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'loan_id': loanId,
        'items': items.map((e) => e.toJson()).toList(),
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Gagal mengembalikan barang: ${response.body}');
    }
  }
}
