//
//  AnswerListView.swift
//  matnamana
//
//  Created by pc on 9/17/24.
//

import UIKit

import Then
import SnapKit

final class AnswerListView: BaseView {
  
  let backgroundView = UIView().then {
    $0.backgroundColor = .black.withAlphaComponent(0.5)
    $0.isHidden = true
  }
  let reputationReview = ReputationReviewView()
  
  private let descriptionLabel = UILabel().then {
    let imageAttachment = NSTextAttachment()
    let image = UIImage(systemName: "light.beacon.min")?.withTintColor(.orange, renderingMode:  .alwaysOriginal)
    imageAttachment.image = image
    imageAttachment.bounds = CGRect(x: 0, y: -3, width: 20, height: 20)
    
    let attachmentString = NSAttributedString(attachment: imageAttachment)
    
    let fullString = NSMutableAttributedString()
    fullString.append(attachmentString)
    fullString.append(NSAttributedString(string: "\n"))
    fullString.append(NSAttributedString(string: "작성된 답변은 상대방에게 노출되지 않습니다."))
    
    $0.attributedText = fullString
    $0.font = UIFont.headLine()
    $0.textColor = .orange
    $0.numberOfLines = 0
  }
  
  var tableView = UITableView().then {
    $0.register(AnswerListCell.self, forCellReuseIdentifier: String(describing: AnswerListCell.self))
    $0.rowHeight = 70
  }
  
  let button = UIButton(type: .system).then {
    $0.setTitle("확인완료", for: .normal)
    $0.backgroundColor = .manaMainColor
    $0.setTitleColor(.white, for: .normal)
    $0.layer.cornerRadius = 15
  }
  
  override func configureUI() {
    super.configureUI()
    [
      descriptionLabel,
      tableView,
      button,
      backgroundView
    ].forEach { self.addSubview($0) }
    backgroundView.addSubview(reputationReview)
  }
  
  override func setConstraints() {
    super.setConstraints()
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(146)
      $0.left.equalToSuperview().inset(40)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(100)
      $0.horizontalEdges.equalToSuperview().inset(40)
      $0.bottom.equalTo(button.snp.top)
    }
    
    button.snp.makeConstraints {
      $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(50)
      $0.width.equalTo(160)
      $0.height.equalTo(40)
      $0.centerX.equalToSuperview()
    }
    
    backgroundView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    reputationReview.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
}
