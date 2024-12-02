//
//  ReceivedRequestCollectionViewCell.swift
//  matnamana
//
//  Created by pc on 9/6/24.
//
import UIKit

import RxSwift
import Kingfisher
import SnapKit
import Then

final class ReceivedRequestCell: UICollectionViewCell {
  ///String(describing: )
  static let id = "ReceivedRequestViewCell"
  
  var disposeBag = DisposeBag()
  
  var requesterId = ""
  var targetId = ""
  
  
  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "profile")
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 40
  }
  
  private let nameLabel = UILabel().then {
    $0.text = "이지은 -> 박동현"
    $0.textAlignment = .center
    $0.font = .boldSystemFont(ofSize: 18)
  }
  
  private let statusLabel = UILabel().then {
    $0.text = "평판조회를 요청받았습니다."
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 16)
  }
  
  let acceptButton = UIButton().then {
    $0.setTitle("수락하기", for: .normal)
    $0.titleLabel?.font = UIFont.subHeadLine()
    $0.backgroundColor = .manaMainColor
    $0.layer.cornerRadius = 16
  }
  let cancelButton = UIButton().then {
    $0.setTitle("무시하기", for: .normal)
    $0.titleLabel?.font = UIFont.subHeadLine()
    $0.backgroundColor = .lightGray
    $0.layer.cornerRadius = 16
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
    $0.distribution = .fillEqually
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    // 재사용될 때 disposeBag 초기화
    disposeBag = DisposeBag()
  }
  
  private func configureUI() {
    setupShadow()
    [
      acceptButton,
      cancelButton
    ].forEach { buttonStackView.addArrangedSubview($0) }
    
    [
      imageView,
      nameLabel,
      statusLabel,
      buttonStackView
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
    
    buttonStackView.snp.makeConstraints {
      $0.top.equalTo(statusLabel.snp.bottom).offset(10)
      $0.centerX.equalTo(statusLabel.snp.centerX)
      $0.leading.trailing.equalTo(statusLabel)
    }
  }
  
  func configure(imageUrl: String, name: String, requester: String, target: String, status: String) {
    if let url = URL(string: imageUrl) {
      imageView.kf.setImage(with: url)
    }
    nameLabel.text = "\(name) -> 나"
    requesterId = requester
    targetId = target
    
    if status == "approved" {
      statusLabel.text = "맞나만나가 진행중입니다."
      cancelButton.isHidden = true
      acceptButton.isHidden = true
    } else {
      statusLabel.text = "맞나만나를 요청받았습니다."
      cancelButton.isHidden = false
      acceptButton.isHidden = false
    }
  }
}
