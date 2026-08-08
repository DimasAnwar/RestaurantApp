// Lokasi: lib/core/models/food_model.dart
class FoodModel {
  final int? id;
  final String imagePath;
  final String name;
  final String category;
  final String time;
  final int price;
  final double rating;

  FoodModel({
    this.id,
    required this.imagePath,
    required this.name,
    required this.category,
    required this.time,
    required this.price,
    this.rating = 0.0,
  });
}