//
//  ReadAnswerView.swift
//  matnamana
//
//  Created by pc on 9/14/24.
//

import UIKit

import Then
import SnapKit

final class ReadAnswerView: BaseView {
  
  private let titleLabel = UILabel().then {
    $0.text = "님의 답변입니다!"
    $0.font = .boldSystemFont(ofSize: 28)
  }
  
  var tableVIew = UITableView().then {
    $0.register(QandACell.self, forCellReuseIdentifier: String(describing: QandACell.self))
    $0.estimatedRowHeight = 100
    $0.rowHeight = 70
  }

  
  func reName(name: String) {
    titleLabel.text = "\(name)님의 답변입니다!"
  }
  
  override func configureUI() {
    super.configureUI()
    [
      titleLabel,
      tableVIew
    ].forEach { self.addSubview($0) }
  }
  
  override func setConstraints() {
    super.setConstraints()
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(self.safeAreaLayoutGuide)
      $0.centerX.equalToSuperview()
    }
    tableVIew.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(100)
      $0.leading.equalToSuperview().offset(40)
      $0.trailing.equalToSuperview().inset(40)
      $0.height.equalTo(400)
    }

  }
  
  
  
}
