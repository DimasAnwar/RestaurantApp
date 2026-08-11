import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restauran_app/core/models/chat_model.dart';

class ChatService {
  static final ChatService instance = ChatService._internal();
  ChatService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  /// Utility to get current authenticated user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Fetch chat messages for specific order UUID
  Future<List<ChatMessageItem>> fetchMessages(String dbOrderId) async {
    if (dbOrderId.isEmpty) return [];

    try {
      final response = await _client
          .from('order_chats')
          .select()
          .eq('order_id', dbOrderId)
          .order('created_at', ascending: true);

      if (response == null || response is! List) return [];

      return response
          .map((json) => ChatMessageItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('🚨 Error fetching chat messages: $e');
      return [];
    }
  }

  /// Send chat message to Supabase with input sanitization and security validation
  Future<bool> sendMessage({
    required String dbOrderId,
    required String senderId,
    required String message,
  }) async {
    final sanitizedMessage = message.trim();
    if (sanitizedMessage.isEmpty || dbOrderId.isEmpty) {
      debugPrint('⚠️ Invalid message payload prevented.');
      return false;
    }

    final validSenderId = senderId.isNotEmpty ? senderId : (currentUserId ?? '');
    if (validSenderId.isEmpty) {
      debugPrint('⚠️ Unauthenticated chat message attempt blocked.');
      return false;
    }

    try {
      await _client.from('order_chats').insert({
        'order_id': dbOrderId,
        'sender_id': validSenderId,
        'message': sanitizedMessage,
      });
      return true;
    } catch (e) {
      debugPrint('🚨 Error sending chat message: $e');
      return false;
    }
  }

  /// Subscribe to Realtime Postgres Changes with auto-fallback to Polling on ChannelError
  RealtimeChannel? subscribeToOrderChats({
    required String dbOrderId,
    required Function(ChatMessageItem) onNewMessage,
    required VoidCallback onErrorOrChannelFailed,
  }) {
    if (dbOrderId.isEmpty) {
      onErrorOrChannelFailed();
      return null;
    }

    try {
      final channel = _client.channel('public:order_chats_$dbOrderId');

      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'order_chats',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'order_id',
          value: dbOrderId,
        ),
        callback: (payload) {
          if (payload.newRecord != null && payload.newRecord.isNotEmpty) {
            final newMsg = ChatMessageItem.fromJson(payload.newRecord);
            onNewMessage(newMsg);
          }
        },
      ).subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.channelError || error != null) {
          debugPrint('⚠️ Supabase Realtime channel error ($status): $error. Triggering fallback.');
          onErrorOrChannelFailed();
        }
      });

      return channel;
    } catch (e) {
      debugPrint('🚨 Error creating Realtime subscription: $e. Triggering fallback.');
      onErrorOrChannelFailed();
      return null;
    }
  }
}
