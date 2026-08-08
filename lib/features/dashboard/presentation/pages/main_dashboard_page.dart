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
  
  // Fungsi buat ganti tab
  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List pages dipindah ke sini biar bisa passing fungsi _switchTab ke ProfilePage
    final List<Widget> pages = [
      const HomePage(),
      const SearchPage(),
      const OrderPage(),
      ProfilePage(onSwitchTab: _switchTab), // Kirim fungsinya ke sini
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        elevation: 20,
        onTap: _switchTab,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}