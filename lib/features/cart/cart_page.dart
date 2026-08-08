import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import '../../core/services/cart_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // --- FUNGSI HELPER BUAT FORMAT HARGA (Misal: 25000 -> 25.000) ---
  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
  bool _isCheckingOut = false;
  Future<void> _checkout() async {
    if (CartService.instance.items.isEmpty || _isCheckingOut) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Sesi login tidak ditemukan.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final cartItems = CartService.instance.items;
      final totalPrice = CartService.instance.totalPrice.toInt();

      // 1. Generate Order Number unik (Pake waktu biar ga bentrok)
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      // 2. Insert ke tabel orders dan ambil ID-nya
      final orderResponse = await supabase.from('orders').insert({
        'user_id': user.id,
        'order_number': orderNumber,
        'status': 'pending',
        'total_price': totalPrice,
        'catatan': '', // Kosongin dulu, atau nanti lu bisa tambahin text field notes
      }).select('id').single();

      final orderId = orderResponse['id'];

      // 3. Siapin data order_items (detail makanannya)
      final List<Map<String, dynamic>> orderItemsData = cartItems.map((item) {
        return {
          'order_id': orderId,
          'menu_item_id': item.food.id,
          'nama_makanan': item.food.name,
          'kategori': item.food.category,
          'harga_satuan': item.food.price,
          'jumlah': item.quantity,
          'subtotal': item.food.price * item.quantity,
        };
      }).toList();

      // 4. Insert ke tabel order_items sekalian banyak (bulk insert)
      await supabase.from('order_items').insert(orderItemsData);

      // 5. Kalau sukses, bersihin keranjang
      setState(() {
        CartService.instance.clearCart();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checkout Berhasil! Pesanan sedang disiapkan.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Balik ke OrderPage dan kirim sinyal refresh
      }

    } catch (e) {
      debugPrint('Error Checkout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal melakukan checkout, coba lagi.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartService.instance.items;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState() // Muncul kalau keranjang kosong
          : ListView.separated(
              padding: const EdgeInsets.all(24.0),
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // --- GAMBAR MAKANAN ---
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(item.food.imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // --- INFO MAKANAN & TOMBOL ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.food.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // HARGA SUDAH DI FORMAT PAKAI TITIK
                            Text(
                              'Rp ${_formatPrice(item.food.price)}',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            
                            // --- CONTROLLER PLUS MINUS & DELETE ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Wadah Plus Minus
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildQtyButton(Icons.remove, () {
                                        setState(() {
                                          CartService.instance.decreaseQuantity(item);
                                        });
                                      }),
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          '${item.quantity}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ),
                                      _buildQtyButton(Icons.add, () {
                                        setState(() {
                                          CartService.instance.increaseQuantity(item);
                                        });
                                      }),
                                    ],
                                  ),
                                ),
                                
                                // Tombol Tong Sampah (Delete)
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      CartService.instance.removeItem(item);
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
      // --- FOOTER CHECKOUT AREA ---
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total (${CartService.instance.totalItems} items)',
                          style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        // TOTAL HARGA JUGA DI FORMAT PAKAI TITIK
                        Text(
                          'Rp ${_formatPrice(CartService.instance.totalPrice)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // Kalau lagi checkout, tombolnya di-disable (kasih null)
                        onPressed: _isCheckingOut ? null : _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        // Tunjukin loading kalau lagi proses
                        child: _isCheckingOut 
                          ? const SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Checkout Now',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- UI EMPTY STATE KALAU KERANJANG KOSONG ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Keranjang Masih Kosong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih menu favoritmu dan\nnikmati makanan lezat hari ini!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Mulai Belanja', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- WIDGET TOMBOL PLUS MINUS ---
  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}