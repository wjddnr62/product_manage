import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// FCM 서비스 클래스
/// Firebase Cloud Messaging 관련 기능을 관리합니다.
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  FirebaseMessaging? _firebaseMessaging;
  String? _fcmToken;
  
  /// FirebaseMessaging 인스턴스 가져오기 (지연 초기화)
  FirebaseMessaging get firebaseMessaging {
    _firebaseMessaging ??= FirebaseMessaging.instance;
    return _firebaseMessaging!;
  }

  /// FCM 토큰을 가져옵니다.
  String? get fcmToken => _fcmToken;

  /// FCM 초기화
  Future<void> initialize() async {
    try {
      // Firebase가 초기화되지 않았으면 초기화하지 않음
      try {
        FirebaseMessaging.instance;
      } catch (e) {
        debugPrint('Firebase Messaging 인스턴스를 가져올 수 없습니다: $e');
        return;
      }
      
      // 알림 권한 요청 (iOS)
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('사용자가 알림 권한을 허용했습니다.');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('사용자가 임시 알림 권한을 허용했습니다.');
      } else {
        debugPrint('사용자가 알림 권한을 거부했습니다.');
      }

      // FCM 토큰 가져오기
      await _getFcmToken();

      // 토큰 갱신 리스너
      firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM 토큰이 갱신되었습니다: $newToken');
        // 여기에 서버로 새 토큰을 전송하는 로직을 추가할 수 있습니다.
      });

      // 포그라운드 메시지 핸들러
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 백그라운드 메시지 핸들러 (앱이 종료된 상태에서 메시지를 받았을 때)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // 앱이 종료된 상태에서 알림을 탭하여 앱을 열었을 때
      RemoteMessage? initialMessage = await firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
      }
    } catch (e) {
      debugPrint('FCM 초기화 중 오류 발생: $e');
    }
  }

  /// FCM 토큰 가져오기
  Future<void> _getFcmToken() async {
    try {
      _fcmToken = await firebaseMessaging.getToken();
      debugPrint('FCM 토큰: $_fcmToken');
      // 여기에 서버로 토큰을 전송하는 로직을 추가할 수 있습니다.
    } catch (e) {
      debugPrint('FCM 토큰 가져오기 실패: $e');
    }
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('포그라운드 메시지 수신:');
    debugPrint('제목: ${message.notification?.title}');
    debugPrint('내용: ${message.notification?.body}');
    debugPrint('데이터: ${message.data}');

    // 여기에 포그라운드에서 알림을 표시하는 로직을 추가할 수 있습니다.
    // 예: flutter_local_notifications 패키지 사용
  }

  /// 백그라운드 메시지 처리
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('백그라운드 메시지 수신:');
    debugPrint('제목: ${message.notification?.title}');
    debugPrint('내용: ${message.notification?.body}');
    debugPrint('데이터: ${message.data}');

    // 여기에 백그라운드 메시지를 처리하는 로직을 추가할 수 있습니다.
    // 예: 특정 화면으로 이동, 데이터 업데이트 등
  }

  /// 토픽 구독
  Future<void> subscribeToTopic(String topic) async {
    try {
      await firebaseMessaging.subscribeToTopic(topic);
      debugPrint('토픽 구독 성공: $topic');
    } catch (e) {
      debugPrint('토픽 구독 실패: $e');
    }
  }

  /// 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('토픽 구독 해제 성공: $topic');
    } catch (e) {
      debugPrint('토픽 구독 해제 실패: $e');
    }
  }

  /// FCM 토큰 삭제
  Future<void> deleteToken() async {
    try {
      await firebaseMessaging.deleteToken();
      _fcmToken = null;
      debugPrint('FCM 토큰 삭제 완료');
    } catch (e) {
      debugPrint('FCM 토큰 삭제 실패: $e');
    }
  }
}

