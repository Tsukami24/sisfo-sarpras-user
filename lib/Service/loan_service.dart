import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisfo_sarpras_users/model/loan_model.dart';

class LoanService {
  final String baseUrl;
  LoanService({required this.baseUrl});

  Future<Map<String, dynamic>?> postLoan({
    required int userId,
    required String loanDate,
    required String reason,
    required List<LoanItem> items,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/loan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'loan_date': loanDate,
        'reason': reason,
        'items': items.map((item) => item.toJson()).toList(),
      }),
    );

    return (response.statusCode == 200 || response.statusCode == 201)
        ? jsonDecode(response.body)
        : null;
  }

  Future<List<Map<String, dynamic>>> getItems() async {
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

    final List<dynamic> data = jsonDecode(response.body);
    return data
        .map((item) => {'id': item['id'], 'name': item['name']})
        .toList();
  }

Future<List<LoanHistory>> getLoanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/loans'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data pinjaman');
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> data = decoded['data'];
    return data.map((e) => LoanHistory.fromJson(e)).toList();
  }

  

  
}
