import 'package:flutter/material.dart';
import 'package:restauran_app/features/admin/models/admin_models.dart';

class RevenueChartWidget extends StatelessWidget {
  final List<RevenuePoint> points;
  final VoidCallback? onViewReportTap;

  const RevenueChartWidget({
    Key? key,
    required this.points,
    this.onViewReportTap,
  }) : super(key: key);

  String _formatAmount(double amount) {
    if (amount == 0) return 'Rp 0';
    if (amount >= 1000000) {
      final val = amount / 1000000;
      return 'Rp ${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    } else {
      return 'Rp ${amount.toInt()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxAmount = points.fold<double>(1.0, (max, p) => p.amount > max ? p.amount : max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tren Pendapatan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: onViewReportTap,
                child: const Text(
                  'Lihat Laporan',
                  style: TextStyle(
                    color: Color(0xFFD83A1E),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bar Chart Graphics dengan tinggi fleksibel 165px untuk mencegah Bottom Overflow
          SizedBox(
            height: 165,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.map((point) {
                final heightFactor = (point.amount / maxAmount).clamp(0.2, 1.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (point.isHighlighted && point.amount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _formatAmount(point.amount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 18),
                    Container(
                      width: 26,
                      height: 95 * heightFactor,
                      decoration: BoxDecoration(
                        color: point.isHighlighted && point.amount > 0
                            ? const Color(0xFFD83A1E)
                            : const Color(0xFFF6C8C0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      point.dayLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: point.isHighlighted ? FontWeight.bold : FontWeight.normal,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
