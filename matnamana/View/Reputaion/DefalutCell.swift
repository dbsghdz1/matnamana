//
//  defalutCell.swift
//  matnamana
//
//  Created by pc on 9/11/24.
//

import UIKit

import SnapKit
import Then

final class DefaultCell: UICollectionViewCell {
  ///String(describing: )
  static let id = "DefaultCell"
  
  let label = UILabel().then {
    $0.text = "이지은 -> 박동현"
    $0.textAlignment = .center
    $0.font = .boldSystemFont(ofSize: 22)
    $0.numberOfLines = 2
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .white
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    setupShadow()
    [
      label,
    ].forEach { self.addSubview($0) }
    
    
    label.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.left.equalToSuperview().offset(10)
      $0.right.equalToSuperview().offset(-10)
    }
    
  }
  func configure(text: String) {
    label.text = text
  }
}
