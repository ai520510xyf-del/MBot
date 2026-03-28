import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

/// 推送通知服务
class NotificationService {
  NotificationService._();
  
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;
  String? _fcmToken;

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// FCM Token
  String? get fcmToken => _fcmToken;

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 初始化本地通知
      await _initializeLocalNotifications();
      
      // 初始化 FCM
      await _initializeFCM();
      
      // 请求权限
      await _requestPermissions();
      
      _initialized = true;
      debugPrint('NotificationService: Initialized successfully');
    } catch (e) {
      debugPrint('NotificationService: Initialization failed - $e');
    }
  }

  /// 初始化本地通知
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
        // TODO: 处理通知点击
      },
    );
  }

  /// 初始化 FCM
  Future<void> _initializeFCM() async {
    // 获取 FCM Token
    _fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // 监听 Token 刷新
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint('FCM Token refreshed: $token');
      // TODO: 上传新 Token 到服务器
    });

    // 监听前台消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received message in foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 监听后台消息点击
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened from background: ${message.data}');
    });
  }

  /// 请求通知权限
  Future<bool> _requestPermissions() async {
    // Android 13+ 需要请求通知权限
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      debugPrint('Notification permission: ${status.isGranted}');
      return status.isGranted;
    }
    
    // iOS 权限在初始化时已处理
    return true;
  }

  /// 显示本地通知
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'mbot_channel',
      'MBot 通知',
      channelDescription: 'AI Agent 消息通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// 发送本地通知（用于测试或应用内通知）
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mbot_channel',
      'MBot 通知',
      channelDescription: 'AI Agent 消息通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 获取初始消息（应用从终止状态启动）
  Future<RemoteMessage?> getInitialMessage() async {
    return await FirebaseMessaging.instance.getInitialMessage();
  }

  /// 清除所有通知
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// 订阅主题
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// 取消订阅主题
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }
}
