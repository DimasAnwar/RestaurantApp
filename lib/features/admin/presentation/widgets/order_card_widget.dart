import 'package:flutter/material.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'package:restauran_app/features/admin/presentation/widgets/print_receipt_dialog.dart';

class OrderCardWidget extends StatelessWidget {
  final dynamic order;
  final VoidCallback onAccept;
  final VoidCallback? onPrint;

  const OrderCardWidget({
    Key? key,
    required this.order,
    required this.onAccept,
    this.onPrint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderNumber = order['order_number']?.toString() ?? 'ORD-0000';
    final items = order['order_items'] as List<dynamic>? ?? [];
    final itemCount = items.fold<int>(0, (sum, i) => sum + ((i['jumlah'] as num?)?.toInt() ?? 1));
    final customerName = order['alamat_pengiriman'] != null && order['alamat_pengiriman'].toString().isNotEmpty
        ? _extractName(order['alamat_pengiriman'].toString())
        : 'Customer';

    final price = (order['total_price'] as num?)?.toDouble() ?? 0.0;
    final status = order['status'] as String? ?? 'pending';

    String actionLabel = '✓ Accept';
    if (status == 'cooking') actionLabel = '✓ Dispatch';
    if (status == 'on_delivery') actionLabel = '✓ Complete';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#$orderNumber',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ASAP',
                            style: TextStyle(
                              color: Color(0xFFD83A1E),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${_formatPrice(price)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lunas (Paid)',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$customerName • $itemCount Items',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFAF7F5),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedTouchable(
                    onTap: onAccept,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD83A1E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        actionLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedTouchable(
                  onTap: () {
                    if (onPrint != null) {
                      onPrint!();
                    } else {
                      PrintReceiptDialog.show(context, order);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(
                      Icons.print_outlined,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _extractName(String address) {
    if (address.contains(',')) {
      return address.split(',').first;
    }
    return address.length > 15 ? address.substring(0, 15) : address;
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
