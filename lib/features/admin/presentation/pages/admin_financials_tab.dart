import 'package:flutter/material.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';
import 'package:restauran_app/features/admin/data/admin_repository.dart';
import 'package:restauran_app/features/admin/models/admin_models.dart';
import 'package:restauran_app/features/admin/presentation/widgets/revenue_chart_widget.dart';

class AdminFinancialsTab extends StatefulWidget {
  final List<dynamic> orders;

  const AdminFinancialsTab({Key? key, required this.orders}) : super(key: key);

  @override
  State<AdminFinancialsTab> createState() => _AdminFinancialsTabState();
}

class _AdminFinancialsTabState extends State<AdminFinancialsTab> {
  late FinancialMetric _metrics;
  late List<RevenuePoint> _revenuePoints;
  late List<TransactionItem> _transactions;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Set default date range to Today per user instruction
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day),
    );
    _loadFinancialData();
  }

  @override
  void didUpdateWidget(covariant AdminFinancialsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orders != widget.orders) {
      _loadFinancialData();
    }
  }

  void _loadFinancialData() {
    _metrics = AdminRepository.instance.calculateFinancialMetrics(
      widget.orders,
      range: _selectedDateRange,
    );
    _revenuePoints = AdminRepository.instance.getWeeklyRevenueTrend(
      widget.orders,
      range: _selectedDateRange,
    );
    _transactions = AdminRepository.instance.getRecentTransactions(widget.orders);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      initialDateRange: _selectedDateRange ?? DateTimeRange(start: now, end: now),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD83A1E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _loadFinancialData();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data keuangan diperbarui untuk: ${_formatDateRange(picked)}'),
            backgroundColor: const Color(0xFFD83A1E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return 'Hari Ini';
    final start = range.start;
    final end = range.end;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return 'Hari Ini (${start.day} ${months[start.month - 1]} ${start.year})';
    }
    return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),

            // Interactive Date Range Picker Box (Default: Hari Ini)
            AnimatedTouchable(
              onTap: _pickDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFFD83A1E)),
                        const SizedBox(width: 10),
                        Text(
                          _formatDateRange(_selectedDateRange),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade700),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Metric Cards Grid from Real Order Data
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    label: 'HARI INI',
                    growthPercent: _metrics.todayGrowthPercent,
                    revenueAmount: _metrics.todayRevenue,
                    isHighlight: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    label: 'RENTANG TGL',
                    growthPercent: _metrics.thisWeekGrowthPercent,
                    revenueAmount: _metrics.thisWeekRevenue,
                    isHighlight: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Revenue Trend Chart generated dynamically from Real Orders
            RevenueChartWidget(
              points: _revenuePoints,
              onViewReportTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka Laporan Keuangan Lengkap... 📈')),
                );
              },
            ),

            const SizedBox(height: 24),

            // Recent Activity Section generated from Real Orders
            const Text(
              'Aktivitas Penjualan Terbaru',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            if (_transactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Center(
                  child: Text(
                    'Belum ada transaksi penjualan recorded',
                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      separatorBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Colors.black12, height: 1),
                      ),
                      itemBuilder: (context, index) {
                        final tx = _transactions[index];
                        return _buildTransactionItem(tx);
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // View All Transactions Button
            SizedBox(
              width: double.infinity,
              child: AnimatedTouchable(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menampilkan seluruh riwayat transaksi...')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Lihat Semua Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required double growthPercent,
    required double revenueAmount,
    required bool isHighlight,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isHighlight
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '↗ +$growthPercent%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Rp ${_formatRupiah(revenueAmount)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isHighlight ? const Color(0xFFD83A1E) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionItem tx) {
    IconData iconData;
    Color iconColor;
    Color iconBg;

    if (tx.isCredit) {
      iconData = Icons.account_balance_wallet_outlined;
      iconColor = Colors.green;
      iconBg = const Color(0xFFE8F5E9);
    } else {
      iconData = Icons.receipt_long_outlined;
      iconColor = const Color(0xFFD83A1E);
      iconBg = const Color(0xFFFDE8E4);
    }

    final formattedAmount = '${tx.isCredit ? '+' : '-'}Rp ${_formatRupiah(tx.amount)}';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(iconData, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                tx.timestamp,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          formattedAmount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: tx.isCredit ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  String _formatRupiah(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
