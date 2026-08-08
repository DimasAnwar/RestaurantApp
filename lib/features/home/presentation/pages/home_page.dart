import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart'; 

import 'package:restauran_app/core/theme/app_colors.dart';
import '../../../../core/services/menu_service.dart';
import '../../../../core/widgets/food_card.dart'; 

// Import komponen UI yang udah kita pisah
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_menu.dart';

class HomePage extends StatefulWidget {
  // Tambahin parameter ini buat nerima fungsi ganti tab dari MainDashboardPage
  final Function(int, {String? query, int? tabIndex})? onSwitchTab;

  const HomePage({Key? key, this.onSwitchTab}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _currentAddress = "Mencari lokasi...";
  String _userName = "User"; 
  String? _profileImageUrl; 
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isMenuLoading = true;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _getCurrentLocation();
    _getUserData(); 
    _loadMenuData();
  }

  void _getUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.userMetadata?['username'] ?? "User";
        _profileImageUrl = user.userMetadata?['avatar_url']; 
      });
    }
  }

  Future<void> _loadMenuData() async {
    await MenuService.instance.fetchMenu();
    if (mounted) setState(() => _isMenuLoading = false);
  }

  // --- INI LOGIC LOKASI LU YANG BENER, GAK GUA UBAH SAMA SEKALI ---
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _currentAddress = "GPS tidak aktif");
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _currentAddress = "Izin lokasi ditolak");
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _currentAddress = "Izin lokasi diblokir permanen");
        return;
      }

      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
      final Geocoding geocoding = Geocoding();
      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      final List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
        if (mounted) {
          setState(() {
            _currentAddress = "${place.locality}, ${place.administrativeArea}"; 
          });
        }
      }
    } catch (e) {
      debugPrint("Error Get Location: $e");
      if (mounted) setState(() => _currentAddress = "Gagal memuat alamat");
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() => _searchController.text = val.recognizedWords),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      // Pindah ke search page setelah selesai ngomong
      if (_searchController.text.isNotEmpty) {
        widget.onSwitchTab?.call(1, query: _searchController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendedList = MenuService.instance.recommended.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(address: _currentAddress, userName: _userName, imageUrl: _profileImageUrl),
                const SizedBox(height: 20),
                
                HomeSearchBar(
                    controller: _searchController,
                    isListening: _isListening,
                    onMicTap: _listen,
                    // PAS DI SEARCH, PAKSA KE TAB 'ALL' (Index 0)
                    onSubmitted: (value) => widget.onSwitchTab?.call(1, query: value, tabIndex: 0),
                      ),
                const SizedBox(height: 20),
                
                const PromoBanner(),
                const SizedBox(height: 20),
                
                CategoryMenu(
  // KARENA 'ALL' ITU 0, KATEGORI MAKANAN MULAINYA DARI 1 (Makanya ditambah 1)
  onCategoryTap: (tabIndex) => widget.onSwitchTab?.call(1, tabIndex: tabIndex + 1),
),
                const SizedBox(height: 20),

                // --- RECOMMENDED HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recommended", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
  // ARAHIN KE TAB 'ALL' (Index 0)
  onPressed: () => widget.onSwitchTab?.call(1, tabIndex: 0),
  child: Text("See all", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
)
                  ],
                ),
                const SizedBox(height: 5),

                // --- LIST MAKANAN RECOMMENDED ---
                SizedBox(
                  height: 240, 
                  child: _isMenuLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        scrollDirection: Axis.horizontal, 
                        itemCount: recommendedList.length, 
                        separatorBuilder: (context, index) => const SizedBox(width: 16), 
                        itemBuilder: (context, index) {
                          return FoodCard(food: recommendedList[index]); 
                        },
                      ),
                )
              ]
            )
          )
        )
      )
    );
  }
}