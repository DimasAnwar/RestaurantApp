import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart'; 

import 'package:restauran_app/core/theme/app_colors.dart';
import '../../../../core/widgets/custom_input.dart';
import '../../../../core/models/food_model.dart'; 
import '../../../../core/widgets/food_card.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  // --- STATE LOKASI ---
  String _currentAddress = "Mencari lokasi...";
  
  // --- STATE PROFILE ---
  String _userName = "User"; // Default sebelum ditarik dari DB
  String? _profileImageUrl; 

  // --- STATE MICROPHONE ---
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _getCurrentLocation();
    _getUserData(); 
  }

  // --- FUNGSI TARIK DATA DARI SUPABASE ---
  void _getUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.userMetadata?['username'] ?? "User";
        _profileImageUrl = user.userMetadata?['avatar_url']; 
      });
    }
  }

  // --- FUNGSI AMBIL LOKASI REALTIME (DISESUAIKAN KE GEOLOCATOR v14) ---
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

      // PERUBAHAN UTAMA: Menggunakan LocationSettings untuk geolocator v14+
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
      final Geocoding geocoding = Geocoding();
      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
     final List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(52.2165157, 6.9437819);
      
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

  // --- FUNGSI SPEECH TO TEXT (MIC) ---
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

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
                
                // --- HEADER LOKASI & PROFILE ---
                Row(
                  children: [
                    Icon(Icons.place, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ClipOval(
                      child: _profileImageUrl != null 
                        ? Image.network( 
                            _profileImageUrl!,
                            width: 45, height: 45, fit: BoxFit.cover,
                          )
                        : Image.asset( 
                            "assets/images/default_profile.png", 
                            width: 45, height: 45, fit: BoxFit.cover,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- SAPAAN DINAMIS ---
                Text(
                  "Hello $_userName", 
                  style: const TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "What are you Eating Today?",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                
                // --- SEARCH BAR & MIC ---
                Row(
                  children: [
                    Expanded(
                      child: CustomInput(
                        label: "Search", 
                        hint: "Search for food, drinks etc.",
                        controller: _searchController,
                        isPassword: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _listen,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: _isListening ? Colors.red : AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none, 
                          size: 28, 
                          color: _isListening ? Colors.white : AppColors.primary,
                        ),
                      ),
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

                // --- LIST MAKANAN (CUSTOM WIDGET) ---
                SizedBox(
                  height: 240, 
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal, 
                    itemCount: dummyFoods.length, 
                    separatorBuilder: (context, index) => const SizedBox(width: 16), 
                    itemBuilder: (context, index) {
                      return FoodCard(food: dummyFoods[index]); 
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

  // --- WIDGET MENU KATALOG KECIL ---
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