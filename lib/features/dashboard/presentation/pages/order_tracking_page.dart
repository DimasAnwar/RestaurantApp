import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'order_page.dart'; // Import ini buat ambil model OrderData

class OrderTrackingPage extends StatefulWidget {
  final OrderData orderData;

  const OrderTrackingPage({Key? key, required this.orderData}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  // Dummy koordinat buat animasi map (Misal: Resto & Lokasi Driver)
  final LatLng _restaurantLocation = const LatLng(-6.200000, 106.816666);
  final LatLng _driverLocation = const LatLng(-6.205000, 106.820000);

  // Menentukan index status saat ini berdasarkan string dari database
  int _getCurrentStep() {
    switch (widget.orderData.status) {
      case 'Menunggu': return 0;
      case 'Sedang Dimasak': return 1;
      case 'Diperjalanan': return 2;
      case 'Selesai': return 3;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0), // Warna background map default
      body: Stack(
        children: [
          // --- 1. LAYER MAP (FLUTTER MAP OSM) ---
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.55, // Setengah layar atas
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _driverLocation,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Kunci map biar fokus
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.restauran_app',
                ),
                // Garis putus-putus rute (Simulasi)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_restaurantLocation, _driverLocation],
                      color: AppColors.primary.withOpacity(0.5),
                      strokeWidth: 4.0,
                      // isDotted: true, <--- HAPUS BARIS INI
                      pattern: StrokePattern.dashed(segments: const [10.0, 10.0]), // <--- GANTI JADI INI
                    ),
                  ],
                ),
                // Marker Resto & Driver
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _restaurantLocation,
                      width: 40, height: 40,
                      child: const _MapPin(icon: Icons.storefront, color: Colors.orange),
                    ),
                    Marker(
                      point: _driverLocation,
                      width: 50, height: 50,
                      child: _MapPin(icon: Icons.delivery_dining, color: AppColors.primary, size: 50),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 2. TOMBOL BACK & ESTIMASI WAKTU (MENGAMBANG DI ATAS MAP) ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('Arriving in 12 min', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // --- 3. BOTTOM SHEET DETAIL ORDER & DRIVER ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gagang Scroll (Hiasan)
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  // --- INFO DRIVER ---
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'), // Dummy foto orang
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alex P.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 2),
                            Text('🚗 GZ-4821 • Toyota Prius', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                      // Tombol Chat
                      _buildActionBtn(Icons.chat_bubble_outline, Colors.grey[600]!),
                      const SizedBox(width: 12),
                      // Tombol Telepon
                      _buildActionBtn(Icons.phone_outlined, AppColors.primary),
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.black12, height: 1),
                  ),

                  // --- INFO ORDER ---
                  Text('Order #${widget.orderData.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.orderData.itemCount}x items (${widget.orderData.itemDescription})',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 24),

                  // --- TIMELINE STATUS VERTICAL ---
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildTimelineStep(title: 'Order Received', time: '12:30 PM', stepIndex: 0, currentIndex: _getCurrentStep()),
                        _buildTimelineStep(title: 'Preparing', time: '12:35 PM', stepIndex: 1, currentIndex: _getCurrentStep()),
                        _buildTimelineStep(title: 'On the Way', subtitle: 'Heading to you now', time: '12:45 PM', stepIndex: 2, currentIndex: _getCurrentStep()),
                        _buildTimelineStep(title: 'Delivered', time: 'Est. 1:15 PM', stepIndex: 3, currentIndex: _getCurrentStep(), isLast: true),
                      ],
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

  // --- WIDGET BANTUAN BUAT TOMBOL CHAT/CALL ---
  Widget _buildActionBtn(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  // --- WIDGET BANTUAN BUAT TIMELINE VERTIKAL ---
  Widget _buildTimelineStep({
    required String title,
    String? subtitle,
    required String time,
    required int stepIndex,
    required int currentIndex,
    bool isLast = false,
  }) {
    bool isDone = stepIndex < currentIndex;
    bool isActive = stepIndex == currentIndex;

    Color dotColor = isActive || isDone ? AppColors.primary : Colors.grey[300]!;
    Color textColor = isActive ? Colors.black : (isDone ? Colors.black87 : Colors.grey);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Garis & Titik
          Column(
            children: [
              // Garis Atas (Sembunyikan kalau item pertama)
              Container(
                width: 2, height: 10,
                color: stepIndex == 0 ? Colors.transparent : (isDone || isActive ? AppColors.primary : Colors.grey[300]),
              ),
              // Titik tengah
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: isActive ? 4 : 0),
                ),
              ),
              // Garis Bawah
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AppColors.primary : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Teks Status
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                  if (isActive && subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 2),
                  Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Bantuan Buat Bikin Pin Map Cakep
class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _MapPin({required this.icon, required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(
        color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Center(
        child: Container(
          width: size * 0.8, height: size * 0.8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: size * 0.5),
        ),
      ),
    );
  }
}