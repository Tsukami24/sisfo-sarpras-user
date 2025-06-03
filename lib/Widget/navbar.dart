import 'package:flutter/material.dart';
import 'package:sisfo_sarpras_users/pages/home_page.dart';
import 'package:sisfo_sarpras_users/pages/history_page.dart';
import 'package:sisfo_sarpras_users/Service/loan_service.dart';

class NavBarWidget extends StatefulWidget {
  @override
  _NavBarWidgetState createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  int _currentIndex = 0;
  late final LoanService loanService;
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    loanService = LoanService(baseUrl: 'http://127.0.0.1:8000/api');
    _children = [
      HomePage(),
      Container(), 
      LoanHistoryPage(loanService: loanService),
    ];
  }

  void onBarTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(
        context,
        '/loan',
        arguments: null, 
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onBarTapped,
        selectedItemColor: const Color.fromARGB(255, 0, 97, 215),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: screenWidth * 0.06),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box, size: screenWidth * 0.06),
            label: 'Peminjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined, size: screenWidth * 0.06),
            label: 'Riwayat',
          ),
        ],
        selectedLabelStyle: TextStyle(fontSize: screenHeight * 0.02),
        unselectedLabelStyle: TextStyle(fontSize: screenHeight * 0.018),
      ),
    );
  }
}
