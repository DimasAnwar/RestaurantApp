import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'package:restauran_app/features/admin/presentation/widgets/order_card_widget.dart';
import 'package:restauran_app/features/admin/presentation/widgets/print_receipt_dialog.dart';

class AdminDashboardTab extends StatelessWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final VoidCallback onRefresh;
  final ValueChanged<int> onNavigateToTab;

  const AdminDashboardTab({
    Key? key,
    required this.orders,
    required this.isLoading,
    required this.onRefresh,
    required this.onNavigateToTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pendingCount = orders.where((o) => o['status'] == 'pending').length;
    final cookingCount = orders.where((o) => o['status'] == 'cooking').length;
    final deliveryCount = orders.where((o) => o['status'] == 'on_delivery').length;
    final completedCount = orders.where((o) => o['status'] == 'completed').length;

    final urgentOrders = orders.where((o) => o['status'] == 'pending' || o['status'] == 'cooking').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Dapur & Resto',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),

              // Status Dapur Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD83A1E), Color(0xFFB82810)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD83A1E).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KITCHEN STATUS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Normal Load • ${orders.length} Total Orders',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Operational Stat Grid (4 Cards)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    title: 'Pesanan Baru',
                    count: '$pendingCount',
                    icon: Icons.notifications_active_outlined,
                    color: const Color(0xFFD83A1E),
                    bgColor: const Color(0xFFFDE8E4),
                    onTap: () => onNavigateToTab(1),
                  ),
                  _buildStatCard(
                    title: 'Sedang Dimasak',
                    count: '$cookingCount',
                    icon: Icons.soup_kitchen_outlined,
                    color: Colors.orange.shade800,
                    bgColor: Colors.orange.shade50,
                    onTap: () => onNavigateToTab(1),
                  ),
                  _buildStatCard(
                    title: 'Sedang Dikirim',
                    count: '$deliveryCount',
                    icon: Icons.delivery_dining_outlined,
                    color: Colors.purple.shade700,
                    bgColor: Colors.purple.shade50,
                    onTap: () => onNavigateToTab(1),
                  ),
                  _buildStatCard(
                    title: 'Selesai',
                    count: '$completedCount',
                    icon: Icons.task_alt_rounded,
                    color: Colors.green.shade700,
                    bgColor: Colors.green.shade50,
                    onTap: () => onNavigateToTab(1),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Urgent Orders Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pesanan Membutuhkan Tindakan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onNavigateToTab(1),
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: Color(0xFFD83A1E),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (urgentOrders.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 40, color: Colors.green.shade400),
                      const SizedBox(height: 8),
                      const Text(
                        'Semua pesanan telah diproses!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: urgentOrders.take(3).length,
                  itemBuilder: (context, index) {
                    final order = urgentOrders[index];
                    return OrderCardWidget(
                      order: order,
                      onAccept: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pesanan berhasil diterima!'), backgroundColor: Colors.green),
                        );
                        onRefresh();
                      },
                      onPrint: () => PrintReceiptDialog.show(context, order),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return AnimatedTouchable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 18),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
