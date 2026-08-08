import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'map_picker_page.dart'; // Pastikan file map_picker_page.dart ada di folder yang sama

class DeliveryAddressPage extends StatefulWidget {
  const DeliveryAddressPage({Key? key}) : super(key: key);

  @override
  State<DeliveryAddressPage> createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  String _currentAddress = "Mencari lokasi saat ini...";
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // --- FUNGSI AMBIL LOKASI SAAT INI ---
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _currentAddress = "GPS tidak aktif. Nyalakan GPS lu bro.";
            _isLoadingLocation = false;
          });
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _currentAddress = "Izin lokasi ditolak.";
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _currentAddress = "Izin lokasi diblokir permanen. Buka setting HP.";
            _isLoadingLocation = false;
          });
        }
        return;
      }

      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
      
      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);
      final Geocoding geocoding = Geocoding();
      // Ambil nama jalan/daerah dari koordinat
      final List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Gabungin data biar alamatnya lengkap
        String fullAddress = "";
        if (place.street != null && place.street!.isNotEmpty) fullAddress += "${place.street}, ";
        if (place.subLocality != null && place.subLocality!.isNotEmpty) fullAddress += "${place.subLocality}, ";
        if (place.locality != null && place.locality!.isNotEmpty) fullAddress += "${place.locality}, ";
        if (place.administrativeArea != null) fullAddress += "${place.administrativeArea}";

        if (mounted) {
          setState(() {
            _currentAddress = fullAddress;
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error Get Location: $e");
      if (mounted) {
        setState(() {
          _currentAddress = "Gagal memuat alamat. Cek internet/GPS lu.";
          _isLoadingLocation = false;
        });
      }
    }
  }

  // --- FUNGSI NAVIGASI KE MAP PICKER ---
  Future<void> _goToMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // Koordinat default awal (misal Monas Jakarta)
        builder: (context) => const MapPickerPage(initialLocation: null),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _currentAddress = result['address'];
        _isLoadingLocation = false;
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
            // Cuma nampilin Current Location
            _buildAddressCard(
              'Current Location',
              _isLoadingLocation ? 'Sedang mencari lokasi...' : _currentAddress,
              Icons.my_location_rounded,
              true,
            ),
            const SizedBox(height: 24),
            
            // Tombol Add New Map (Manggil Map Picker OpenStreetMap)
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