import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/services/cart_service.dart';
import 'package:restauran_app/core/services/language_service.dart';
import 'package:restauran_app/core/services/notification_service.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'package:restauran_app/features/dashboard/presentation/pages/delivery_address_page.dart';
import 'package:restauran_app/features/cart/presentation/widgets/cart_empty_state.dart';
import 'package:restauran_app/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:restauran_app/features/cart/presentation/widgets/voucher_bottom_sheet.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isCheckingOut = false;

  String? _selectedAddress;
  String? _selectedAddressLabel;

  VoucherItem? _appliedVoucher;

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

  void _openVoucherModal() async {
    final subtotal = CartService.instance.totalPrice;
    final VoucherItem? selected = await showModalBottomSheet<VoucherItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => VoucherBottomSheet(
        currentSubtotal: subtotal,
        appliedVoucherCode: _appliedVoucher?.code,
      ),
    );

    if (selected != null) {
      setState(() {
        _appliedVoucher = selected;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${LanguageService.instance.tr('voucher_applied')} (${selected.code})'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- FUNGSI MANGGIL API MIDTRANS ---
  Future<void> _payWithMidtrans(String orderNumber, int grossAmount) async {
    final String serverKey = dotenv.env['MIDTRANS_SERVER_KEY'] ?? '';
    final basicAuth = base64Encode(utf8.encode('$serverKey:'));

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

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final redirectUrl = responseData['redirect_url'];
        await launchUrl(Uri.parse(redirectUrl), mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Midtrans Error: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _checkout() async {
    final lang = LanguageService.instance;
    if (CartService.instance.items.isEmpty || _isCheckingOut) return;

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.tr('select_address')), backgroundColor: Colors.red),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isCheckingOut = true);
    final supabase = Supabase.instance.client;
    final cartItems = CartService.instance.items;

    final subtotal = CartService.instance.totalPrice;
    final discount = _appliedVoucher?.calculateDiscount(subtotal) ?? 0;
    final finalPrice = (subtotal - discount).clamp(0, double.infinity).toInt();

    final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final fullDeliveryAddress = '$_selectedAddressLabel - $_selectedAddress';

    dynamic orderId;

    try {
      // 1. INSERT ORDERS
      final orderResponse = await supabase.from('orders').insert({
        'user_id': user.id,
        'order_number': orderNumber,
        'status': 'pending',
        'total_price': finalPrice,
        'catatan': _appliedVoucher != null ? 'Voucher: ${_appliedVoucher!.code}' : '',
        'alamat_pengiriman': fullDeliveryAddress,
      }).select('id').single();

      orderId = orderResponse['id'];

      // 2. INSERT ORDER ITEMS
      final List<Map<String, dynamic>> orderItemsData = cartItems.map((item) {
        return {
          'order_id': orderId.toString(),
          'menu_item_id': item.food.id.toString(),
          'nama_makanan': item.food.name.toString(),
          'kategori': item.food.category,
          'harga_satuan': item.food.price,
          'jumlah': item.quantity,
          'subtotal': (item.food.price * item.quantity).toInt(),
        };
      }).toList();

      await supabase.from('order_items').insert(orderItemsData);

      // 3. MIDTRANS PAYMENT
      await _payWithMidtrans(orderNumber, finalPrice);

      // 4. NOTIFICATION & CLEAR CART
      NotificationService.instance.addNotification(
        title: 'Pesanan Dibuat (#$orderNumber)',
        body: 'Pesanan sebesar Rp ${_formatPrice(finalPrice)} sedang diproses oleh restoran.',
        type: 'order',
      );

      setState(() {
        CartService.instance.clearCart();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.tr('checkout_success')), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses pesanan.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final cartItems = CartService.instance.items;

    final subtotal = CartService.instance.totalPrice;
    final discount = _appliedVoucher?.calculateDiscount(subtotal) ?? 0;
    final finalTotal = (subtotal - discount).clamp(0, double.infinity);

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAF8F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(lang.tr('my_cart'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: cartItems.isEmpty
              ? const CartEmptyState()
              : Column(
                  children: [
                    // Delivery Address Card
                    AnimatedTouchable(
                      onTap: _selectDeliveryAddress,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.location_on_rounded, color: AppColors.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedAddressLabel ?? lang.tr('select_address'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: _selectedAddress == null ? Colors.red : Colors.black87,
                                    ),
                                  ),
                                  if (_selectedAddress != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _selectedAddress!,
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    // Voucher Selection Card
                    AnimatedTouchable(
                      onTap: _openVoucherModal,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _appliedVoucher != null ? AppColors.primary.withOpacity(0.06) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _appliedVoucher != null ? AppColors.primary : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _appliedVoucher != null
                                    ? 'Voucher: ${_appliedVoucher!.code} (-Rp ${_formatPrice(discount)})'
                                    : lang.tr('use_voucher'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _appliedVoucher != null ? AppColors.primary : Colors.black87,
                                ),
                              ),
                            ),
                            if (_appliedVoucher != null)
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                                onPressed: () => setState(() => _appliedVoucher = null),
                              )
                            else
                              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    // Items List
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

          // Footer Checkout
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
                        // Subtotal & Discount summary
                        if (_appliedVoucher != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(lang.tr('subtotal'), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              Text('Rp ${_formatPrice(subtotal)}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(lang.tr('discount'), style: TextStyle(fontSize: 14, color: AppColors.primary)),
                              Text('-Rp ${_formatPrice(discount)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          const Divider(height: 16),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${lang.tr('total')} (${CartService.instance.totalItems} items)',
                              style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Rp ${_formatPrice(finalTotal)}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedTouchable(
                            onTap: _isCheckingOut ? null : _checkout,
                            child: ElevatedButton(
                              onPressed: _isCheckingOut ? null : _checkout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 2,
                              ),
                              child: _isCheckingOut
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.payment_rounded, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          lang.tr('pay_midtrans'),
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    ),
                            ),
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
}