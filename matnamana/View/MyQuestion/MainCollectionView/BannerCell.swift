//
//  BannerCell.swift
//  matnamana
//
//  Created by 김윤홍 on 9/12/24.
//

import UIKit

import SnapKit
import Then

final class BannerCell: UICollectionViewCell {
  
  private let bannerImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.image = UIImage(named: "fill")
    $0.layer.cornerRadius = 16

  }
  private let label = UILabel().then {
    $0.text = "사람과 사람 사이 긍정적인 영향을 끼칩니다."
    $0.textColor = .white
    $0.font =  UIFont(name: "SFPro-Bold", size: 16)
    $0.textAlignment = .center
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    contentView.addSubview(bannerImageView)
    bannerImageView.addSubview(label)
  }
  
  private func setConstraints() {
    label.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    bannerImageView.snp.makeConstraints {
      $0.horizontalEdges.equalToSuperview().inset(20)
      $0.height.equalTo(120)
    }
  }
}
