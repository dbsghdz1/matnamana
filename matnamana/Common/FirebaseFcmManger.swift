////
////  FirebaseFcmManger.swift
////  matnamana
////
////  Created by 이진규 on 10/1/24.
////
//
//import UIKit
//
//import Firebase
//import FirebaseMessaging
//import UserNotifications
//
//final class FirebaseFcmManger: NSObject {
//  static let shared = FirebaseFcmManger()
//
//  private override init() {
//    super.init()
//  }
//
//  func configure(application: UIApplication) {
//    Messaging.messaging().delegate = self
//    UNUserNotificationCenter.current().delegate = self
//    requestNotificationAuthorization()
//    application.registerForRemoteNotifications()
//  }
//
//  private func requestNotificationAuthorization() {
//    UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .alert, .badge]) { isAgree, error in
//      if isAgree {
//        print("알림허용")
//      }
//    }
//  }
//}
//
//// MARK: - UNUserNotificationCenterDelegate, MessagingDelegate
//extension FirebaseFcmManger: UNUserNotificationCenterDelegate, MessagingDelegate {
//  /// 푸시 클릭 시
//  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//    print("🟢", #function)
//  }
//
//  /// 앱 화면 보고 있는 중에 푸시 올 때
//  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
//    print("🟢", #function)
//    return [.sound, .banner, .list]
//  }
//  
//  /// FCMToken 업데이트 시
//  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//    print("🟢", #function, fcmToken)
//  }
//
//  /// 스위즐링 NO 시, APNs 등록, 토큰 값 가져옴
//  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//    Messaging.messaging().apnsToken = deviceToken
//    let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
//    print("🟢", #function, deviceTokenString)
//  }
//
//  /// 에러 발생 시
//  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//    print("🟢", error)
//  }
//}
