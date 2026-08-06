import 'package:flutter/material.dart';
// Pastikan variabel 'primary' benar-benar ada di dalam file ini
import 'package:restauran_app/core/theme/app_colors.dart'; 
import '../../../home/presentation/pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/order_page.dart';
import '../pages/search_page.dart';

class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({ Key? key }) : super(key: key);

  @override
  _MainDashboardPageState createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  int _currentIndex = 0;
  
  // PERBAIKAN: Disesuaikan menjadi 4 item agar sinkron dengan Navbar
  final List<Widget> _pages = [
    const HomePage(), // Pastikan HomePage memiliki const constructor jika memungkinkan
    const SearchPage(), // Nanti bisa diganti dengan ProfilePage yang kita buat sebelumnya
    const OrderPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary, // Pastikan 'primary' ada di AppColors
        elevation: 20,
        onTap: (int indexBaru) {
          setState(() {
            _currentIndex = indexBaru;
          });
        },
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