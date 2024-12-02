//
//  AppDelegate.swift
//  matnamana
//
//  Created by 김윤홍 on 8/22/24.
//

import UIKit
import CoreData

import FirebaseCore
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      UINavigationBar.appearance().layoutMargins.left = 40
      UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.systemFont(ofSize: 28, weight: .bold)]

      KakaoSDK.initSDK(appKey: "a819a59d9cb83cddc3d7d806754f2a1e")

      FirebaseApp.configure()

      //FirebaseFcmManger.shared.configure(application: application)

      return true
    }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "matnamana")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}
