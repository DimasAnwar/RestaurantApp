class ChatMessageItem {
  final String id;
  final String orderId;
  final String senderId;
  final String message;
  final DateTime timestamp;

  ChatMessageItem({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    return ChatMessageItem(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      message: json['message'] ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'sender_id': senderId,
      'message': message,
    };
  }
}
