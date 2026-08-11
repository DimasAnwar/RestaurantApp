class OrderData {
  final String dbOrderId;
  final String restaurantName;
  final String date;
  final String orderId;
  final String rawStatus;
  final String status;
  final bool isActive;
  final int itemCount;
  final String itemDescription;
  final double price;
  final String buttonText;
  final bool hasStarButton;
  final List<dynamic> rawItems;

  OrderData({
    required this.dbOrderId,
    required this.restaurantName,
    required this.date,
    required this.orderId,
    required this.rawStatus,
    required this.status,
    required this.isActive,
    required this.itemCount,
    required this.itemDescription,
    required this.price,
    required this.buttonText,
    this.hasStarButton = false,
    this.rawItems = const [],
  });
}
