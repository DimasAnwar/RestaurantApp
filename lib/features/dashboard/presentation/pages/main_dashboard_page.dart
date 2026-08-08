import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart'; 
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/pages/profile_page.dart';
import '../pages/order_page.dart';
import '../pages/search_page.dart';

class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({ Key? key }) : super(key: key);

  @override
  _MainDashboardPageState createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  int _currentIndex = 0;
  String _searchQuery = '';
  int _searchTab = 0;
  
  // Fungsi ganti tab yang di-upgrade buat nerima parameter filter
  void _switchTab(int index, {String? query, int? tabIndex}) {
    setState(() {
      _currentIndex = index;
      if (query != null) _searchQuery = query;
      if (tabIndex != null) _searchTab = tabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(onSwitchTab: _switchTab),
      // Lempar parameter ke SearchPage
      SearchPage(initialQuery: _searchQuery, initialTab: _searchTab), 
      const OrderPage(),
      // PERBAIKAN DI SINI: Bungkus pakai (index) => _switchTab(index)
      ProfilePage(onSwitchTab: (index) => _switchTab(index)), 
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        elevation: 20,
        onTap: (index) => _switchTab(index), // Tap biasa dari navbar
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}