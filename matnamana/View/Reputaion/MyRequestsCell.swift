//
//  MyRequestsCollectionViewCell.swift
//  matnamana
//
//  Created by pc on 9/6/24.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class MyRequestsCell: UICollectionViewCell {
  ///String(describing: )
  static let id = "MyRequestsViewCell"
  
  var requesterId = ""
  var targetId = ""
  
  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "profile")
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 40
    
  }
  
  let nameLabel = UILabel().then {
    $0.text = "이지은 -> 박동현"
    $0.textAlignment = .center
    $0.font = .boldSystemFont(ofSize: 18)
  }
  
  let statusLabel = UILabel().then {
    $0.text = "상대방 수락 대기중"
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 16)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .white
    
    configureUI()
  }
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  private func configureUI() {
    
    setupShadow()
    [
      imageView,
      nameLabel,
      statusLabel
    ].forEach { self.addSubview($0) }
    
    imageView.snp.makeConstraints {
      $0.top.equalTo(nameLabel.snp.bottom).offset(6)
      $0.left.equalToSuperview().offset(10)
      $0.width.height.equalTo(80)
    }
    
    nameLabel.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().offset(6)
    }
    
    statusLabel.snp.makeConstraints {
      $0.centerY.equalTo(imageView.snp.centerY)
      $0.right.equalToSuperview().offset(-40)
    }
  }
  
  func configure(imageUrl: String, name: String, requester: String, target: String, status: String) {
    if let url = URL(string: imageUrl) {
      imageView.kf.setImage(with: url)
    }
    nameLabel.text = "나 -> \(name)"
    requesterId = requester
    targetId = target
    if status == "approved" {
      statusLabel.text = "맞나만나 진행중"
    } else {
      statusLabel.text = "상대방 수락 대기중"
    }
  }
}
