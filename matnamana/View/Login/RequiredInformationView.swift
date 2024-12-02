//
//  LoginView.swift
//  matnamana
//
//  Created by pc on 8/28/24.
//

import UIKit

import SnapKit
import Then

class RequiredInformationView: BaseView {
  
  private let scrollView = UIScrollView()
  
  private let descriptionLabel = UILabel().then {
    $0.text = "서로를 알아볼 수 있는 정보를 입력해주세요."
    $0.numberOfLines = 2
    $0.textAlignment = .left
    $0.font = UIFont.title1()
  }
  
  private let nameLabel = UILabel().then {
    $0.text = "이름"
    $0.textAlignment = .left
    $0.font = UIFont.title2()
  }
  
  let nameTextField = UITextField().then {
    $0.placeholder = "실명을 입력해주세요."
    $0.font = UIFont.callOut()
    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 0))
    $0.leftViewMode = .always
    $0.layer.cornerRadius = 15
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(.gray).cgColor
  }
  
  private let nickNameLabel = UILabel().then {
    $0.text = "닉네임"
    $0.textAlignment = .left
    $0.font = UIFont.title2()
  }
  
  let nickNameTextField = UITextField().then {
    $0.placeholder = "닉네임을 입력해주세요.(최대 15자 알파벳, 숫자)"
    $0.font = UIFont.callOut()
    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 0))
    $0.leftViewMode = .always
    $0.layer.cornerRadius = 15
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(.gray).cgColor
  }
  
  let duplicateCheckLabel = UILabel().then {
    $0.text = "중복된 닉네임입니다./사용할 수 없는 단어입니다."
    $0.textColor = .red
    $0.textAlignment = .left
    $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    $0.isHidden = true
  }
  
  private let shortDescriptionLabel = UILabel().then {
    $0.text = "소개"
    $0.textAlignment = .left
    $0.font = UIFont.title2()
  }
  
  let shortDescriptionTextField = UITextField().then {
    $0.placeholder = "나를 소개하는 단어 또는 한마디.(최대 10자)"
    $0.font = UIFont.callOut()
    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 0))
    $0.leftViewMode = .always
    $0.layer.cornerRadius = 15
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(.gray).cgColor
  }
  
  let joinButton = UIButton().then {
    $0.setTitle("맞나만나 회원가입", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = UIFont.headLine()
    $0.backgroundColor = .manaMainColor
    $0.layer.cornerRadius = 15
  }
  
  func pickNickname() -> String {
    guard let nickname = nickNameTextField.text else { return "" }
    return nickname
  }
  
  func pickName() -> String {
    guard let name = nameTextField.text else { return "" }
    return name
  }
  
  func pickShortDescription() -> String {
    guard let shorTDescription = shortDescriptionTextField.text else { return "" }
    return shorTDescription
  }
  
  func showduplicateCheck() {
    duplicateCheckLabel.isHidden = false
    duplicateCheckLabel.text = "중복된 닉네임입니다."
  }
  
  func hideduplicateCheck() {
    duplicateCheckLabel.isHidden = true
  }
  
  func validCheck() {
    duplicateCheckLabel.isHidden = false
    duplicateCheckLabel.text = "유효하지 않은 닉네임입니다."
  }

  func hidename() {
    nameLabel.isHidden = true
    nameTextField.isHidden = true
    nickNameLabel.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(60)
      $0.leading.equalToSuperview().inset(25)
    }
  }
  
  override func configureUI() {
    self.backgroundColor = .white
    [
      descriptionLabel,
      nameLabel,
      nameTextField,
      nickNameLabel,
      nickNameTextField,
      duplicateCheckLabel,
      shortDescriptionLabel,
      shortDescriptionTextField,
      joinButton
    ].forEach { scrollView.addSubview($0) }
    self.addSubview(scrollView)
  }
  
  override func setConstraints() {
    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(116)
      $0.leading.equalToSuperview().inset(28)
      $0.width.equalTo(250)
    }
    
    nameLabel.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(60)
      $0.leading.equalToSuperview().inset(25)
    }
    
    nameTextField.snp.makeConstraints {
      $0.top.equalTo(nameLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalTo(self).inset(25)
      $0.height.equalTo(62)
    }
    
    nickNameLabel.snp.makeConstraints {
      
      $0.top.equalTo(nameTextField.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview().inset(25)
      
    }
    
    nickNameTextField.snp.makeConstraints {
      $0.top.equalTo(nickNameLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalTo(nameTextField)
      $0.height.equalTo(62)
    }
    
    duplicateCheckLabel.snp.makeConstraints {
      $0.top.equalTo(nickNameTextField.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(49)
    }
    
    shortDescriptionLabel.snp.makeConstraints {
      $0.top.equalTo(duplicateCheckLabel.snp.bottom).offset(32)
      $0.leading.trailing.equalTo(nameTextField)
    }
    
    shortDescriptionTextField.snp.makeConstraints {
      $0.top.equalTo(shortDescriptionLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalTo(nameTextField)
      $0.height.equalTo(62)
    }
    
    joinButton.snp.makeConstraints {
      $0.top.equalTo(shortDescriptionTextField.snp.bottom).offset(32)
      $0.leading.trailing.equalTo(nameTextField)
      $0.height.equalTo(56)
      $0.bottom.equalToSuperview().offset(-30)
    }
  }
}
