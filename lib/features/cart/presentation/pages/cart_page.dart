import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:restauran_app/core/theme/app_colors.dart';
import '../../../../core/services/cart_service.dart';
import '../../../dashboard/presentation/pages/delivery_address_page.dart'; // Sesuaikan path
import 'package:restauran_app/features/cart/presentation/widgets/cart_empty_state.dart'; 
import 'package:restauran_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isCheckingOut = false;
  
  String? _selectedAddress;
  String? _selectedAddressLabel;

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  Future<void> _selectDeliveryAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeliveryAddressPage()),
    );

    if (result != null && result is Map) {
      setState(() {
        _selectedAddressLabel = result['label'];
        _selectedAddress = result['address'];
      });
    }
  }

  // --- FUNGSI MANGGIL API MIDTRANS ---
  Future<void> _payWithMidtrans(String orderNumber, int grossAmount) async {
    final String serverKey = dotenv.env['MIDTRANS_SERVER_KEY']?? ''; 
    final basicAuth = base64Encode(utf8.encode('$serverKey:'));

    debugPrint("--- MIDTRANS REQUEST START ---");
    debugPrint("Order ID: $orderNumber");
    debugPrint("Amount: $grossAmount");

    try {
      final response = await http.post(
        Uri.parse('https://app.sandbox.midtrans.com/snap/v1/transactions'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $basicAuth',
        },
        body: jsonEncode({
          'transaction_details': {
            'order_id': orderNumber,
            'gross_amount': grossAmount,
          },
          'customer_details': {
            'first_name': Supabase.instance.client.auth.currentUser?.userMetadata?['username'] ?? 'User',
            'email': Supabase.instance.client.auth.currentUser?.email ?? 'user@example.com',
          }
        }),
      );

      // --- INI KUNCI BUAT TAU ERRORNYA ---
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final redirectUrl = responseData['redirect_url'];
        await launchUrl(Uri.parse(redirectUrl), mode: LaunchMode.externalApplication);
      } else {
        // Kalau error, lu bakal liat pesannya di debug console
        debugPrint("ERROR MIDTRANS: ${response.body}");
        throw Exception('Midtrans Error: ${response.body}');
      }
    } catch (e) {
      debugPrint("CATCH ERROR: $e");
      rethrow;
    }
  }

  // --- FUNGSI CHECKOUT VERSI INVESTIGASI ---
  Future<void> _checkout() async {
    if (CartService.instance.items.isEmpty || _isCheckingOut) return;

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat pengiriman dulu ya!'), backgroundColor: Colors.red),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isCheckingOut = true);
    final supabase = Supabase.instance.client;
    final cartItems = CartService.instance.items;
    final totalPrice = CartService.instance.totalPrice.toInt();
    final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final fullDeliveryAddress = '$_selectedAddressLabel - $_selectedAddress';
    
    dynamic orderId; // Buat nyimpen ID order

    debugPrint("\n========== PROSES CHECKOUT DIMULAI ==========");

    // ==========================================
    // STEP 1: INSERT KE TABEL ORDERS
    // ==========================================
    try {
      debugPrint("STEP 1: Menyimpan ke tabel 'orders'...");
      final orderResponse = await supabase.from('orders').insert({
        'user_id': user.id,
        'order_number': orderNumber,
        'status': 'pending', 
        'total_price': totalPrice,
        'catatan': '', 
        'alamat_pengiriman': fullDeliveryAddress,
      }).select('id').single();

      orderId = orderResponse['id'];
      debugPrint("✅ STEP 1 SUKSES! Order ID: $orderId");
    } catch (e) {
      debugPrint("🚨 GAGAL DI STEP 1 (TABEL ORDERS): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat pesanan (Step 1)'), backgroundColor: Colors.red));
        setState(() => _isCheckingOut = false);
      }
      return; // BERHENTI DI SINI KALAU GAGAL
    }

    // ==========================================
    // STEP 2: INSERT KE TABEL ORDER_ITEMS
    // ==========================================
    try {
      debugPrint("STEP 2: Menyimpan detail makanan ke 'order_items'...");
      final List<Map<String, dynamic>> orderItemsData = cartItems.map((item) {
        return {
          'order_id': orderId.toString(),
          'menu_item_id': item.food.id.toString(), 
          'nama_makanan': item.food.name.toString(), 
          'kategori': item.food.category?.toString() ?? 'Lainnya', 
          'harga_satuan': (item.food.price).toInt(), 
          'jumlah': (item.quantity).toInt(), 
          'subtotal': (item.food.price * item.quantity).toInt(),
        };
      }).toList();

      await supabase.from('order_items').insert(orderItemsData);
      debugPrint("✅ STEP 2 SUKSES! Detail makanan tersimpan.");
    } catch (e) {
      debugPrint("🚨 GAGAL DI STEP 2 (TABEL ORDER ITEMS): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan detail makanan (Step 2)'), backgroundColor: Colors.red));
        setState(() => _isCheckingOut = false);
      }
      return; // BERHENTI DI SINI KALAU GAGAL
    }

    // ==========================================
    // STEP 3: TEMBAK MIDTRANS
    // ==========================================
    try {
      debugPrint("STEP 3: Membuka Midtrans...");
      await _payWithMidtrans(orderNumber, totalPrice);
      debugPrint("✅ STEP 3 SUKSES!");

      // 4. Bersihkan keranjang
      setState(() {
        CartService.instance.clearCart();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      debugPrint("🚨 GAGAL DI STEP 3 (MIDTRANS): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses pembayaran (Step 3).'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
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
        title: const Text('My Cart', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? const CartEmptyState() // Manggil widget yang udah dipecah
          : Column(
              children: [
                // --- KARTU PEMILIHAN ALAMAT ---
                GestureDetector(
                  onTap: _selectDeliveryAddress,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.location_on_rounded, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedAddressLabel ?? 'Pilih Alamat Pengiriman',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15,
                                  color: _selectedAddress == null ? Colors.red : Colors.black87,
                                ),
                              ),
                              if (_selectedAddress != null) ...[
                                const SizedBox(height: 4),
                                Text(_selectedAddress!, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ]
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                // --- DAFTAR ITEM KERANJANG (Dipecah pakai CartItemCard) ---
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        item: item,
                        onIncrease: () => setState(() => CartService.instance.increaseQuantity(item)),
                        onDecrease: () => setState(() => CartService.instance.decreaseQuantity(item)),
                        onRemove: () => setState(() => CartService.instance.removeItem(item)),
                      );
                    },
                  ),
                ),
              ],
            ),
            
      // --- FOOTER CHECKOUT AREA ---
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total (${CartService.instance.totalItems} items)', style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600)),
                        Text('Rp ${_formatPrice(CartService.instance.totalPrice)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCheckingOut ? null : _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: _isCheckingOut 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payment_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Bayar dengan Midtrans', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
}