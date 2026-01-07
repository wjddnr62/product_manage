import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rehabiltiation/splash_page.dart';
import 'services/fcm_service.dart';

/// 백그라운드 메시지 핸들러 (최상위 함수로 선언해야 함)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('백그라운드 메시지 핸들러 실행: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();
  await Hive.openBox('user');
  
  // Firebase 초기화 (JSON 파일이 없어도 앱이 실행되도록 try-catch 처리)
  try {
    await Firebase.initializeApp();
    
    // 백그라운드 메시지 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // FCM 서비스 초기화
    await FcmService().initialize();
  } catch (e) {
    debugPrint('Firebase 초기화 실패 (FCM JSON 파일이 없을 수 있습니다): $e');
    // Firebase 초기화 실패해도 앱은 정상 실행
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'maplestory', // 앱 전체 기본 폰트 설정
      ),
      home: const SplashPage(),
    );
  }
}
