import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase 초기화 (GoogleService-Info.plist 파일이 없어도 앱이 실행되도록 try-catch 처리)
    do {
      FirebaseApp.configure()
      
      // FCM 설정
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
      } else {
        let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }
      
      application.registerForRemoteNotifications()
      
      // FCM 메시징 델리게이트 설정
      Messaging.messaging().delegate = self
    } catch {
      print("Firebase 초기화 실패 (GoogleService-Info.plist 파일이 없을 수 있습니다): \(error)")
      // Firebase 초기화 실패해도 앱은 정상 실행
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // APNs 토큰을 받았을 때 FCM에 등록
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Firebase가 초기화된 경우에만 APNs 토큰 등록
    if FirebaseApp.app() != nil {
      Messaging.messaging().apnsToken = deviceToken
    }
  }
}

// FCM 메시징 델리게이트 확장
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    // Firebase가 초기화된 경우에만 토큰 처리
    guard FirebaseApp.app() != nil else { return }
    
    print("Firebase registration token: \(String(describing: fcmToken))")
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}
