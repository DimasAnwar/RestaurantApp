import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/models/food_model.dart';
import 'package:restauran_app/core/models/order_model.dart';
import 'package:restauran_app/core/services/cart_service.dart';
import 'package:restauran_app/core/services/language_service.dart';
import 'package:restauran_app/core/services/notification_service.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'package:restauran_app/features/cart/presentation/pages/cart_page.dart';
import 'order_tracking_page.dart';

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

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      List<OrderData> active = [];
      List<OrderData> past = [];
      final lang = LanguageService.instance;

      for (var json in response) {
        final rawStatus = json['status'] as String;
        final isActive = ['pending', 'cooking', 'on_delivery'].contains(rawStatus);

        final items = json['order_items'] as List<dynamic>? ?? [];
        final itemNames = items.map((e) => e['nama_makanan']).toList();
        final description = itemNames.join(', ');

        final orderData = OrderData(
          dbOrderId: json['id']?.toString() ?? '',
          restaurantName: 'Magic Food',
          date: _formatDate(json['created_at']),
          orderId: json['order_number'],
          rawStatus: rawStatus,
          status: _formatStatus(rawStatus, lang),
          isActive: isActive,
          itemCount: items.fold<int>(0, (sum, item) => sum + (item['jumlah'] as int)),
          itemDescription: description.isEmpty ? 'Custom Order' : description,
          price: (json['total_price'] as num).toDouble(),
          buttonText: isActive ? lang.tr('track_order') : lang.tr('reorder'),
          hasStarButton: !isActive,
          rawItems: items,
          shippingAddress: json['alamat_pengiriman']?.toString() ?? 'Jl. Pajajaran No. 45, Bogor',
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

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  String _formatStatus(String status, LanguageService lang) {
    switch (status) {
      case 'pending':
        return lang.tr('status_pending');
      case 'cooking':
        return lang.tr('status_cooking');
      case 'on_delivery':
        return lang.tr('status_on_delivery');
      case 'completed':
        return lang.tr('status_completed');
      case 'cancelled':
        return lang.tr('status_cancelled');
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFFAF8F5),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopHeader(onRefreshOrders: _fetchOrders),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    child: Text(
                      lang.tr('order'),
                      style: const TextStyle(
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
                      tabs: [
                        Tab(text: lang.tr('active_orders')),
                        Tab(text: lang.tr('past_orders')),
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
      },
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
        return _OrderCard(
          data: orders[index],
          onRefresh: _fetchOrders,
        );
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
    setState(() {});
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
          AnimatedTouchable(
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
  final VoidCallback onRefresh;

  const _OrderCard({Key? key, required this.data, required this.onRefresh}) : super(key: key);

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  void _handleAction(BuildContext context) async {
    if (data.isActive) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingPage(orderData: data),
        ),
      );
      if (result == true) {
        onRefresh();
      }
    } else {
      for (var item in data.rawItems) {
        int id = int.tryParse(item['menu_item_id']?.toString() ?? '0') ?? 0;
        FoodModel food = FoodModel(
          id: id,
          name: item['nama_makanan'] ?? 'Food Item',
          category: item['kategori'] ?? 'Food',
          price: (item['harga_satuan'] as num).toInt(),
          time: '15 min',
          imagePath: 'assets/images/sate.jpg',
          rating: 4.8,
        );
        int qty = (item['jumlah'] as num?)?.toInt() ?? 1;
        for (int i = 0; i < qty; i++) {
          CartService.instance.addToCart(food);
        }
      }

      NotificationService.instance.addNotification(
        title: 'Pesanan Diulang!',
        body: 'Item dari pesanan #${data.orderId} telah dimasukkan ke keranjang belanja.',
        type: 'order',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageService.instance.tr('reorder_added')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTouchable(
      onTap: () => _handleAction(context),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                    color: data.isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey[200],
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
                  child: AnimatedTouchable(
                    onTap: () => _handleAction(context),
                    child: OutlinedButton(
                      onPressed: () => _handleAction(context),
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
      ),
    );
  }
}