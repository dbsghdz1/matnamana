//
//  ReplyView.swift
//  matnamana
//
//  Created by pc on 9/12/24.
//

import UIKit
import SnapKit
import Then

final class ReplyView: BaseView {
  
  private let descriptionLabel = UILabel().then {
    let imageAttachment = NSTextAttachment()
    let image = UIImage(systemName: "light.beacon.min")?.withTintColor(.orange, renderingMode:  .alwaysOriginal)
    imageAttachment.image = image
    imageAttachment.bounds = CGRect(x: 0, y: -3, width: 20, height: 20)
    
    let attachmentString = NSAttributedString(attachment: imageAttachment)
    
    let fullString = NSMutableAttributedString()
    fullString.append(attachmentString)
    fullString.append(NSAttributedString(string: "\n"))
    fullString.append(NSAttributedString(string: "작성된 답변은 친구에게 노출되지 않습니다."))
    
    $0.attributedText = fullString
    $0.font = UIFont.headLine()
    $0.textColor = .orange
    $0.numberOfLines = 0
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "박동현님은 어떤 분인가요?"
    $0.font = .boldSystemFont(ofSize: 28)
  }
  
  let tableView = UITableView().then {
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "QuestionCell")
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedRowHeight = 44

  }
  
  let sendButton = UIButton().then {
    $0.setTitle("보내기", for: .normal)
    $0.backgroundColor = .gray
    $0.layer.cornerRadius = 10
    $0.isEnabled = false
  }
  
  func reName(name: String) {
    titleLabel.text = "\(name)님은 어떤 분인가요?"
  }
  
  override func configureUI() {
    super.configureUI()
    [
      descriptionLabel,
      titleLabel,
      tableView,
      sendButton
    ].forEach { self.addSubview($0) }
  }
  
  override func setConstraints() {
    super.setConstraints()
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(146)
      $0.left.equalToSuperview().inset(40)
    }
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(32)
      $0.centerX.equalToSuperview()
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(68)
      $0.left.equalToSuperview().offset(30)
      $0.right.equalToSuperview().offset(-30)
      $0.height.equalTo(300)
    }
    
    sendButton.snp.makeConstraints {
      $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(80)
      $0.height.equalTo(40)
      $0.width.equalTo(200)
      $0.centerX.equalToSuperview()
    }
  }
  
}
