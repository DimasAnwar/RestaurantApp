class FinancialMetric {
  final double todayRevenue;
  final double todayGrowthPercent;
  final double thisWeekRevenue;
  final double thisWeekGrowthPercent;

  FinancialMetric({
    required this.todayRevenue,
    required this.todayGrowthPercent,
    required this.thisWeekRevenue,
    required this.thisWeekGrowthPercent,
  });
}

class RevenuePoint {
  final String dayLabel; // 'M', 'T', 'W', 'T', 'F', 'S', 'S'
  final double amount;
  final bool isHighlighted;

  RevenuePoint({
    required this.dayLabel,
    required this.amount,
    this.isHighlighted = false,
  });
}

class TransactionItem {
  final String id;
  final String title;
  final String timestamp;
  final double amount;
  final bool isCredit; // true = +, false = -
  final String iconType; // 'deposit', 'payout', 'lease'

  TransactionItem({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.amount,
    required this.isCredit,
    required this.iconType,
  });
}

class CourierInfo {
  final String name;
  final String avatarUrl;
  final double rating;
  final String vehicle; // 'Bicycle', 'Scooter', 'Motorcycle'
  final String phone;

  CourierInfo({
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.vehicle,
    this.phone = '08123456789',
  });
}
