// Lokasi: lib/core/services/menu_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/food_model.dart';

class MenuService {
  // Setup Singleton biar class ini cuma dibikin 1 kali di memori
  static final MenuService instance = MenuService._internal();
  MenuService._internal();

  List<FoodModel> foods = [];
  List<FoodModel> drinks = [];
  List<FoodModel> desserts = [];
  List<FoodModel> recommended = [];
  
  bool isLoading = false;
  bool hasLoaded = false; // Penanda biar ga diload ulang

  Future<void> fetchMenu() async {
    if (hasLoaded || isLoading) return; 
    isLoading = true;

    try {
      final response = await Supabase.instance.client.from('menu_items').select();
      
      final List<FoodModel> allItems = (response as List).map((json) => FoodModel(
        id: json['id'],
        name: json['nama'],
        category: json['kategori'],
        price: json['harga'],
        time: '${json['lama_pembuatan_menit']} min',
        imagePath: json['image_url'],
        rating: (json['rating'] as num).toDouble(),
      )).toList();

      // Pisah-pisahin berdasarkan kategori
      foods = allItems.where((e) => e.category == 'food').toList();
      drinks = allItems.where((e) => e.category == 'drinks').toList();
      desserts = allItems.where((e) => e.category == 'dessert').toList();

      // Sort rating tertinggi buat ditampilin di Recommended (ambil 5 teratas)
      allItems.sort((a, b) => b.rating.compareTo(a.rating));
      recommended = allItems.take(5).toList();

      hasLoaded = true;
    } catch (e) {
      debugPrint('Error fetch menu: $e');
    } finally {
      isLoading = false;
    }
  }
}