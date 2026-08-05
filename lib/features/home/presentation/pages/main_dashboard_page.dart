import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';

class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({Key? key}) : super(key: key);

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  int _currentIndex = 0;
  int _cartCount = 3; // Contoh jumlah item di cart

  final List<Widget> _pages = [
    const Center(
      child: Text('Halaman Home', style: TextStyle(fontSize: 20)),
    ),
    const Center(
      child: Text('Halaman Pencarian', style: TextStyle(fontSize: 20)),
    ),
    const Center(
      child: Text('Halaman Pesanan / Cart', style: TextStyle(fontSize: 20)),
    ),
    const Center(
      child: Text('Halaman Favorit', style: TextStyle(fontSize: 20)),
    ),
    const Center(
      child: Text('Halaman Profil', style: TextStyle(fontSize: 20)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // extendBody biar body nge-render di belakang navbar (keliatan transparan)
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildPremiumNavBar(),
    );
  }

  Widget _buildPremiumNavBar() {
    const Color primaryColor = Color(0xFFFF6B35);
    const Color darkColor = Color(0xFF2D2D2D);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: darkColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: darkColor.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: primaryColor.withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ===== Item 0: Home =====
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                primaryColor: primaryColor,
              ),

              // ===== Item 1: Search =====
              _buildNavItem(
                index: 1,
                icon: Icons.search_outlined,
                activeIcon: Icons.search_rounded,
                label: 'Cari',
                primaryColor: primaryColor,
              ),

              // ===== Item 2: Center Button (Cart/Order) =====
              _buildCenterButton(
                index: 2,
                primaryColor: primaryColor,
              ),

              // ===== Item 3: Favorit =====
              _buildNavItem(
                index: 3,
                icon: Icons.favorite_outline_rounded,
                activeIcon: Icons.favorite_rounded,
                label: 'Favorit',
                primaryColor: primaryColor,
              ),

              // ===== Item 4: Profil =====
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Akun',
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // ITEM BIASA (Home, Search, Favorit, Profil)
  // ============================================
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color primaryColor,
  }) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon yang naik dikit pas aktif
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(
                0,
                isSelected ? -2 : 2,
                0,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? primaryColor : Colors.grey.shade500,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),

            // Label kecil
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey.shade600,
                fontSize: isSelected ? 10 : 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 4),

            // Indicator dot di bawah
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isSelected ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFFFF6B35),
                          Color(0xFFFF9A5C),
                        ],
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton({
    required int index,
    required Color primaryColor,
  }) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tombol bulat utama
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.translationValues(
                0,
                isSelected ? -8 : -4,
                0,
              ),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [
                            const Color(0xFFFF6B35),
                            const Color(0xFFFF3D00),
                          ]
                        : [
                            const Color(0xFFFF6B35),
                            const Color(0xFFFF8A50),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(isSelected ? 0.5 : 0.3),
                      blurRadius: isSelected ? 16 : 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Icon cart
                    Icon(
                      isSelected
                          ? Icons.shopping_bag_rounded
                          : Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 24,
                    ),

                    // Badge jumlah cart
                    if (_cartCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _cartCount > 9 ? '9+' : '$_cartCount',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 2),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                color: isSelected ? primaryColor : Colors.grey.shade500,
                fontSize: isSelected ? 10 : 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              child: const Text('Order'),
            ),
          ],
        ),
      ),
    );
  }
}