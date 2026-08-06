import 'package:flutter/material.dart';
// Import file custom card lu
import '../../../../core/widgets/food_card.dart';
// Import model lu
import '../../../../core/models/food_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // -------------------------------------------------------------------------
  // DUMMY DATA
  // Sesuai dengan properti yang dipanggil di FoodCard lu
  // -------------------------------------------------------------------------
  final List<FoodModel> dummyFoods = [
    FoodModel(
      imagePath: 'assets/images/sate.jpg', // Ganti dengan asset lu
      name: 'Spicy Burger',
      category: 'Fast Food',
      time: '15 min',
      price: 35000,
    ),
    FoodModel(
      imagePath: 'assets/images/sate.jpg',
      name: 'Nasi Goreng Spesial',
      category: 'Indonesian',
      time: '20 min',
      price: 25000,
    ),
  ];

  final List<FoodModel> dummyDrinks = [
    FoodModel(
      imagePath: 'assets/images/sate.jpg',
      name: 'Iced Matcha Latte',
      category: 'Coffee & Tea',
      time: '5 min',
      price: 28000,
    ),
    FoodModel(
      imagePath: 'assets/images/sate.jpg',
      name: 'Strawberry Smoothies',
      category: 'Juice',
      time: '10 min',
      price: 22000,
    ),
  ];

  final List<FoodModel> dummyDesserts = [
    FoodModel(
      imagePath: 'assets/images/sate.jpg',
      name: 'Choco Lava Cake',
      category: 'Cakes',
      time: '25 min',
      price: 40000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Food, Drinks, Dessert
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F5), // Warna background standar aplikasi lu
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari makanan, minuman...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFFC84A33), // Warna accentRed lu
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFC84A33),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            tabs: [
              Tab(text: 'Food'),
              Tab(text: 'Drinks'),
              Tab(text: 'Dessert'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Food
            _buildGridContent(dummyFoods),
            // Tab 2: Drinks
            _buildGridContent(dummyDrinks),
            // Tab 3: Dessert
            _buildGridContent(dummyDesserts),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // WIDGET BUILDER
  // Dipisah agar tidak banyak kode yang berulang (DRY Principle)
  // -------------------------------------------------------------------------
  Widget _buildGridContent(List<FoodModel> dataList) {
    if (dataList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada item',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 kolom sejajar
        // Rasio ini disesuaikan dengan dimensi card lu (170 / 230)
        childAspectRatio: 170 / 230,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        // Langsung panggil custom FoodCard lu di sini
        return FoodCard(food: dataList[index]);
      },
    );
  }
}