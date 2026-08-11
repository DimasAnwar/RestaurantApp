import 'dart:async';
import 'package:flutter/material.dart';
import 'package:restauran_app/features/admin/data/admin_repository.dart';
import 'package:restauran_app/features/admin/presentation/pages/admin_dashboard_tab.dart';
import 'package:restauran_app/features/admin/presentation/pages/admin_financials_tab.dart';
import 'package:restauran_app/features/admin/presentation/pages/admin_orders_tab.dart';
import 'package:restauran_app/features/admin/presentation/pages/admin_settings_tab.dart';
import 'package:restauran_app/features/admin/presentation/widgets/admin_bottom_nav.dart';
import 'package:restauran_app/features/admin/presentation/widgets/admin_header.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({Key? key}) : super(key: key);

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentTabIndex = 0; // Default to Dashboard Tab
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchAdminOrders();
  }

  Future<void> _fetchAdminOrders() async {
    if (_orders.isEmpty && mounted) setState(() => _isLoading = true);

    final data = await AdminRepository.instance.fetchOrders();

    if (mounted) {
      setState(() {
        _orders = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AdminHeader(
        onNotificationTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifikasi Admin: Pesanan baru telah diterima! 🔔'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onProfileTap: () {
          setState(() => _currentTabIndex = 3);
        },
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTabIndex,
            children: [
              // Tab 0: Dashboard Overview (Dapur, Quick Stats, Priority Orders)
              AdminDashboardTab(
                orders: _orders,
                isLoading: _isLoading,
                onRefresh: _fetchAdminOrders,
                onNavigateToTab: (tabIndex) {
                  setState(() => _currentTabIndex = tabIndex);
                },
              ),
              // Tab 1: Orders (New, In Process, Shipped, History)
              AdminOrdersTab(
                orders: _orders,
                isLoading: _isLoading,
                onRefresh: _fetchAdminOrders,
              ),
              // Tab 2: Financials (Revenue overview & transactions)
              AdminFinancialsTab(
                orders: _orders,
              ),
              // Tab 3: Settings
              const AdminSettingsTab(),
            ],
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AdminBottomNav(
              currentIndex: _currentTabIndex,
              onTap: (index) {
                setState(() => _currentTabIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
