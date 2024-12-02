//
//  AcceptRequestViewModel.swift
//  matnamana
//
//  Created by pc on 9/9/24.
//

import Foundation

import RxCocoa
import RxSwift

final class AcceptRequestViewModel {
  
  
  
  var currentname = BehaviorRelay<String>(value: "")
  var selectedItems = BehaviorRelay<[String]>(value: [])
  var friendList = BehaviorRelay<[User]>(value: [])
  
  var disposeBag = DisposeBag()
  
  init() {
    // friendList의 변화 감지 및 count가 2일 때 실행
    friendList
      .map { $0.count } // friendList의 count를 감지
      .filter { $0 == 2 } // count가 2가 되면 진행
      .subscribe(onNext: { [weak self] _ in
        self?.sendReputationRequest()
      })
      .disposed(by: disposeBag)
  }
  
  private let db = FirebaseManager.shared.db
  
  private let reputationView = ReputationView()
  private let friendListView = FriendListView()
  
  private var requesterId: String?
  private var targetId: String?
  
  func selectItem(selectedFriends: String) {
    var currentItems = selectedItems.value
    currentItems.append(selectedFriends)
    selectedItems.accept(currentItems)
  }
  
  func removeItem(at indexPath: IndexPath, selectedFriends: String) {
    var currentItems = selectedItems.value
    if let index = currentItems.firstIndex(of: selectedFriends) {
      currentItems.remove(at: index)
      selectedItems.accept(currentItems)
      friendListView.friendList.deselectRow(at: indexPath, animated: true)
    }
  }
  
  func removeFirstItem() {
    var currentItems = selectedItems.value
    currentItems.remove(at: 0)
    selectedItems.accept(currentItems)
  }
  
  func selectName(_ name: String) {
    currentname.accept(name)
    print(name)
  }
  
  func sendData(requester: String, target: String) {
    print(selectedItems.value)
    requesterId = requester
    targetId = target
//    let documentId = "\(requester)-\(target)"
    
    for selectedItem in selectedItems.value {
      print(selectedItem)
      
      db.collection("users").whereField("info.name", isEqualTo: selectedItem)
        .getDocuments { [weak self] querySnapshot, error in
          guard let self = self else { return }
          guard let querySnapshot,
                error == nil
          else { return }
          
          if let document = querySnapshot.documents.first {
            do {
              let user = try document.data(as: User.self)
              print(user)
              
              // friendList 업데이트
              var currentFriendList = self.friendList.value
              currentFriendList.append(user)
              self.friendList.accept(currentFriendList) // BehaviorRelay 업데이트
              
            } catch {
              print("Error decoding user: \(error)")
            }
          }
        }
    }
  }
  
  // friendList count가 2가 되면 실행될 메서드
  private func sendReputationRequest() {
    guard let requester = requesterId,
          let target = targetId else { return }
    
    let documentId = "\(requester)-\(target)"
    
    db.collection("reputationRequests").document(documentId)
      .updateData([
        "selectedFriends": friendList.value.map { friend in
          [
            "nickName": friend.info.name,
            "profileImage": friend.info.profileImage,
            "userId": friend.userId
          ]
        },
        "selectedFriendsUserIds": friendList.value.map { $0.userId }
      ]) { error in
        if let error = error {
          print("Error updating reputationRequests: \(error)")
        } else {
          print("Reputation request successfully updated")
        }
      }
    
  }
  
  func updateStatus(requester: String, target: String) {
    let docId = "\(requester)-\(target)"
    db.collection("reputationRequests").document(docId)
      .updateData([
        "status": "approved"
      ])
  }
  
}
