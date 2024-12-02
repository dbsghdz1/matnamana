//
//  File.swift
//  matnamana
//
//  Created by 김윤홍 on 9/4/24.
//

import UIKit

import SnapKit
import Then

final class TotalQuestionView: UIView {
  
  let questionList = UITableView().then {
    $0.register(QuestionListCell.self, forCellReuseIdentifier: String(describing: QuestionListCell.self))
    $0.rowHeight = 80
  }
  
  let questionSegement = UISegmentedControl(items: ["팩트 질문", "가치관 질문", "커리어 질문"]).then {
    $0.selectedSegmentIndex = 0
    $0.selectedSegmentTintColor = .manaMainColor
    $0.backgroundColor = .white
    let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    $0.setTitleTextAttributes(titleTextAttributes, for: .normal)
    let titleTextAttributes2 = [NSAttributedString.Key.foregroundColor: UIColor.white]
    $0.setTitleTextAttributes(titleTextAttributes2, for: .selected)
    
    $0.layer.cornerRadius = CGRectGetHeight($0.bounds) / 2
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.borderWidth = 1
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
    [
      questionSegement,
      questionList
    ].forEach { self.addSubview($0) }
  }
  
  private func setConstraints() {
    
    questionSegement.snp.makeConstraints {
      $0.top.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(10)
      $0.height.equalTo(40)
    }
    
    questionList.snp.makeConstraints {
      $0.top.equalTo(questionSegement.snp.bottom).offset(10)
      $0.bottom.equalTo(self.safeAreaLayoutGuide)
      $0.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(20)
    }
    
//    customButton.snp.makeConstraints {
//      $0.bottom.equalTo(questionSegement.snp.top).offset(20)
//      $0.trailing.equalToSuperview().inset(20)
//      $0.height.width.equalTo(50)
//    }
  }
}
