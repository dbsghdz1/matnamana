//
//  ProfileEditViewController.swift
//  matnamana
//
//  Created by 이진규 on 8/30/24.
// 키보드올라올때 화면 올라가게
//

import UIKit
import SnapKit

final class ProfileEditView: UIView {

  // MARK: - UI Components
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "profile")
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 75
    imageView.clipsToBounds = true
    imageView.isUserInteractionEnabled = true
    return imageView
  }()

  let nameTextField: UILabel = {
    let label = UILabel()
    label.text = "김민지"
    label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    return label
  }()

  // 스택뷰를 생성하여 profileImageView와 nameTextField를 담을 컨테이너로 사용
  private let headerStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = 20
    return stackView
  }()

  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.register(ProfileEditCell.self, forCellReuseIdentifier: String(describing: ProfileEditCell.self))
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 44
    return tableView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    setConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {
    // 스택뷰에 프로필 이미지와 이름 텍스트 필드 추가
    [profileImageView, nameTextField].forEach {
      headerStackView.addArrangedSubview($0)
    }

    // 테이블뷰의 헤더로 스택뷰를 설정
    tableView.tableHeaderView = headerStackView

    // 뷰에 테이블뷰 추가
    addSubview(tableView)
  }

  private func setConstraints() {
    // 스택뷰의 레이아웃 설정 (필수)
    profileImageView.snp.makeConstraints{
      $0.width.height.equalTo(150)
    }  

    headerStackView.snp.makeConstraints {
      $0.width.equalToSuperview()
    }

    // 테이블뷰의 레이아웃 설정
    tableView.snp.makeConstraints {
      $0.edges.equalTo(safeAreaLayoutGuide)
    }

    // 레이아웃 업데이트를 위해 호출
    layoutIfNeeded()
  }
}
