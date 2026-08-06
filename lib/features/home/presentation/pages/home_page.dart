import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import '../../../../core/widgets/custom_input.dart';

// KUNCI: Import file model dan custom widget yang udah lu bikin
import '../../../../core/models/food_model.dart'; // Sesuaikan jumlah '../' dengan posisi folder lu
import '../../../../core/widgets/food_card.dart'; // Sesuaikan jumlah '../' dengan posisi folder lu

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- HEADER LOKASI ---
                Row(
                  children: [
                    Icon(Icons.place, color: AppColors.primary),
                    const SizedBox(width: 4),
                    const Text(
                      "Current Location",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ClipOval(
                      child: Image.asset(
                        "assets/images/sate.jpg",
                        width: 45, height: 45, fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- SAPAAN ---
                const Text(
                  "Hello Dimas",
                  style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "What are you Eating Today?",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // --- SEARCH BAR ---
                Row(
                  children: [
                    Expanded(
                      child: CustomInput(
                        icon: Icons.search, 
                        label: "Search",
                        hint: "Search for food, drinks etc.",
                        controller: _searchController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.mic, size: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- PROMO BANNER ---
                SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.asset("assets/images/promo1.jpg", fit: BoxFit.cover),
                        ),
                      ),
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20, top: 20,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Special Offers",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 20, left: 20,
                        child: Text(
                          "50% Off \nFirst Order",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- TABS KATALOG ---
                SizedBox(
                  width: double.infinity,
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                    children: [
                      _buildKatalogMenu(Icons.food_bank, "Food"),
                      _buildKatalogMenu(Icons.local_drink_rounded, "Drinks"),
                      _buildKatalogMenu(Icons.icecream_rounded, "Dessert"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- RECOMMENDED HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recommended",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "See all",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),

                // --- LIST MAKANAN (MEMANGGIL CUSTOM WIDGET) ---
                SizedBox(
                  height: 240, 
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal, 
                    // dummyFoods ini otomatis kebaca dari file food_model.dart yang udah di-import
                    itemCount: dummyFoods.length, 
                    separatorBuilder: (context, index) => const SizedBox(width: 16), 
                    itemBuilder: (context, index) {
                      // Manggil cetakan custom widget yang ada di food_card.dart
                      return FoodCard(food: dummyFoods[index]); 
                    },
                  ),
                )
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi helper biar kode Tabs Menu nggak kotor
  Widget _buildKatalogMenu(IconData icon, String title) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 235, 184, 174),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(icon, size: 36, color: const Color.fromARGB(255, 85, 27, 13)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Inter'),
        )
      ],
    );
  }
}