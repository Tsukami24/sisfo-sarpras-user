import 'package:flutter/material.dart';
import 'package:sisfo_sarpras_users/pages/login_page.dart';
import 'package:sisfo_sarpras_users/pages/loan_page.dart';
import 'package:sisfo_sarpras_users/Service/loan_service.dart';
import 'package:sisfo_sarpras_users/Widget/navbar.dart';
import 'package:sisfo_sarpras_users/model/loan_model.dart';

void main() {
  final loanService = LoanService(baseUrl: 'http://127.0.0.1:8000/api');

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginPage(),
      '/home': (context) => NavBarWidget(),
    },
    onGenerateRoute: (settings) {
      if (settings.name == '/loan') {
        final loanItem = settings.arguments as LoanItem?;
        return MaterialPageRoute(
          builder: (context) => LoanPage(
            loanService: loanService,
            initialItem: loanItem, 
          ),
        );
      }
      return null;
    },

  ));
}
