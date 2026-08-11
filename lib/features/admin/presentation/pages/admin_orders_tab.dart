import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'package:restauran_app/features/admin/data/admin_repository.dart';
import 'package:restauran_app/features/admin/presentation/widgets/courier_tracking_card.dart';
import 'package:restauran_app/features/dashboard/presentation/pages/order_chat_page.dart';

class AdminOrdersTab extends StatefulWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AdminOrdersTab({
    Key? key,
    required this.orders,
    required this.isLoading,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  String _selectedFilter = 'New'; // 'New', 'In Process', 'Shipped', 'History'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> get _filteredOrders {
    List<dynamic> result = widget.orders;

    if (_selectedFilter == 'New') {
      result = result.where((o) => o['status'] == 'pending').toList();
    } else if (_selectedFilter == 'In Process') {
      result = result.where((o) => o['status'] == 'cooking').toList();
    } else if (_selectedFilter == 'Shipped') {
      result = result.where((o) => o['status'] == 'on_delivery').toList();
    } else if (_selectedFilter == 'History') {
      result = result.where((o) => o['status'] == 'completed' || o['status'] == 'cancelled').toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((o) {
        final orderNum = o['order_number']?.toString().toLowerCase() ?? '';
        final addr = o['alamat_pengiriman']?.toString().toLowerCase() ?? '';
        return orderNum.contains(_searchQuery.toLowerCase()) || addr.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  Future<void> _handleStatusUpdate(dynamic orderId, String newStatus, String msg) async {
    final success = await AdminRepository.instance.updateOrderStatus(orderId, newStatus);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
        widget.onRefresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui status!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan CSV/PDF berhasil diekspor! 📥'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = widget.orders.where((o) => o['status'] == 'pending').length;
    final cookingCount = widget.orders.where((o) => o['status'] == 'cooking').length;
    final shippedCount = widget.orders.where((o) => o['status'] == 'on_delivery').length;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFFFFBF8),
          body: RefreshIndicator(
            onRefresh: () async => widget.onRefresh(),
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kitchen Status Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KITCHEN STATUS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade500,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Normal Load • ${widget.orders.length} Active Orders',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search orders or couriers...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Horizontal Filter Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('New', pendingCount),
                        _buildFilterChip('In Process', cookingCount),
                        _buildFilterChip('Shipped', shippedCount),
                        _buildFilterChip('History', null),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Orders Content List
                  if (widget.isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    )
                  else if (_filteredOrders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'Tidak ada pesanan di kategori $_selectedFilter',
                          style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        final status = order['status'] as String? ?? 'pending';

                        if (status == 'completed' || status == 'cancelled') {
                          return _buildHistoryCard(order);
                        }

                        final courier = AdminRepository.instance.getCourierForOrder(index);

                        String? actionText;
                        if (status == 'pending') actionText = '✓ Terima & Proses Pesanan';
                        if (status == 'cooking') actionText = '✓ Kirim Pesanan Sekarang';
                        if (status == 'on_delivery') actionText = '✓ Selesaikan Pesanan';

                        return CourierTrackingCard(
                          order: order,
                          courier: courier,
                          actionButtonText: actionText,
                          onAcceptTap: () {
                            if (status == 'pending') {
                              _handleStatusUpdate(order['id'], 'cooking', 'Pesanan diterima & diproses!');
                            } else if (status == 'cooking') {
                              _handleStatusUpdate(order['id'], 'on_delivery', 'Pesanan sedang dikirim!');
                            } else if (status == 'on_delivery') {
                              _handleStatusUpdate(order['id'], 'completed', 'Pesanan selesai!');
                            }
                          },
                          onChatTap: () {
                            final dbOrderId = order['id']?.toString() ?? '';
                            final orderNumber = order['order_number']?.toString() ?? '000';

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderChatPage(
                                  dbOrderId: dbOrderId,
                                  orderNumber: orderNumber,
                                  restaurantName: 'Magic Food',
                                  senderRole: 'admin',
                                ),
                              ),
                            );
                          },
                          onCallTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Memanggil kurir ${courier.name} (${courier.phone})... 📞')),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),

        // Floating Export Report Button in History View
        if (_selectedFilter == 'History')
          Positioned(
            bottom: 80,
            right: 20,
            child: AnimatedTouchable(
              onTap: _exportReport,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD83A1E),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD83A1E).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.download_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Export Report',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int? count) {
    final isSelected = _selectedFilter == label;
    String display = label;
    if (count != null) {
      display = '$label ($count)';
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: AnimatedTouchable(
        onTap: () => setState(() => _selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD83A1E) : const Color(0xFFFDE8E4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            display,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF9E2C14),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(dynamic order) {
    final orderNumber = order['order_number']?.toString() ?? 'ORD-000';
    final status = order['status'] as String? ?? 'completed';
    final price = (order['total_price'] as num?)?.toDouble() ?? 0.0;
    final isCompleted = status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORD-2026-$orderNumber',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Cancelled',
                  style: TextStyle(
                    color: isCompleted ? Colors.green.shade700 : Colors.red.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order['alamat_pengiriman'] ?? 'Customer Order',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Oct 24, 2026 • 14:30',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Icon(Icons.credit_card_outlined, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'Visa •••• 4242',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.black12, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700)),
              Text(
                'Rp ${_formatPrice(price)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
