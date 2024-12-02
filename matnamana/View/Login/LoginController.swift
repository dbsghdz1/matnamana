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
    super.setupView()
    loginView = LoginView(frame: UIScreen.main.bounds)
    self.view = loginView
  }
  
  override func bind() {
    super.bind()
    let input = LoginViewModel.Input(
      loggedInApple: loginView.loginButton.rx.controlEvent(.touchUpInside),
      loggedInKakao: loginView.kakaoLoginButton.rx.tap
    )
    
    let output = loginviewModel.transform(input: input)
    
    output.isDuplicate
      .withLatestFrom(output.appleLoggin) { (isDuplicate: Bool, appleLoggin: Bool) -> (Bool, Bool) in
        return (isDuplicate, appleLoggin)
          }
          .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] (isDuplicate, appleLoggin) in
        guard let self = self else { return }
        
        if isDuplicate {
          self.transitionToViewController(TabBarController())
        } else {
          if appleLoggin {
            let viewController = RequiredInformationController(appleLogin: true)
            self.transitionToViewController(viewController)
          } else {
            let viewController = RequiredInformationController(appleLogin: false)
            self.transitionToViewController(viewController)
          }
        }
      })
      .disposed(by: disposeBag)
  }
}
