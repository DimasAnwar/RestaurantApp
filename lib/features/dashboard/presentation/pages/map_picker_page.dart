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

  @override
  void initState() {
    super.initState();
    // Default ke Monas Jakarta kalau null, atau pakai posisi yang dilempar
    _pickedLocation = widget.initialLocation ?? const LatLng(-6.1753924, 106.8271528);
    _getAddressFromLatLng(_pickedLocation);
  }

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
        title: const Text('Pilih Lokasi di Peta', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _pickedLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() => _pickedLocation = point);
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoadingAddress ? null : () {
                        Navigator.pop(context, {'latLng': _pickedLocation, 'address': _address});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Pilih Alamat Ini', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
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