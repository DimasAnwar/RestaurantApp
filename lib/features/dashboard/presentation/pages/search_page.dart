import 'package:flutter/material.dart';
import '../../../../core/widgets/food_card.dart';
import '../../../../core/models/food_model.dart';
import '../../../../core/services/menu_service.dart'; // Sesuaikan path-nya

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isLoading = true;
  String _searchQuery = ''; 
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await MenuService.instance.fetchMenu();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- FUNGSI FILTER DATA BERDASARKAN PENCARIAN ---
  List<FoodModel> _filterData(List<FoodModel> source) {
    if (_searchQuery.isEmpty) return source;
    return source.where((item) => 
      item.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F5),
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
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari makanan, minuman...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                // Tombol X buat hapus teks pencarian
                suffixIcon: _searchQuery.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          bottom: const TabBar(
            labelColor: Color(0xFFC84A33),
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
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC84A33)))
          : TabBarView(
              children: [
                // Data difilter sebelum dikirim ke Grid
                _buildGridContent(_filterData(MenuService.instance.foods)),
                _buildGridContent(_filterData(MenuService.instance.drinks)),
                _buildGridContent(_filterData(MenuService.instance.desserts)),
              ],
            ),
      ),
    );
  }

  Widget _buildGridContent(List<FoodModel> dataList) {
    if (dataList.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? 'Belum ada item' : 'Item tidak ditemukan',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 170 / 230,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return FoodCard(food: dataList[index]);
      },
    );
  }
}