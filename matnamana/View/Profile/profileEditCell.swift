//
//  profileEditTable.swift
//  matnamana
//
//  Created by 이진규 on 9/3/24.
//

import UIKit

final class ProfileEditCell: UITableViewCell {
  
  // MARK: - UI Components
  let textField: UITextField = {
    let textField = UITextField()
    textField.clearButtonMode = .always
    textField.placeholder = "Value"
    return textField
  }()
  
  // MARK: - Initializers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup UI
  private func setupUI() {
    contentView.addSubview(textField)
    textField.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.centerY.equalToSuperview()
      $0.width.equalTo(200)
    }
  }
  

}
