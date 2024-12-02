//
//  TableViewCell.swift
//  matnamana
//
//  Created by 김윤홍 on 8/27/24.
//

import UIKit

import RxSwift
import SnapKit
import Then

final class FriendListCell: UITableViewCell {
  
  private let userImage = UIImageView().then {
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 25
    $0.contentMode = .scaleAspectFill
  }
  
  let userName = UILabel().then {
    $0.text = ""
    $0.font = .systemFont(ofSize: 17, weight: .semibold)
  }
  
  let userRelation = UILabel().then {
    $0.text = "친구"
    $0.font = .systemFont(ofSize: 17)
  }
  
  private let stackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
    $0.distribution = .fillEqually
  }
  
  let acceptButton = UIButton().then {
    $0.setTitle("수락하기", for: .normal)
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .manaMainColor
  }
  
  let refuseButton = UIButton().then {
    $0.setTitle("거절하기", for: .normal)
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .gray
  }
  
  let sendRequestLabel = UILabel().then {
    $0.text = ""
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    [
      acceptButton,
      refuseButton
    ].forEach { stackView.addArrangedSubview($0) }
    
    [
      userImage,
      userName,
      userRelation,
      stackView,
      sendRequestLabel
    ].forEach { contentView.addSubview($0) }
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    userImage.image = UIImage(named: "profile")
    super.prepareForReuse()
  }
  
  private func setConstraints() {
    userImage.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(20)
      $0.centerY.equalToSuperview()
      $0.width.height.equalTo(50)
    }
    
    userName.snp.makeConstraints {
      $0.leading.equalTo(userImage.snp.trailing).offset(20)
      $0.top.equalTo(userImage.snp.top)
    }
    
    userRelation.snp.makeConstraints {
      $0.top.equalTo(userName.snp.bottom).offset(5)
      $0.leading.equalTo(userName.snp.leading)
    }
    
    stackView.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-10)
      $0.leading.equalTo(userName.snp.trailing).offset(30)
      $0.centerY.equalToSuperview()
    }
    
    sendRequestLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(userImage.snp.trailing).offset(20)
    }
  }
  
  func configureCell(nickName: String, relation: String, friendImage: String) {
    userName.text = nickName
    
    if let url = URL(string: friendImage) {
      userImage.kf.setImage(with: url, placeholder: UIImage(named: "profile"))
    }
    
    switch relation.lowercased() {
    case "friend":
      userRelation.text = "친구"
    case "family":
      userRelation.text = "가족"
    case "colleague":
      userRelation.text = "동료"
    default:
      userRelation.text = relation
    }
  }
  
  func updateRequestLabel(name: String) {
    sendRequestLabel.text = "\(name)님에게 친구 요청을 보냈습니다"
  }
}
