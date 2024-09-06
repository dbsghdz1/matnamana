//
//  LoginController.swift
//  matnamana
//
//  Created by 김윤홍 on 8/23/24.
//

import UIKit

import FirebaseAuth
import KakaoSDKAuth
import KakaoSDKUser
import RxCocoa
import RxSwift

final class LoginController: BaseViewController {
  
  private var loginView = LoginView(frame: .zero)
  private let loginviewModel = LoginViewModel()
  
  override func setupView() {
    loginView = LoginView(frame: UIScreen.main.bounds)
    self.view = loginView
  }
  
  override func bind() {
    let input = LoginViewModel.Input(
      loggedInApple: loginView.loginButton.rx.tap,
      loggedInKakao: loginView.kakaoLoginButton.rx.tap
    )
    
    let output = loginviewModel.transform(input: input)
    
    output.isDuplicate
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { isDuplicate in
        if isDuplicate {
          self.transitionToViewController(TabBarController())
        } else {
          self.transitionToViewController(RequiredInformationController())
        }
      }).disposed(by: disposeBag)
  }
}
