import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._internal();
  LanguageService._internal();

  String _currentLanguage = 'id'; // Default Indonesian

  String get currentLanguage => _currentLanguage;
  bool get isIndonesian => _currentLanguage == 'id';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'id';
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    if (_currentLanguage == langCode) return;
    _currentLanguage = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', langCode);
    notifyListeners();
  }

  // Translation Dictionary
  static final Map<String, Map<String, String>> _localizedValues = {
    'id': {
      // General & Nav
      'home': 'Beranda',
      'order': 'Pesanan',
      'cart': 'Keranjang',
      'profile': 'Profil',
      'settings': 'Pengaturan',
      'search': 'Cari makanan...',
      'recommended': 'Rekomendasi',
      'categories': 'Kategori',
      'all': 'Semua',
      'food': 'Makanan',
      'drinks': 'Minuman',
      'dessert': 'Penutup',

      // Settings & Profile
      'account_details': 'Detail Akun',
      'notifications': 'Notifikasi',
      'language': 'Bahasa',
      'privacy_security': 'Privasi & Keamanan',
      'logout': 'Keluar',
      'logout_confirm': 'Apakah Anda yakin ingin keluar dari akun ini?',
      'cancel': 'Batal',
      'save': 'Simpan',
      'edit_profile': 'Edit Profil',
      'username': 'Nama Pengguna',
      'email': 'Email',
      'phone': 'Nomor Telepon',
      'role': 'Peran Akun',
      'profile_updated': 'Profil berhasil diperbarui!',
      'order_history': 'Riwayat Pesanan',
      'delivery_addresses': 'Alamat Pengiriman',
      'available_points': 'Poin Tersedia',
      'pts_to_next': 'pts menuju',
      'redeem': 'Tukar Poin',

      // Notifications
      'notification_settings': 'Pengaturan Notifikasi HP',
      'sync_system_notification': 'Ikuti Pengaturan Notifikasi HP',
      'system_noti_desc': 'Notifikasi aplikasi disesuaikan dengan izin notifikasi perangkat Android/iOS Anda.',
      'notifications_empty': 'Belum ada notifikasi.',
      'mark_all_read': 'Tandai Semua Dibaca',

      // Cart & Checkout & Voucher
      'my_cart': 'Keranjang Saya',
      'select_address': 'Pilih Alamat Pengiriman',
      'voucher_promo': 'Voucher & Promo',
      'use_voucher': 'Gunakan Voucher',
      'enter_voucher_code': 'Masukkan Kode Voucher',
      'apply': 'Gunakan',
      'voucher_applied': 'Voucher berhasil dipasang!',
      'voucher_invalid': 'Kode voucher tidak valid',
      'discount': 'Diskon',
      'subtotal': 'Subtotal',
      'total': 'Total',
      'pay_midtrans': 'Bayar dengan Midtrans',
      'checkout_success': 'Pesanan berhasil dibuat!',
      'cart_empty': 'Keranjang belanjaanmu kosong',

      // Order & Tracking & Reorder
      'active_orders': 'Pesanan Aktif',
      'past_orders': 'Riwayat Pesanan',
      'reorder': 'Pesan Ulang',
      'track_order': 'Lacak Pesanan',
      'complete_order': 'Selesaikan Pesanan',
      'order_completed_msg': 'Pesanan Selesai! Poin kamu telah bertambah.',
      'reorder_added': 'Item dari pesanan sebelumnya telah dimasukkan ke keranjang!',
      'status_pending': 'Menunggu',
      'status_cooking': 'Sedang Dimasak',
      'status_on_delivery': 'Diperjalanan',
      'status_completed': 'Selesai',
      'status_cancelled': 'Dibatalkan',

      // Rating
      'rating': 'Rating',
    },
    'en': {
      // General & Nav
      'home': 'Home',
      'order': 'Orders',
      'cart': 'Cart',
      'profile': 'Profile',
      'settings': 'Settings',
      'search': 'Search food...',
      'recommended': 'Recommended',
      'categories': 'Categories',
      'all': 'All',
      'food': 'Food',
      'drinks': 'Drinks',
      'dessert': 'Dessert',

      // Settings & Profile
      'account_details': 'Account Details',
      'notifications': 'Notifications',
      'language': 'Language',
      'privacy_security': 'Privacy & Security',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to log out of this account?',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit_profile': 'Edit Profile',
      'username': 'Username',
      'email': 'Email',
      'phone': 'Phone Number',
      'role': 'Account Role',
      'profile_updated': 'Profile updated successfully!',
      'order_history': 'Order History',
      'delivery_addresses': 'Delivery Addresses',
      'available_points': 'Available Points',
      'pts_to_next': 'pts to',
      'redeem': 'Redeem',

      // Notifications
      'notification_settings': 'Device Notification Settings',
      'sync_system_notification': 'Sync with HP Notification Settings',
      'system_noti_desc': 'App notifications follow your Android/iOS system permission settings.',
      'notifications_empty': 'No notifications yet.',
      'mark_all_read': 'Mark All as Read',

      // Cart & Checkout & Voucher
      'my_cart': 'My Cart',
      'select_address': 'Select Delivery Address',
      'voucher_promo': 'Vouchers & Promos',
      'use_voucher': 'Use Voucher',
      'enter_voucher_code': 'Enter Voucher Code',
      'apply': 'Apply',
      'voucher_applied': 'Voucher applied successfully!',
      'voucher_invalid': 'Invalid voucher code',
      'discount': 'Discount',
      'subtotal': 'Subtotal',
      'total': 'Total',
      'pay_midtrans': 'Pay with Midtrans',
      'checkout_success': 'Order placed successfully!',
      'cart_empty': 'Your cart is empty',

      // Order & Tracking & Reorder
      'active_orders': 'Active Orders',
      'past_orders': 'Past Orders',
      'reorder': 'Reorder',
      'track_order': 'Track Order',
      'complete_order': 'Complete Order',
      'order_completed_msg': 'Order completed! You have earned points.',
      'reorder_added': 'Items from previous order added to cart!',
      'status_pending': 'Pending',
      'status_cooking': 'Cooking',
      'status_on_delivery': 'On Delivery',
      'status_completed': 'Completed',
      'status_cancelled': 'Cancelled',

      // Rating
      'rating': 'Rating',
    }
  };

  String tr(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? _localizedValues['id']?[key] ?? key;
  }
}
