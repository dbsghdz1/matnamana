//
//  Ex+UIColor.swift
//  matnamana
//
//  Created by 김윤홍 on 8/29/24.
//

import UIKit

extension UIColor {
  static let beaconColor = UIColor(red: 242/255, green: 132/255, blue: 30/255, alpha: 1)
  static let manaMainColor = UIColor(red: 0/255, green: 168/255, blue: 226/255, alpha: 1)
  static let manatextColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
}
extension UIViewController {
  func transitionToViewController(_ viewController: UIViewController) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return }
    window.rootViewController = viewController
    window.makeKeyAndVisible()
  }
  
  func pushViewController(_ viewController: UIViewController) {
    navigationController?.pushViewController(viewController, animated: true)
  }
  func popViewController() {
    navigationController?.popViewController(animated: true)
  }
  
  func presentModally(
    _ viewController: UIViewController,
    animated: Bool = true,
    modalPresentationStyle: UIModalPresentationStyle = .formSheet
  ) {
    viewController.modalPresentationStyle = modalPresentationStyle
    self.present(viewController, animated: animated)
  }
  
  func hideKeyboardWhenTappedAround() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}

extension UIView {
  func setupShadow() {
    self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04)
    self.layer.cornerRadius = 10
    self.layer.masksToBounds = false
    //    self.layer.shadowOpacity = 1
    //    self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
    //    self.layer.shadowOffset = CGSize(width: 2, height: 2)
    //    self.layer.shadowRadius = 2
  }
}

extension UIFont {
  static func screenTitle(fontSize: CGFloat = 34) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .bold)
  }
  
  static func title1(fontSize: CGFloat = 28) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .bold)
  }
  
  static func title2(fontSize: CGFloat = 22) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .bold)
  }
  
  static func title3(fontSize: CGFloat = 20) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .semibold)
  }
  
  static func headLine(fontSize: CGFloat = 17) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .semibold)
  }
  
  static func bonmoon(fontSize: CGFloat = 17) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .regular)
  }
  
  static func callOut(fontSize: CGFloat = 16) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .semibold)
  }
  
  static func subHeadLine(fontSize: CGFloat = 15) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .regular)
  }
  
  static func footNote(fontSize: CGFloat = 13) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .regular)
  }
  
  static func caption(fontSize: CGFloat = 12) -> UIFont {
    return UIFont.systemFont(ofSize: fontSize, weight: .regular)
  }
}
