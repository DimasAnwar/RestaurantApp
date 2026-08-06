class FoodModel {
  final String imagePath;
  final String name;
  final String category;
  final String time;
  final int price;

  FoodModel({
    required this.imagePath,
    required this.name,
    required this.category,
    required this.time,
    required this.price,
  });
}

List<FoodModel> dummyFoods = [
  FoodModel(
    imagePath: "assets/images/sate.jpg",
    name: "Sate Ayam",
    category: "Indonesian Food",
    time: "30 Min",
    price: 20000,
  ),
  FoodModel(
    imagePath: "assets/images/promo1.jpg",
    name: "Truffle Pasta",
    category: "Italian Food",
    time: "25 Min",
    price: 45000,
  ),
  FoodModel(
    imagePath: "assets/images/sate.jpg",
    name: "Nasi Goreng",
    category: "Indonesian Food",
    time: "15 Min",
    price: 25000,
  ),
];
