import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/cart_service.dart';
import '../../../cart/presentation/pages/cart_page.dart'; // Sesuaikan path ini kalau error
import 'order_tracking_page.dart';


class OrderData {
  final String restaurantName;
  final String date;
  final String orderId;
  final String status;
  final bool isActive;
  final int itemCount;
  final String itemDescription;
  final double price;
  final String buttonText;
  final bool hasStarButton;

  OrderData({
    required this.restaurantName,
    required this.date,
    required this.orderId,
    required this.status,
    required this.isActive,
    required this.itemCount,
    required this.itemDescription,
    required this.price,
    required this.buttonText,
    this.hasStarButton = false,
  });
}

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool _isLoading = true;
  List<OrderData> _activeOrders = [];
  List<OrderData> _pastOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // --- FUNGSI TARIK DATA TRANSAKSI DARI SUPABASE ---
  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // Narik tabel orders sekaligus detail order_items-nya
      final response = await Supabase.instance.client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      List<OrderData> active = [];
      List<OrderData> past = [];

      for (var json in response) {
        final rawStatus = json['status'] as String;
        final isActive = ['pending', 'cooking', 'on_delivery'].contains(rawStatus);
        
        final items = json['order_items'] as List<dynamic>;
        
        // Gabungin nama-nama item buat deskripsi (Misal: "Nasi Goreng, Es Teh...")
        final itemNames = items.map((e) => e['nama_makanan']).toList();
        final description = itemNames.join(', ');

        final orderData = OrderData(
          restaurantName: 'Magic Food', // Default sesuai request lu
          date: _formatDate(json['created_at']),
          orderId: json['order_number'],
          status: _formatStatus(rawStatus),
          isActive: isActive,
          itemCount: items.fold<int>(0, (sum, item) => sum + (item['jumlah'] as int)),
          itemDescription: description.isEmpty ? 'Custom Order' : description,
          price: (json['total_price'] as num).toDouble(),
          buttonText: isActive ? 'Track Order' : 'Reorder',
          hasStarButton: !isActive,
        );

        if (isActive) {
          active.add(orderData);
        } else {
          past.add(orderData);
        }
      }

      if (mounted) {
        setState(() {
          _activeOrders = active;
          _pastOrders = past;
        });
      }
    } catch (e) {
      debugPrint('Error fetch orders: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HELPER BUAT FORMAT TANGGAL ---
  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString).toLocal();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // --- HELPER BUAT FORMAT STATUS TRANSLATE KE INDO ---
  String _formatStatus(String status) {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'cooking': return 'Sedang Dimasak';
      case 'on_delivery': return 'Diperjalanan';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F5),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopHeader(onRefreshOrders: _fetchOrders),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Text(
                  'Orders',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A5A5A),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black12, width: 1.5),
                  ),
                ),
                child: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Past Orders'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : TabBarView(
                        children: [
                          _buildOrderList(_activeOrders, 'Belum ada pesanan aktif nih.'),
                          _buildOrderList(_pastOrders, 'Belum ada riwayat pesanan.'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderData> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _OrderCard(data: orders[index]);
      },
    );
  }
}

class _TopHeader extends StatefulWidget {
  final VoidCallback onRefreshOrders;

  const _TopHeader({Key? key, required this.onRefreshOrders}) : super(key: key);

  @override
  State<_TopHeader> createState() => _TopHeaderState();
}

class _TopHeaderState extends State<_TopHeader> {
  void _goToCart() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
    );
    // Refresh badge keranjang
    setState(() {});
    
    // Kalau result-nya true (artinya user abis checkout), refresh data order
    if (result == true) {
      widget.onRefreshOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    int cartCount = CartService.instance.totalItems;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Current Location',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _goToCart,
            child: Badge(
              isLabelVisible: cartCount > 0,
              label: Text(
                cartCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: Colors.red,
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderData data;
  const _OrderCard({Key? key, required this.data}) : super(key: key);

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[100],
                radius: 20,
                child: const Icon(Icons.storefront_outlined, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.restaurantName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.date} • ${data.orderId}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: data.isActive ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  data.status,
                  style: TextStyle(
                    color: data.isActive ? AppColors.primary : Colors.grey[700],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.black12, height: 1),
          ),
          
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fastfood_outlined, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.itemCount} items',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.itemDescription,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // PERUBAHAN: Format Harga ke Rupiah
              Text(
                'Rp ${_formatPrice(data.price)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  // --- UBAH BAGIAN INI ---
                  onPressed: () {
                    if (data.isActive) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderTrackingPage(orderData: data),
                        ),
                      );
                    }
                  },
                  // -----------------------
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    data.buttonText,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              if (data.hasStarButton) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black12),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.star_outline_rounded, size: 20),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}