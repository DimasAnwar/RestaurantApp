import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restauran_app/core/models/chat_model.dart';
import 'package:restauran_app/core/services/chat_service.dart';
import 'package:restauran_app/core/theme/app_colors.dart';
import 'package:restauran_app/core/widgets/animated_touchable.dart';

class OrderChatPage extends StatefulWidget {
  final String dbOrderId; // UUID order_id yang merujuk ke orders.id
  final String orderNumber; // String nomor order (contoh: ORD-123456)
  final String restaurantName;
  final String senderRole; // 'customer' atau 'admin'

  const OrderChatPage({
    Key? key,
    required this.dbOrderId,
    required this.orderNumber,
    this.restaurantName = 'Magic Food',
    this.senderRole = 'customer',
  }) : super(key: key);

  @override
  State<OrderChatPage> createState() => _OrderChatPageState();
}

class _OrderChatPageState extends State<OrderChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessageItem> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  RealtimeChannel? _realtimeChannel;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    await _fetchLatestMessages();

    // Coba langganan Realtime Supabase
    _realtimeChannel = ChatService.instance.subscribeToOrderChats(
      dbOrderId: widget.dbOrderId,
      onNewMessage: (newMsg) {
        if (mounted) {
          setState(() {
            if (!_messages.any((m) => m.id == newMsg.id)) {
              _messages.add(newMsg);
            }
          });
          _scrollToBottom();
        }
      },
      onErrorOrChannelFailed: () {
        // Jika Supabase Realtime belum diaktifkan di dashboard, jalankan polling otomatis 2 detik
        _startPollingFallback();
      },
    );
  }

  Future<void> _fetchLatestMessages({bool showLoading = true}) async {
    if (showLoading && _messages.isEmpty && mounted) {
      setState(() => _isLoading = true);
    }

    final fetched = await ChatService.instance.fetchMessages(widget.dbOrderId);

    if (mounted) {
      setState(() {
        _messages = fetched;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _startPollingFallback() {
    if (_pollingTimer != null && _pollingTimer!.isActive) return;
    debugPrint('🔄 Dynamic polling active for Order Chat...');
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchLatestMessages(showLoading: false);
    });
  }

  Future<void> _sendMessage([String? customText]) async {
    final text = (customText ?? _messageController.text).trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    final senderId = ChatService.instance.currentUserId;
    if (senderId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan login terlebih dahulu.')),
        );
      }
      return;
    }

    // Pesan lokal sementara (optimistic UI update)
    final localMsg = ChatMessageItem(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      orderId: widget.dbOrderId,
      senderId: senderId,
      message: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(localMsg);
      _isSending = true;
    });
    _scrollToBottom();

    final success = await ChatService.instance.sendMessage(
      dbOrderId: widget.dbOrderId,
      senderId: senderId,
      message: text,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _fetchLatestMessages(showLoading: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengirim pesan. Periksa koneksi internet.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMeAdmin = widget.senderRole == 'admin';
    final currentUserId = ChatService.instance.currentUserId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                isMeAdmin ? Icons.person_rounded : Icons.storefront_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMeAdmin ? 'Customer Chat' : widget.restaurantName,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Order #${widget.orderNumber}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // List Pesan Chat
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada pesan. Mulai percakapan!',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final item = _messages[index];
                          final isMine = (item.senderId == currentUserId);

                          return _buildMessageBubble(item, isMine, isMeAdmin);
                        },
                      ),
          ),

          // Quick Suggestion Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: isMeAdmin
                  ? [
                      _buildChip('Pesanan sedang dimasak ya!'),
                      _buildChip('Driver sudah mengantar pesanan.'),
                      _buildChip('Terima kasih telah memesan!'),
                    ]
                  : [
                      _buildChip('Bisa tolong tambahkan sambal?'),
                      _buildChip('Pesanan saya sudah sampai mana?'),
                      _buildChip('Tolong kirimkan sendok ya.'),
                    ],
            ),
          ),
          const SizedBox(height: 8),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedTouchable(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey[300]!),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageItem item, bool isMine, bool isMeAdmin) {
    String senderLabel = isMine
        ? 'Saya'
        : (isMeAdmin ? 'Pelanggan' : 'Admin Resto');

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine) ...[
              Text(
                senderLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              item.message,
              style: TextStyle(
                color: isMine ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: isMine ? Colors.white.withValues(alpha: 0.7) : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
