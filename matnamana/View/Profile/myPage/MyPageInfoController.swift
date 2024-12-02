////
////  MyPageInfoController.swift
////  matnamana
////
////  Created by 이진규 on 9/19/24.
////

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import FirebaseFirestore
import FirebaseAuth



final class MyPageInfoController: BaseViewController {
  let mypageInfoTable = ["이용약관", "개인정보처리방침", "로그아웃", "맞나만나 탈퇴하기"]
  var mypageInfoView = MyPageInfoView(frame: .zero)
  
  override func setupView() {
    super.setupView()
    mypageInfoView = MyPageInfoView(frame: UIScreen.main.bounds)
    self.view = mypageInfoView
    self.navigationItem.title = "맞나만나 정보"
  }
  
  override func bind() {
    super.bind()
    bindTableView()
  }
  
  private func bindTableView() {
    mypageInfoView.tableView.dataSource = self
    mypageInfoView.tableView.delegate = self
  }
  
  enum ActionType {
    case ok
    case cancel
  }
  
  // 로그아웃 확인 알림창을 띄우는 함수
  private func showLogoutAlert() -> Observable<ActionType> {
    return Observable.create { [weak self] observer in
      let alertController = UIAlertController(title: "로그아웃 확인", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
      
      let logoutAction = UIAlertAction(title: "로그아웃", style: .destructive) { _ in
        // 로그아웃 이벤트 전달
        observer.onNext(.ok)
        observer.onCompleted()
      }
      
      let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
        // 취소 이벤트 전달
        observer.onNext(.cancel)
        observer.onCompleted()
      }
      
      alertController.addAction(logoutAction)
      alertController.addAction(cancelAction)
      
      self?.present(alertController, animated: true, completion: nil)
      
      return Disposables.create {
        alertController.dismiss(animated: true, completion: nil)
      }
    }
  }
  // 로그아웃 함수
  private func logOutTapped() {
    // showLogoutAlert() 호출 후 반드시 구독(subscribe)하여 결과를 처리해야 합니다.
    showLogoutAlert()
      .subscribe(onNext: { action in
        switch action {
        case .ok:
          // UserDefaults에 로그아웃 상태 저장
          UserDefaults.standard.set(false, forKey: "isLoggedIn")
          // UIWindow를 가져와서 LoginController로 화면 전환
          if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let window = scene.windows.first {
            window.rootViewController = UINavigationController(rootViewController: LoginController())
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
          }
        case .cancel:
          print("로그아웃 취소")
        }
      })
      .disposed(by: disposeBag)  // disposeBag을 사용해 메모리 관리를 합니다.
  }
  
  private func showDeleteUserIdAlert() -> Observable<ActionType> {
    return Observable.create { [weak self] observer in
      let alertController = UIAlertController(title: "맞나만나를 탈퇴하시겠어요?", message: "탈퇴 시, 모든 정보는 삭제됩니다.", preferredStyle: .alert)
      
      let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
        observer.onNext(.cancel)
        observer.onCompleted()
      }
      
      let deleteUserIdAction = UIAlertAction(title: "탈퇴하기", style: .destructive) { _ in
        observer.onNext(.ok)
        observer.onCompleted()
      }
      
      alertController.addAction(deleteUserIdAction)
      alertController.addAction(cancelAction)
      
      self?.present(alertController, animated: true, completion: nil)
      
      return Disposables.create {
        alertController.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  private func deleteUserId() {
    // showDeleteUserIdAlert() 호출 후 반드시 구독(subscribe)하여 결과를 처리해야 합니다.
    showDeleteUserIdAlert()
      .subscribe(onNext: { [weak self] action in
        switch action {
        case .ok:
          self?.performUserDeletion()  // Firebase 또는 서버에서 회원 탈퇴 처리
        case .cancel:
          print("회원 탈퇴 취소")
        }
      })
      .disposed(by: disposeBag)  // disposeBag을 사용해 메모리 관리를 합니다.
  }
  
  // 실제 Firebase에서 유저 정보를 삭제하는 함수
  private func performUserDeletion() {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    let db = Firestore.firestore()
    
    // Firestore에서 사용자 문서 삭제
    db.collection("users").document(userId).delete { error in
      if let error = error {
        print("회원 탈퇴 중 오류 발생: \(error.localizedDescription)")
      } else {
        print("회원 탈퇴가 완료되었습니다.")

        UserDefaults.standard.set(false, forKey: "isLoggedIn")

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
          window.rootViewController = UINavigationController(rootViewController: LoginController())
          UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        } // 회원 탈퇴 후 로그아웃 처리
      }
    }
  }
  
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension MyPageInfoController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    case 0:
      if let url = URL(string: "https://matnamana.com/policy/") {
        UIApplication.shared.open(url, options: [:])
      }
    case 1:
      if let url = URL(string: "https://matnamana.com/privacy/") {
        UIApplication.shared.open(url, options: [:])
      }
    case 2:
      logOutTapped() // 로그아웃 선택 시 알림창 띄움
    case 3:
      deleteUserId() // 회원 탈퇴 선택 시 알림창 띄움
    default:
      print(indexPath.row)
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return mypageInfoTable.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MypageInfoCell.self), for: indexPath) as? MypageInfoCell else {
      return UITableViewCell()
    }
    let cellText = mypageInfoTable[indexPath.row]
    cell.configureCell(myPageInfoCell: cellText)
    return cell
  }
}
