//
//  AnswerListCell.swift
//  matnamana
//
//  Created by pc on 9/19/24.
//

import UIKit

import Then
import SnapKit

final class AnswerListCell: UITableViewCell {
  
  private let userImage = UIImageView().then {
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 25
    $0.contentMode = .scaleAspectFit
  }
  
  let userName = UILabel().then {
    $0.text = ""
    $0.textColor = .black
  }
  
  let userRelation = UILabel().then {
    $0.text = "친구"
    $0.textColor = .black
  }
  
  
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    [
      userImage,
     userName,
     userRelation
    ].forEach { contentView.addSubview($0) }
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setConstraints() {
    userImage.snp.makeConstraints {
      $0.leading.equalToSuperview()
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
  }
  
  
  func configure(with reputation: UserProfile) {
    if let url = URL(string: reputation.profileImage ?? "") {
      userImage.kf.setImage(with: url)
    }
    userName.text = reputation.nickName
  }
}
