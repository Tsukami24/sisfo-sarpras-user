import 'package:flutter/material.dart';
import 'package:sisfo_sarpras_users/pages/login_page.dart';
// import 'package:sisfo_sarpras_users/pages/home_page.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sisfo_sarpras_users/Widget/navbar.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginPage(),
      '/home': (context) => NavBarWidget(),
    },
  ));
}
