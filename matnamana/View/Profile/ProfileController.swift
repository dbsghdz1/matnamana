//
//  ProfileController.swift
//  matnamana
//
//  Created by 김윤홍 on 8/23/24.
import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class ProfileController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

  // MARK: - UI Components
  private var profileView = ProfileUIView()
  private let viewModel = ProfileViewModel()

  // MARK: - Data
  private let userInfoKeys = ["휴대번호", "이메일", "거주지", "생년월일", "직업", "회사명", "최종학력", "대학교"]
  private var userValues = ["", "", "", "", "", "", "", ""]

  // 표시할 항목을 저장할 배열 (파이어베이스 데이터에 따라 변경됨)
  private var visibleUserInfo: [(key: String, value: String)] = []

  // MARK: - Lifecycle
  override func setupView() {
    super.setupView()
    self.view = profileView
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    view.backgroundColor = .white
    profileView.tableView.dataSource = self
    profileView.tableView.delegate = self
    bindProfileData()
  }

  func bindProfileData() {
    let input = ProfileViewModel.Input(fetchProfile: Observable.just(()))
    let output = viewModel.transform(input: input)

    output.profileData
      .drive(onNext: { [weak self] profile in
        guard let self = self else { return }
        self.profileView.nameLabel.text = profile.name
        self.profileView.nickNameLabel.text = "닉네임: \(profile.nickName)"
        self.profileView.introduceLabel.text = profile.shortDescription
        self.profileView.profileImageView.loadImage(from: profile.profileImage)

        // Firebase 데이터로 userValues 업데이트
        self.userValues = [
          profile.phoneNumber,
          profile.email,
          profile.location,
          profile.birth,
          profile.career,
          profile.companyName,
          profile.education,
          profile.university
        ]

        // userValues와 userInfoKeys를 사용하여 표시할 항목만 visibleUserInfo에 저장
        self.visibleUserInfo = zip(self.userInfoKeys, self.userValues)
          .filter { !$0.1.isEmpty } // 값이 빈 문자열이 아닌 것만 포함
        self.profileView.tableView.reloadData()
      })
      .disposed(by: disposeBag)
  }



  override func setNavigation() {
    super.setNavigation()

    let editButton = UIBarButtonItem(title: "수정", style: .plain, target: nil, action: nil)
    navigationItem.rightBarButtonItem = editButton

    editButton.rx.tap
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        self.navigationController?.pushViewController(ProfileEditViewController(), animated: true)
      })
      .disposed(by: disposeBag)
  }

  // MARK: - UITableViewDataSource Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return visibleUserInfo.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let info = visibleUserInfo[indexPath.row]
    cell.textLabel?.text = info.key
    cell.selectionStyle = .none

    // 기존 UILabel 제거 및 직접 추가 (간결화)
    let valueLabel = UILabel()
    valueLabel.text = info.value
    valueLabel.textAlignment = .right
    valueLabel.textColor = .gray

    // 중복 추가 방지
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }

    cell.contentView.addSubview(valueLabel)
    valueLabel.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.centerY.equalToSuperview()
    }

    return cell
  }
}
extension UIImageView {
  func loadImage(from urlString: String) {
    guard let url = URL(string: urlString) else { return }
    DispatchQueue.global().async {
      if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
        DispatchQueue.main.async {
          self.image = image
        }
      }
    }
  }
}

