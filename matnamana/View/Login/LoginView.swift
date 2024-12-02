////
////  LoginView.swift
////  matnamana
////
////  Created by pc on 8/28/24.
////
//
import AuthenticationServices
import UIKit


import SnapKit
import Then

final class LoginView: BaseView {
  
  private let logo = UIImageView().then {
    $0.image = UIImage(named: "MatnamanaLogo")
  }
  
  private let goodMeeting = UILabel().then {
    $0.text = "좋은 만남은"
    $0.font = UIFont.systemFont(ofSize: 35, weight: .bold)
  }
  
  private let goodQuestion = UILabel().then {
    $0.text = "좋은 질문으로부터"
    $0.font = UIFont.systemFont(ofSize: 35, weight: .bold)
  }
  
  private let quicklyReferenceCheck = UILabel().then {
    $0.text = "빠르고 안전한 평판조회"
    $0.textColor = .gray
    $0.font = UIFont.systemFont(ofSize: 15)
  }
  
  private let matnamana = UILabel().then {
    $0.text = "맞나만나"
    $0.textColor = .gray
    $0.font = UIFont.systemFont(ofSize: 15)
  }
  
  let loginButton = ASAuthorizationAppleIDButton()
  
  let kakaoLoginButton = UIButton().then {
    $0.setImage(UIImage(named: "kakaoLogin"), for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 10
  }
  
  override func configureUI() {
    self.backgroundColor = .white
    [
      logo,
      goodMeeting,
      goodQuestion,
      quicklyReferenceCheck,
      matnamana,
      loginButton,
      kakaoLoginButton
    ].forEach { self.addSubview($0) }
  }
  
  override func setConstraints() {
    logo.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.height.equalTo(logo.snp.width)
      $0.top.equalToSuperview().offset(50)
      $0.leading.trailing.equalToSuperview().inset(50)
    }
    
    goodMeeting.snp.makeConstraints {
      $0.top.equalTo(logo.snp.bottom)
      $0.centerX.equalToSuperview()
    }
    
    goodQuestion.snp.makeConstraints {
      $0.top.equalTo(goodMeeting.snp.bottom).offset(10)
      $0.centerX.equalToSuperview()
    }
    
    quicklyReferenceCheck.snp.makeConstraints {
      $0.top.equalTo(goodQuestion.snp.bottom).offset(10)
      $0.centerX.equalToSuperview()
    }
    
    matnamana.snp.makeConstraints {
      $0.top.equalTo(quicklyReferenceCheck.snp.bottom).offset(8)
      $0.centerX.equalToSuperview()
    }
    
    loginButton.snp.makeConstraints {
      $0.top.equalTo(matnamana.snp.bottom).offset(16)
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.height.equalTo(kakaoLoginButton.snp.height)
//      $0.bottom.equalToSuperview().inset(150)
//      $0.centerX.equalToSuperview()
//      $0.left.equalToSuperview().offset(16)
//      $0.right.equalToSuperview().offset(-16)
//      $0.height.equalTo(56)
    }
    
    kakaoLoginButton.snp.makeConstraints {
//      $0.bottom.equalTo(loginButton.snp.top).offset(-20)
//      $0.centerX.equalToSuperview()
//      $0.left.equalToSuperview().offset(16)
//      $0.right.equalToSuperview().offset(-16)
//      $0.height.equalTo(56)
      
      $0.top.equalTo(loginButton.snp.bottom).offset(8)
      $0.centerX.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
    }
  }
}
