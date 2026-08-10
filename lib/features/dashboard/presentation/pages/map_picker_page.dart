import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:restauran_app/core/theme/app_colors.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation;
  const MapPickerPage({Key? key, this.initialLocation}) : super(key: key);

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _pickedLocation;
  String _address = "Mengambil alamat...";
  bool _isLoadingAddress = true;
  
  // Controller baru buat Maps, Search, dan Label (Nama Alamat)
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation ?? const LatLng(-6.1753924, 106.8271528);
    _getAddressFromLatLng(_pickedLocation);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _labelController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // --- FUNGSI SEARCH ALAMAT ---
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus(); // Tutup keyboard
    
    setState(() => _isLoadingAddress = true);
    try {
      final Geocoding geocoding = Geocoding();
      List<Location> locations = await geocoding.locationFromAddress(query);
      if (locations.isNotEmpty) {
        LatLng newPos = LatLng(locations.first.latitude, locations.first.longitude);
        setState(() => _pickedLocation = newPos);
        _mapController.move(newPos, 15.0); // Pindahin kamera ke lokasi baru
        _getAddressFromLatLng(newPos);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi tidak ditemukan! Coba lebih spesifik.')),
      );
      setState(() => _isLoadingAddress = false);
    }
  }

  // --- FUNGSI UBAH KOORDINAT JADI ALAMAT ---
  Future<void> _getAddressFromLatLng(LatLng point) async {
    setState(() => _isLoadingAddress = true);
    final Geocoding geocoding = Geocoding();
    try {
      List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        String fullAddress = "";
        if (p.street != null && p.street!.isNotEmpty) fullAddress += "${p.street}, ";
        if (p.subLocality != null && p.subLocality!.isNotEmpty) fullAddress += "${p.subLocality}, ";
        if (p.locality != null && p.locality!.isNotEmpty) fullAddress += "${p.locality}, ";
        if (p.administrativeArea != null) fullAddress += "${p.administrativeArea}";

        setState(() {
          _address = fullAddress.isEmpty ? "Lokasi Dipilih" : fullAddress;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = "Alamat tidak ditemukan";
        _isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pilih Lokasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // --- 1. LAYER MAPS ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() => _pickedLocation = point);
                _mapController.move(point, _mapController.camera.zoom);
                _getAddressFromLatLng(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.restauran_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedLocation,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),

          // --- 2. SEARCH BAR MENGAMBANG DI ATAS MAPS ---
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchLocation,
                decoration: InputDecoration(
                  hintText: 'Cari kota, jalan, gedung...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // --- 3. KARTU INFORMASI DI BAWAH ---
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alamat Terpilih:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    _isLoadingAddress ? "Memuat nama alamat..." : _address,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // INPUT NAMA LABEL (RUMAH/KANTOR)
                  TextField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      hintText: 'Simpan sebagai (Contoh: Rumah, Kantor)',
                      hintStyle: const TextStyle(fontSize: 13),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoadingAddress ? null : () {
                        // Kalau label kosong, kasih default 'Alamat Tersimpan'
                        String finalLabel = _labelController.text.trim().isEmpty 
                            ? 'Alamat Tersimpan' 
                            : _labelController.text.trim();

                        Navigator.pop(context, {
                          'latLng': _pickedLocation, 
                          'address': _address,
                          'label': finalLabel // Lempar nama label-nya
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan Alamat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}