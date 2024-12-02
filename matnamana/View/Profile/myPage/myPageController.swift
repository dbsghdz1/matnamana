//
//  myPageController.swift
//  matnamana
//
//  Created by 이진규 on 9/13/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class myPageController: BaseViewController {
  let myPageTable = [//"나의 히스토리",
    "공지", "자주 묻는 질문", "맞나만나에 문의하기", "맞나만나 정보"]

  var myPageView = MyPageView(frame: .zero)
  
  override func setupView() {
    super.setupView()
    myPageView = MyPageView(frame: UIScreen.main.bounds)
    self.view = myPageView
  }
  override func viewWillAppear(_ animated: Bool) {
    bindMyInfo()
    
    func fetchUserInfo() -> Observable<User.Info> {
      guard let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") else {
        return .empty()
      }
      
      return Observable.create { observer in
        FirebaseManager.shared.readUser(documentId: loggedInUserId) { user, error in
          if let error = error {
            observer.onError(error)
          } else if let user = user {
            observer.onNext(user.info)
            observer.onCompleted()
          } else {
            observer.onError(NSError(domain: "UserNotFound", code: -1, userInfo: nil))
          }
        }
        return Disposables.create()
      }
    }
    
    func bindMyInfo() {
      fetchUserInfo()
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] userInfo in
          guard let self = self else { return }
          self.myPageView.nameLabel.text = userInfo.name
          self.myPageView.nicknameLabel.text = "(\(userInfo.nickName))"
          self.myPageView.introduceLabel.text = userInfo.shortDescription
          self.myPageView.profileImageView.loadImage(from: userInfo.profileImage)
        }, onError: { error in
          print("Error fetching user info: \(error)")
        })
        .disposed(by: disposeBag)
    }
  }
  
  override func bind() {
    super.bind()
    bindTableView()
    
    myPageView.myPageButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.navigationController?.pushViewController(ProfileController(), animated: true)
      }).disposed(by: disposeBag)
    
  }
  
  
  
  private func bindTableView() {
    myPageView.tableView.dataSource = self
    myPageView.tableView.delegate = self
  }
}

extension myPageController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    switch indexPath.row {
    case 0:
      if let url = URL(string: "https://matnamana.com/notice/") {  UIApplication.shared.open(url, options: [:])
      }
    case 1:
      if let url = URL(string: "https://matnamana.com/faq/") {  UIApplication.shared.open(url, options: [:])
      }
    case 2:
      if let url = URL(string: "https://matnamana.com/contact/") {  UIApplication.shared.open(url, options: [:])
      }
    case 3:
      let myPageInfoController = MyPageInfoController()
      self.navigationController?.pushViewController(myPageInfoController, animated: true)
    default:
      print(indexPath.row)
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    myPageTable.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: myPageCell.self), for: indexPath) as? myPageCell else {
      return UITableViewCell()
    }
    
    let cellText = myPageTable[indexPath.row]
    cell.configureCell(myPageCell: cellText) // 셀에 텍스트 설정
    return cell
  }
}
