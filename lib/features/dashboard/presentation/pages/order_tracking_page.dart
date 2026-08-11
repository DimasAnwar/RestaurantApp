import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/models/order_model.dart';
import 'package:restauran_app/core/services/language_service.dart';
import 'package:restauran_app/core/services/notification_service.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'order_chat_page.dart';

class OrderTrackingPage extends StatefulWidget {
  final OrderData orderData;

  const OrderTrackingPage({Key? key, required this.orderData}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final LatLng _storeLocation = const LatLng(-6.603212, 106.793834);
  final LatLng _customerLocation = const LatLng(-6.608500, 106.791500);

  int _estimatedMinutes = 15;
  String _distanceText = "0 km";
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _calculateDistanceAndTime();
  }

  void _calculateDistanceAndTime() {
    const Distance distance = Distance();
    final double meter = distance.as(
      LengthUnit.Meter,
      _storeLocation,
      _customerLocation,
    );

    int calculatedTime = (meter / 500).ceil() + 10;

    setState(() {
      _estimatedMinutes = calculatedTime;
      _distanceText = '${(meter / 1000).toStringAsFixed(1)} km';
    });
  }

  int _getCurrentStep() {
    switch (widget.orderData.rawStatus) {
      case 'pending':
        return 0;
      case 'cooking':
        return 1;
      case 'on_delivery':
        return 2;
      case 'completed':
        return 3;
      default:
        return 0;
    }
  }

  Future<void> _completeOrder() async {
    setState(() => _isCompleting = true);
    final user = Supabase.instance.client.auth.currentUser;
    final lang = LanguageService.instance;

    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': 'completed'})
          .eq('order_number', widget.orderData.orderId);

      if (user != null) {
        int currentPoints = (user.userMetadata?['points'] as num?)?.toInt() ?? 0;
        int pointsEarned = (widget.orderData.price / 1000).floor().clamp(10, 2000);
        int newPoints = currentPoints + pointsEarned;

        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'points': newPoints}),
        );

        NotificationService.instance.addNotification(
          title: 'Poin Rewards Bertambah! 🎉',
          body: 'Kamu memperoleh +$pointsEarned poin dari pesanan #${widget.orderData.orderId} yang selesai.',
          type: 'reward',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.tr('order_completed_msg')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error complete order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyelesaikan pesanan.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  void _openChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderChatPage(
          dbOrderId: widget.orderData.dbOrderId,
          orderNumber: widget.orderData.orderId,
          restaurantName: widget.orderData.restaurantName,
          senderRole: 'customer',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final LatLng centerMap = LatLng(
      (_storeLocation.latitude + _customerLocation.latitude) / 2,
      (_storeLocation.longitude + _customerLocation.longitude) / 2,
    );

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9F5F0),
          body: Stack(
            children: [
              // Map Layer
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.50,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: centerMap,
                    initialZoom: 15.5,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.restauran_app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [_storeLocation, _customerLocation],
                          color: AppColors.primary.withValues(alpha: 0.6),
                          strokeWidth: 4.0,
                          pattern: StrokePattern.dashed(segments: const [10.0, 10.0]),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _storeLocation,
                          width: 50,
                          height: 50,
                          child: const _MapPin(
                            icon: Icons.storefront_rounded,
                            color: Colors.orange,
                            size: 50,
                          ),
                        ),
                        Marker(
                          point: _customerLocation,
                          width: 40,
                          height: 40,
                          child: _MapPin(
                            icon: Icons.home_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Back Button & Time Estimation
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
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Arriving in $_estimatedMinutes min',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Sheet Detail & Timeline
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.58,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Store Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.orderData.restaurantName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '📍 Bogor Trade Mall • $_distanceText',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          // Chat Button
                          _buildActionBtn(
                            Icons.chat_bubble_outline,
                            Colors.grey[600]!,
                            onTap: _openChatPage,
                          ),
                          const SizedBox(width: 12),
                          _buildActionBtn(Icons.phone_outlined, AppColors.primary),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.black12, height: 1),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${widget.orderData.orderId}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.orderData.itemCount}x items (${widget.orderData.itemDescription})',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Timeline
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildTimelineStep(
                              title: lang.tr('status_pending'),
                              subtitle: 'Pesanan sedang dikonfirmasi',
                              time: 'Tahap 1',
                              stepIndex: 0,
                              currentIndex: _getCurrentStep(),
                            ),
                            _buildTimelineStep(
                              title: lang.tr('status_cooking'),
                              subtitle: 'Toko sedang menyiapkan pesananmu',
                              time: 'Tahap 2',
                              stepIndex: 1,
                              currentIndex: _getCurrentStep(),
                            ),
                            _buildTimelineStep(
                              title: lang.tr('status_on_delivery'),
                              subtitle: 'Menuju lokasimu ($_distanceText)',
                              time: 'Tahap 3',
                              stepIndex: 2,
                              currentIndex: _getCurrentStep(),
                            ),
                            _buildTimelineStep(
                              title: lang.tr('status_completed'),
                              subtitle: 'Pesanan telah diterima',
                              time: 'Tahap Akhir',
                              stepIndex: 3,
                              currentIndex: _getCurrentStep(),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      // Complete Order Button if active
                      if (widget.orderData.isActive) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedTouchable(
                            onTap: _isCompleting ? null : _completeOrder,
                            child: ElevatedButton(
                              onPressed: _isCompleting ? null : _completeOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isCompleting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                    )
                                  : Text(
                                      lang.tr('complete_order'),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, {VoidCallback? onTap}) {
    return AnimatedTouchable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

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
          Column(
            children: [
              Container(
                width: 2,
                height: 10,
                color: stepIndex == 0
                    ? Colors.transparent
                    : (isDone || isActive ? AppColors.primary : Colors.grey[300]),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: isActive ? 4 : 0),
                ),
              ),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  if (isActive && subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _MapPin({required this.icon, required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.8,
          height: size * 0.8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: size * 0.5),
        ),
      ),
    );
  }
}
