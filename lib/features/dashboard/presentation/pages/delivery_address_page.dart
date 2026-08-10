import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'map_picker_page.dart'; 

class DeliveryAddressPage extends StatefulWidget {
  const DeliveryAddressPage({Key? key}) : super(key: key);

  @override
  State<DeliveryAddressPage> createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  List<Map<String, dynamic>> _savedAddresses = [];
  int _selectedIndex = 0; 

  @override
  void initState() {
    super.initState();
    // Tarik data alamat yang pernah disimpen dari memori HP dulu
    _loadCustomAddresses().then((_) {
      // Setelah itu baru cari lokasi GPS saat ini
      _getCurrentLocation();
    });
  }

  // --- FUNGSI LOAD ALAMAT DARI LOCAL STORAGE ---
  Future<void> _loadCustomAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? addressesData = prefs.getString('custom_addresses');
    
    if (addressesData != null) {
      final List<dynamic> decoded = jsonDecode(addressesData);
      if (mounted) {
        setState(() {
          for (var item in decoded) {
            _savedAddresses.add({
              'label': item['label'],
              'address': item['address'],
              'icon': Icons.place_rounded, // Icon default buat alamat simpanan
            });
          }
        });
      }
    }
  }

  // --- FUNGSI SIMPAN ALAMAT KE LOCAL STORAGE ---
  Future<void> _saveCustomAddress(String label, String address) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil data yang udah ada di HP
    List<Map<String, dynamic>> customAddressesToSave = [];
    final String? existingData = prefs.getString('custom_addresses');
    if (existingData != null) {
      List<dynamic> decoded = jsonDecode(existingData);
      customAddressesToSave = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Tambahin alamat yang baru lu pick dari Map
    customAddressesToSave.add({
      'label': label,
      'address': address,
    });

    // Simpan ulang ke memori HP
    await prefs.setString('custom_addresses', jsonEncode(customAddressesToSave));
  }

  // --- FUNGSI AMBIL LOKASI SAAT INI ---
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _addCurrentLocationCard("GPS tidak aktif", "Silakan nyalakan GPS");
        return;
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _addCurrentLocationCard("Izin lokasi ditolak", "Silakan izinkan akses lokasi");
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _addCurrentLocationCard("Izin diblokir", "Buka setting HP buat izinkan lokasi");
        return;
      }

      LocationSettings locationSettings = const LocationSettings(accuracy: LocationAccuracy.high);
      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      final Geocoding geocoding = Geocoding();
      final List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String fullAddress = "";
        if (place.street != null) fullAddress += "${place.street}, ";
        if (place.subLocality != null) fullAddress += "${place.subLocality}, ";
        if (place.locality != null) fullAddress += "${place.locality}, ";
        if (place.administrativeArea != null) fullAddress += "${place.administrativeArea}";

        _addCurrentLocationCard("Current Location", fullAddress);
      }
    } catch (e) {
      _addCurrentLocationCard("Gagal memuat alamat", "Coba cek koneksi lu");
    }
  }

  // Helper masukin current location SELALU DI URUTAN PALING ATAS
  void _addCurrentLocationCard(String label, String address) {
    if (mounted) {
      setState(() {
        _savedAddresses.insert(0, { // Pake insert(0) biar selalu nangkring di atas
          'label': label,
          'address': address,
          'icon': Icons.my_location_rounded,
        });
        _selectedIndex = 0; // Default milih yang atas
      });
    }
  }

  // --- FUNGSI NAVIGASI KE MAP PICKER ---
  Future<void> _goToMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapPickerPage(initialLocation: LatLng(-6.1753924, 106.8271528)),
      ),
    );

    // Kalau dapet data lemparan dari MapPicker
    if (result != null && result is Map) {
      // 1. Simpan ke local storage HP biar permanen
      await _saveCustomAddress(result['label'], result['address']);

      // 2. Tampilkan di layar saat ini
      setState(() {
        _savedAddresses.add({
          'label': result['label'],      
          'address': result['address'],  
          'icon': Icons.place_rounded,   
        });
        _selectedIndex = _savedAddresses.length - 1; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Delivery Addresses', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: _savedAddresses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _savedAddresses.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = _savedAddresses[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndex = index);
                          },
                          child: _buildAddressCard(
                            item['label'], 
                            item['address'], 
                            item['icon'], 
                            _selectedIndex == index, 
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _goToMapPicker,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Add Address via Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: _savedAddresses.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedAddress = _savedAddresses[_selectedIndex];
                      Navigator.pop(context, selectedAddress);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Gunakan Alamat Ini',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAddressCard(String title, String address, IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[100], 
              shape: BoxShape.circle
            ),
            child: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          if (isSelected) 
            Icon(Icons.check_circle_rounded, color: AppColors.primary)
        ],
      ),
    );
  }
}