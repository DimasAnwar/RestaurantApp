import 'package:flutter/material.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'package:restauran_app/features/admin/models/admin_models.dart';

class CourierTrackingCard extends StatelessWidget {
  final dynamic order;
  final CourierInfo courier;
  final VoidCallback onChatTap;
  final VoidCallback onCallTap;
  final VoidCallback? onAcceptTap;
  final String? actionButtonText;

  const CourierTrackingCard({
    Key? key,
    required this.order,
    required this.courier,
    required this.onChatTap,
    required this.onCallTap,
    this.onAcceptTap,
    this.actionButtonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderNumber = order['order_number']?.toString() ?? 'ORD-8921';
    final items = order['order_items'] as List<dynamic>? ?? [];
    final itemCount = items.fold<int>(0, (sum, i) => sum + ((i['jumlah'] as num?)?.toInt() ?? 1));
    final displayItemCount = itemCount > 0 ? itemCount : 4;
    final price = (order['total_price'] as num?)?.toDouble() ?? 68000.0;
    final status = order['status'] as String? ?? 'on_delivery';

    // Segment active levels: pending = 1, cooking = 2, on_delivery = 3
    int activeSegment = 3;
    String label3 = 'Arriving';
    Color label3Color = const Color(0xFFD83A1E);

    if (status == 'pending') {
      activeSegment = 1;
      label3 = 'Delivered';
      label3Color = Colors.grey;
    } else if (status == 'cooking') {
      activeSegment = 2;
      label3 = 'Delivered';
      label3Color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: #ORD-8921  [Sushico]           2 min
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    '#$orderNumber',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Sushico',
                      style: TextStyle(
                        color: Color(0xFF9E2C14),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: const [
                  Text(
                    '2',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    'min',
                    style: TextStyle(
                      color: Color(0xFFD83A1E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),
          // Subheader: 4 items • Rp 68.000
          Text(
            '$displayItemCount items • Rp ${_formatPrice(price)}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Status Step Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Picked Up',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: activeSegment >= 1 ? const Color(0xFF3B5998) : Colors.grey,
                ),
              ),
              Text(
                'On the way',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: activeSegment >= 2 ? const Color(0xFF3B5998) : Colors.grey,
                ),
              ),
              Text(
                label3,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: label3Color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Segmented Progress Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: activeSegment >= 1 ? const Color(0xFFC02A13) : const Color(0xFFFDE8E4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: activeSegment >= 2 ? const Color(0xFFC02A13) : const Color(0xFFFDE8E4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: activeSegment >= 3 ? const Color(0xFFF09A8D) : const Color(0xFFFDE8E4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Colors.black12, height: 1),
          ),

          // Courier Profile & Action Buttons
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: const AssetImage('assets/images/user2.jpg'),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courier.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          '${courier.rating} • ${courier.vehicle}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chat Action Button (Invokes OrderChatPage)
              AnimatedTouchable(
                onTap: onChatTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF2C3E50),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Call Action Button
              AnimatedTouchable(
                onTap: onCallTap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD83A1E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          // Optional Accept / Process Action Button if supplied
          if (onAcceptTap != null && actionButtonText != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AnimatedTouchable(
                onTap: onAcceptTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD83A1E),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    actionButtonText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
