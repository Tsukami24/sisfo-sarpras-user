import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sisfo_sarpras_users/model/return_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisfo_sarpras_users/model/loan_model.dart';

class ReturnService {
  final String baseUrl;

  ReturnService(this.baseUrl);

  Future<bool> returnItems(int loanId, List<LoanItem> items) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) return false;

  final url = Uri.parse('$baseUrl/returns');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'loan_id': loanId,
      'items': items.map((item) => {
        'item_id': item.id,
        'quantity': item.quantity,
        'condition': 'good',
      }).toList(),
    }),
  );

  return response.statusCode == 200 || response.statusCode == 201;
}
}
