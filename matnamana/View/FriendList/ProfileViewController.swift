//
//  ProfileViewController.swift
//  matnamana
//
//  Created by 김윤홍 on 8/29/24.
//

import UIKit

import RxCocoa
import RxSwift

final class ProfileViewController: BaseViewController {
  
  private var profileView = ProfileView(frame: .zero)
  private var viewModel = UserProfileViewModel()
  var userInfo: String
  var userImage: String?
  var isCellClicked: Bool
  var sendId: String?
  
  init(userInfo: String,
       isCellClicked: Bool,
       sendId: String?
  ) {
    self.userInfo = userInfo
    self.isCellClicked = isCellClicked
    self.sendId = sendId
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupView() {
    super.setupView()
    profileView = ProfileView(frame: UIScreen.main.bounds)
    self.view = profileView
  }
  
  override func bind() {
    super.bind()
    buttonClicked()
    let input = UserProfileViewModel.Input(fetchUser: Observable.just(()), nickName: userInfo)
    let output = viewModel.transform(input: input)
    
    guard let userId = UserDefaults.standard.string(forKey: "loggedInUserId") else { return }
    FirebaseManager.shared.readUser(documentId: userId) { [weak self] documentSnapshot, error in
      guard let self else { return }
      guard let snapshot = documentSnapshot else { return }
      let isFriend = snapshot.friendList.contains { $0.friendId == self.userInfo && $0.status != .rejected }
      
      
      
      if isCellClicked {
        self.profileView.requestFriend.isHidden = true
      } else {
        if self.userInfo == snapshot.info.nickName {
          self.profileView.requestFriend.isHidden = true
          self.profileView.requestReference.isHidden = true
          self.profileView.deleteFriend.isHidden = true
        } else if isFriend {
          self.profileView.requestFriend.isHidden = true
        } else {
          self.profileView.deleteFriend.isHidden = true
        }
      }
    }
    
    output.userInfo
      .drive(onNext: { [weak self] userInfo in
        guard let self else { return }
        self.userImage = userInfo.profileImage
        self.profileView.configureUI(imageURL: userInfo.profileImage,
                                     userName: userInfo.name,
                                     nickName: userInfo.nickName,
                                     shortDescription: userInfo.shortDescription
        )
      })
      .disposed(by: disposeBag)
    
    output.userInfoWithName
      .drive(onNext: { [weak self] userInfo in
        guard let self else { return }
        self.sendId = userInfo.nickName
        self.userImage = userInfo.profileImage
        self.profileView.configureUI(imageURL: userInfo.profileImage,
                                     userName: userInfo.name,
                                     nickName: userInfo.nickName,
                                     shortDescription: userInfo.shortDescription)
      }).disposed(by: disposeBag)
    
    output.friendCount
      .drive(onNext: { [weak self] friendList in
        guard let self else { return }
        if friendList.count > 100 {
          self.profileView.configureFriendCount(friendCount: friendList.count, friendCountLabel: "+")
        } else if friendList.count > 50 {
          self.profileView.configureFriendCount(friendCount: friendList.count, friendCountLabel: "+")
        } else if friendList.count > 10 {
          self.profileView.configureFriendCount(friendCount: friendList.count, friendCountLabel: "+")
        } else {
          self.profileView.configureFriendCount(friendCount: friendList.count, friendCountLabel: "명")
        }
        print(friendList.count)
      }).disposed(by: disposeBag)
  }
  
  private func buttonClicked() {
    profileView.requestFriend.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        guard let userImage = self.userImage else { return }
        let modalVC = AddFriendViewController(userInfo: self.userInfo,
                                              userImage: userImage,
                                              userName: profileView.userName.text ?? "") {
          self.navigationController?.popViewController(animated: true)
        }
        
        modalVC.modalPresentationStyle = .overFullScreen
        self.present(modalVC, animated: true)
      }).disposed(by: disposeBag)
    
    profileView.deleteFriend.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        
        // 알림 생성
        let alertController = UIAlertController(title: "친구를 해제하시겠어요?", message: "상대방 친구목록에서도 삭제됩니다.", preferredStyle: .alert)
        
        // 확인 버튼 추가
        let confirmAction = UIAlertAction(title: "확인", style: .destructive) { _ in
          // 확인을 누르면 아래 로직이 실행됩니다.
          guard let id = UserDefaults.standard.string(forKey: "loggedInUserId") else { return }
          
          FirebaseManager.shared.readUser(documentId: id) { user, error in
            guard let user = user else { return }
            var friendList = user.friendList
            var friendNickName = ""
            
            // 친구 리스트 상태 업데이트
            friendList = friendList.map {
              var friend = $0
              if friend.friendId == self.userInfo || friend.name == self.userInfo {
                friend.status = .rejected
              }
              return friend
            }
            
            // 비동기 작업 완료 클로저
            let completion: () -> Void = {
              // 모든 작업이 완료되었을 때 navigation pop
              self.navigationController?.popViewController(animated: true)
            }
            
            // 한국어 사용자 이름인지 확인하여 처리
            if self.isKorean(self.userInfo) {
              FirebaseManager.shared.getUserInfoWithName(name: self.userInfo) { user, error in
                guard let user = user else { return }
                friendNickName = user.info.nickName
                
                FirebaseManager.shared.deleteFriendList(userId: id, newFriendList: friendList, friendId: friendNickName) { success, error in
                  if let error = error {
                    print(error)
                  } else {
                    print("성공")
                    completion()
                  }
                }
              }
            } else {
              FirebaseManager.shared.deleteFriendList(userId: id, newFriendList: friendList, friendId: self.userInfo) { success, error in
                if let error = error {
                  print(error)
                } else {
                  completion()
                }
              }
            }
          }
        }
        
        // 취소 버튼 추가
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // 액션을 알림에 추가
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        // 알림 표시
        self.present(alertController, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    profileView.requestReference.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        let targetId = self.userInfo
        if isCellClicked {
          if let sendId = sendId {
            self.navigationController?.pushViewController(RequestMyQuestionController(targetId: sendId), animated: true)
          }
        } else {
          self.navigationController?.pushViewController(RequestMyQuestionController(targetId: targetId), animated: true)
        }
      }).disposed(by: disposeBag)
  }
  
  func isKorean(_ text: String) -> Bool {
    for scalar in text.unicodeScalars {
      if !(scalar.value >= 0xAC00 && scalar.value <= 0xD7A3) {
        return false
      }
    }
    return true
  }
}
