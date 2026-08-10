import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restauran_app/core/theme/app_colors.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  List<dynamic> _allOrders = [];
  RealtimeChannel? _ordersChannel;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // _listenForOrderChanges(); // <-- KITA MATIKAN DULU BIAR GAK BENTROK SAMA FETCH MANUAL
  }

  @override
  void dispose() {
    final channel = _ordersChannel;
    if (channel != null) {
      unawaited(Supabase.instance.client.removeChannel(channel));
    }
    super.dispose();
  }

  // --- FUNGSI AMBIL SEMUA ORDER DARI SUPABASE ---
  Future<void> _fetchOrders({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _allOrders = response as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('🚨 ERROR FETCH ADMIN ORDERS: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        // TAMPILIN ERROR DI LAYAR BIAR KITA TAU
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal tarik data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- FUNGSI UPDATE STATUS PESANAN ---
  Future<void> _updateOrderStatus(dynamic orderId, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status diupdate jadi: $newStatus'), backgroundColor: Colors.green),
        );
        _fetchOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal update status pesanan!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah yakin ingin keluar dari Admin Dashboard?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  List<dynamic> _filterOrders(List<String> statuses) {
    return _allOrders.where((order) => statuses.contains(order['status'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Admin Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.black), onPressed: _fetchOrders),
            IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.redAccent), onPressed: _logout),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Pesanan Baru'),
              Tab(text: 'Diproses'),
              Tab(text: 'Dikirim'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : TabBarView(
                children: [
                  _buildOrderList(_filterOrders(['pending']), 'Belum ada pesanan baru.'),
                  _buildOrderList(_filterOrders(['cooking']), 'Tidak ada pesanan diproses.'),
                  _buildOrderList(_filterOrders(['on_delivery']), 'Tidak ada pesanan dikirim.'),
                  _buildOrderList(_filterOrders(['completed', 'cancelled']), 'Riwayat kosong.'),
                ],
              ),
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _AdminOrderCard(
          order: order,
          onAccept: () => _updateOrderStatus(order['id'], 'cooking'),
          onReject: () => _updateOrderStatus(order['id'], 'cancelled'),
          onSend: () => _updateOrderStatus(order['id'], 'on_delivery'),
          onComplete: () => _updateOrderStatus(order['id'], 'completed'),
        );
      },
    );
  }
}

// ============================================================================
// WIDGET KARTU ORDER
// ============================================================================
class _AdminOrderCard extends StatelessWidget {
  final dynamic order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onSend;
  final VoidCallback onComplete;

  const _AdminOrderCard({
    Key? key,
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onSend,
    required this.onComplete,
  }) : super(key: key);

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status'];
    final items = order['order_items'] as List<dynamic>;
    
    // Cegah error kalau order_items kosong
    final itemDescriptions = items.isNotEmpty 
        ? items.map((i) => '${i['jumlah']}x ${i['nama_makanan']}').join(', ') 
        : 'Detail item tidak ditemukan';

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order['order_number']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(order['created_at'].toString().substring(0, 10), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Divider(height: 24),
          Text('Pesanan: $itemDescriptions', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Text('Alamat: ${order['alamat_pengiriman'] ?? '-'}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rp ${_formatPrice(order['total_price'])}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur chat segera hadir!'))),
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('Chat'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // LOGIC TOMBOL
          if (status == 'pending')
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: onAccept, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Terima', style: TextStyle(color: Colors.white)))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: onReject, style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text('Tolak'))),
            ])
          else if (status == 'cooking')
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onSend, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('Kirim Pesanan', style: TextStyle(color: Colors.white))))
          else if (status == 'on_delivery')
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onComplete, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Selesaikan', style: TextStyle(color: Colors.white))))
          else
            Center(child: Text(status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: status == 'completed' ? Colors.green : Colors.red))),
        ],
      ),
    );
  }
}