import 'package:flutter/material.dart';
// Pastikan import ini mengarah ke file tema global kamu
import 'package:restauran_app/core/theme/app_colors.dart'; 

// -------------------------------------------------------------------------
// MODEL DATA (dummy)
// -------------------------------------------------------------------------
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

// -------------------------------------------------------------------------
// MAIN ORDER PAGE
// -------------------------------------------------------------------------
class OrderPage extends StatelessWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data Dummy
    final List<OrderData> activeOrders = [
      OrderData(
        restaurantName: 'Artisan Coffee Co.',
        date: 'Today, 09:42 AM',
        orderId: '#AC-8921',
        status: 'On the way',
        isActive: true,
        itemCount: 2,
        itemDescription: 'Flat White, Avocado Toast',
        price: 24.50,
        buttonText: 'Track Order',
      ),
      OrderData(
        restaurantName: 'Green Bowl Eatery',
        date: 'Today, 12:15 PM',
        orderId: '#GB-4019',
        status: 'In Kitchen',
        isActive: true,
        itemCount: 1,
        itemDescription: 'Superfood Quinoa Bowl',
        price: 18.00,
        buttonText: 'View Details',
      ),
    ];

    final List<OrderData> pastOrders = [
      OrderData(
        restaurantName: 'Koyo Sushi',
        date: 'Yesterday, 07:30 PM',
        orderId: '#KS-9920',
        status: 'Delivered',
        isActive: false,
        itemCount: 3,
        itemDescription: 'Spicy Tuna Roll, Edamame...',
        price: 42.00,
        buttonText: 'Reorder',
        hasStarButton: true,
      ),
    ];

    return DefaultTabController(
      length: 2, // Jumlah Tab
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F5), // Warna background krem muda
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopHeader(),
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
              // Tab Bar Section
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
              // Tab Bar View (Konten yang bisa di-swipe/klik)
              Expanded(
                child: TabBarView(
                  children: [
                    // Tampilan List Tab Active
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      itemCount: activeOrders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _OrderCard(data: activeOrders[index]);
                      },
                    ),
                    // Tampilan List Tab Past Orders
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      itemCount: pastOrders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _OrderCard(data: pastOrders[index]);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// WIDGET KOMPONEN
// -------------------------------------------------------------------------

class _TopHeader extends StatelessWidget {
  const _TopHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.tune_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderData data;
  const _OrderCard({Key? key, required this.data}) : super(key: key);

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
          // Bagian Atas: Logo, Nama Resto, Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[100],
                radius: 20,
                // Placeholder logo restoran
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
                      '${data.date} • ID: ${data.orderId}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Status Badge
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
          
          // Bagian Tengah: Detail Item
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  // Ganti dengan NetworkImage/AssetImage asli nantinya
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
                '\$${data.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bagian Bawah: Tombol Aksi
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
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