////
////  myPageView.swift
////  matnamana
////
////  Created by 이진규 on 9/13/24.
////

import UIKit

import SnapKit
import Then

final class MyPageView: BaseView {
  // MARK: - UI Components

  let myPageButton = UIButton(type: .system).then {
    var configuration = UIButton.Configuration.filled()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 35, bottom: 25, trailing: 35)
    configuration.baseBackgroundColor = .clear
    configuration.background.cornerRadius = 16
    $0.configuration = configuration
    // 테두리 설정
    $0.layer.cornerRadius = 16
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.clipsToBounds = false // 그림자가 보이도록 설정
  }

  let profileImageView = UIImageView().then {
    $0.image = UIImage(named: "profile")
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
    $0.layer.cornerRadius = 50
    $0.layer.masksToBounds = true
  }

  let nameLabel = UILabel().then {
    $0.text = "김민지"
    $0.font = UIFont.boldSystemFont(ofSize: 18)
    $0.textAlignment = .center
  }

  let nicknameLabel = UILabel().then {
    $0.text = "(minji)"
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.textColor = .gray
    $0.textAlignment = .center
  }

  let frindcount = UILabel().then {
    $0.text = "친구 0명"
    $0.font = UIFont.boldSystemFont(ofSize: 14)
    $0.textAlignment = .center
  }

  let introduceLabel = UILabel().then {
    $0.text = "공부하는 직장인"
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.textAlignment = .center
  }

  let tableView = UITableView().then {
    $0.register(myPageCell.self, forCellReuseIdentifier: String(describing: myPageCell.self))
    $0.rowHeight = 48
  }

  // MARK: - Initialization
  override func configureUI() {
    [profileImageView, nameLabel, nicknameLabel, frindcount, introduceLabel].forEach { myPageButton.addSubview($0) }

    // `myPageButton`을 테이블 뷰의 헤더로 설정
    tableView.tableHeaderView = myPageButton


    // 테이블 뷰 추가
    self.addSubview(tableView)
  }

  override func setConstraints() {
    // `myPageButton`의 레이아웃 설정
    myPageButton.snp.makeConstraints {

      $0.centerX.equalToSuperview()
      $0.height.equalTo(self.frame.height * 0.35) // 버튼의 고정 높이 설정
      $0.width.equalToSuperview().multipliedBy(0.6)
    }

    // 이미지와 레이블의 레이아웃 설정
    profileImageView.snp.makeConstraints {
      $0.top.equalTo(myPageButton.snp.top).offset(20)
      $0.centerX.equalTo(myPageButton.snp.centerX)
      $0.width.height.equalTo(100)
    }

    nameLabel.snp.makeConstraints {
      $0.top.equalTo(profileImageView.snp.bottom).offset(10)
      $0.centerX.equalTo(myPageButton.snp.centerX)
    }

    nicknameLabel.snp.makeConstraints {
      $0.top.equalTo(nameLabel.snp.bottom).offset(5)
      $0.centerX.equalTo(myPageButton.snp.centerX)
    }

    frindcount.snp.makeConstraints {
      $0.top.equalTo(nicknameLabel.snp.bottom).offset(5)
      $0.centerX.equalTo(myPageButton.snp.centerX)
    }

    introduceLabel.snp.makeConstraints {
      $0.top.equalTo(frindcount.snp.bottom).offset(5)
      $0.centerX.equalTo(myPageButton.snp.centerX)
    }

    // 테이블 뷰의 레이아웃 설정
    tableView.snp.makeConstraints {
      $0.edges.equalTo(safeAreaLayoutGuide)
    }

    // 테이블 헤더뷰를 새로 레이아웃하기 위한 강제 레이아웃
    tableView.layoutIfNeeded()
  }

  // MARK: - Override layoutSubviews to Apply Gradient
  override func layoutSubviews() {
    super.layoutSubviews()

    // 버튼의 크기와 레이아웃 변경이 완료된 후에 그림자 및 그라데이션 설정
    DispatchQueue.main.async {
      self.applyGradientToButton(self.myPageButton)
    }
  }

  private func applyGradientToButton(_ button: UIButton) {
    // 이미 존재하는 그라데이션 레이어 제거 (중복 방지)
    button.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

    // 그라데이션 레이어 설정
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
      UIColor.white.cgColor,
      UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1).cgColor
    ]
    gradientLayer.locations = [0, 1]
    gradientLayer.startPoint = CGPoint(x: 0.25, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.75, y: 1)
    gradientLayer.frame = button.bounds
    gradientLayer.cornerRadius = 16

    // 버튼의 레이어에 그라데이션 추가
    button.layer.insertSublayer(gradientLayer, at: 0)

    // 그림자 설정
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOpacity = 0.25
    button.layer.shadowOffset = CGSize(width: 0, height: 4)
    button.layer.shadowRadius = 4

    // 그림자의 경로를 버튼의 현재 크기에 맞게 설정
    button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
    button.layer.masksToBounds = false
  }
}
//tableView(<#T##UITableView#>, titleForFooterInSection: <#T##Int#>)
