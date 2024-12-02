//
//  AddFriendView.swift
//  matnamana
//
//  Created by 김윤홍 on 9/1/24.
//

import UIKit

import SnapKit
import Then

class ReputationReviewView: BaseView {
  
  private let relationView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
  }
  
  let closeButton = UIButton().then {
    let image = UIImage(systemName: "xmark")
    $0.setImage(image, for: .normal)
    $0.tintColor = .lightGray
  }
  
  let badButton = UIButton().then {
    $0.backgroundColor = .white
    $0.setTitleColor(.black, for: .normal)
    $0.setTitle("도움이 안됨", for: .normal)
    $0.layer.borderWidth = 1
  }
  
  let goodButton = UIButton().then {
    $0.backgroundColor = .white
    $0.setTitleColor(.black, for: .normal)
    $0.setTitle("도움이 됨", for: .normal)
  }
  
  
  let sendButton = UIButton().then {
    $0.backgroundColor = .manaMainColor
    $0.setTitle("보내기", for: .normal)
    $0.layer.cornerRadius = 16
  }
  
  private let label = UILabel().then {
    $0.textColor = .black
    $0.textAlignment = .left
    $0.text = "맞나만나가 완료되었습니다!. \n상대방 친구의 답변이 도움이 되었나요?"
    $0.font = .headLine()
    $0.numberOfLines = 0
  }
  
  private let horizontalStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 0
    $0.distribution = .fillEqually
    $0.layer.cornerRadius = 16
    $0.layer.borderWidth = 1
    $0.clipsToBounds = true
  }
  
  override func configureUI() {
    super.configureUI()
    self.addSubview(relationView)
    
    [
      label,
      closeButton,
      horizontalStackView,
      sendButton
    ].forEach { relationView.addSubview($0) }
    
    [
      badButton,
      goodButton
    ].forEach { horizontalStackView.addArrangedSubview($0) }
    
  }
  
  override func setConstraints() {
    super.setConstraints()
    
    relationView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.horizontalEdges.equalToSuperview().inset(20)
      $0.height.equalTo(250)
    }
    
    label.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(20)
      $0.top.equalToSuperview()
    }
    
    closeButton.snp.makeConstraints {
      $0.top.trailing.equalToSuperview().inset(20)
      $0.height.width.equalTo(20)
    }
    
    horizontalStackView.snp.makeConstraints {
      $0.top.equalTo(label.snp.bottom).offset(5)
      $0.height.equalTo(60)
      $0.horizontalEdges.equalToSuperview().inset(30)
    }
    
    sendButton.snp.makeConstraints {
      $0.top.equalTo(horizontalStackView.snp.bottom).offset(20)
      $0.width.equalTo(150)
      $0.height.equalTo(40)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(20)
    }
  }
}
