import 'package:flutter/material.dart';
import '../models/food_model.dart';

class CartItem {
  final FoodModel food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

class CartService {
  static final CartService instance = CartService._internal();
  CartService._internal();

  List<CartItem> items = [];

  // Hitung total item dalam keranjang (buat badge angka)
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Hitung total harga
  double get totalPrice => items.fold(0, (sum, item) => sum + (item.food.price * item.quantity));

  void clearCart() {
    items.clear();
  }

  // Tambahin fungsi ini di dalam class CartService
  void addToCart(FoodModel food) {
    // Cek apakah makanan udah ada di keranjang
    final existingIndex = items.indexWhere((item) => item.food.id == food.id);
    
    if (existingIndex >= 0) {
      // Kalau udah ada, tambah jumlahnya aja
      items[existingIndex].quantity += 1;
    } else {
      // Kalau belum ada, masukin sebagai item baru
      items.add(CartItem(food: food, quantity: 1));
    }
  }
  // --- FUNGSI BARU BUAT CART PAGE ---
  void increaseQuantity(CartItem item) {
    item.quantity++;
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      items.remove(item); // Kalau jumlahnya 1 terus dikurangin, otomatis kehapus
    }
  }

  void removeItem(CartItem item) {
    items.remove(item);
  }
}