import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'order', 'reward', 'promo', 'system'
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = 'order',
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        timestamp: DateTime.parse(json['timestamp']),
        type: json['type'] ?? 'order',
        isRead: json['isRead'] ?? false,
      );
}

class NotificationService extends ChangeNotifier {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  List<AppNotification> _notifications = [];
  bool _syncWithSystem = true;

  List<AppNotification> get notifications => _notifications;
  bool get syncWithSystem => _syncWithSystem;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _syncWithSystem = prefs.getBool('sync_system_notification') ?? true;
    final String? notifData = prefs.getString('user_notifications');
    if (notifData != null) {
      try {
        final List<dynamic> list = jsonDecode(notifData);
        _notifications = list.map((e) => AppNotification.fromJson(e)).toList();
      } catch (e) {
        _notifications = [];
      }
    }

    // Default sample notification if empty
    if (_notifications.isEmpty) {
      _notifications.add(
        AppNotification(
          id: 'welcome_1',
          title: 'Selamat Datang di Restaurant App!',
          body: 'Nikmati berbagai promo makanan lezat dan kumpulkan poin rewards kamu.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          type: 'promo',
        ),
      );
      _saveNotifications();
    }
    notifyListeners();
  }

  Future<void> setSyncWithSystem(bool value) async {
    _syncWithSystem = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sync_system_notification', value);
    notifyListeners();
  }

  Future<void> addNotification({
    required String title,
    required String body,
    String type = 'order',
  }) async {
    if (!_syncWithSystem) return; // If disabled, don't log

    final newNotif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
    );

    _notifications.insert(0, newNotif);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    for (var n in _notifications) {
      n.isRead = true;
    }
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString('user_notifications', data);
  }
}
