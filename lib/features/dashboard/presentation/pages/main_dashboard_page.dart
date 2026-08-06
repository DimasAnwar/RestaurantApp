import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import '../../../home/presentation/pages/home_page.dart';
class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({ Key? key }) : super(key: key);

  @override
  _MainDashboardPageState createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {

   int _currentIndex = 0;
  final List<Widget> _pages =[
  HomePage(),
  const Center(child: Text("Halaman Dashboard")),
  const Center(child: Text("Halaman Search")),
  const Center(child: Text("Halaman Profil")),
  const Center(child: Text("Halaman Cart")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        elevation: 20,
        onTap: (int indexBaru) {
          setState(() {
            _currentIndex = indexBaru;
          });
        },
        // Buka daftar items
        items: const [
          // --- ITEM 1 ---
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Ingat: pakai 's' -> Icons.home
            label: "Home",
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // Gua bedain ikonnya biar nggak Home semua
            label: "Search",
          ),
          // --- ITEM 3 ---
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
        ], // Tutup items pakai koma
      ), // Tutup BottomNavigationBar
    ); // Tutup Scaffold
  }
}