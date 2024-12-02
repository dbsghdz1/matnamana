//
//  ReputaionModel.swift
//  matnamana
//
//  Created by pc on 9/7/24.
//

import Foundation

import RxCocoa
import RxSwift

final class ReputationViewModel: ViewModelType {
  
  struct Input {
    let refreshGesture: ControlProperty<CGPoint>
  }
  
  struct Output {
    let fetchTrigger: Observable<Void>
  }
  
  var friendReputationDataRelay = BehaviorRelay(value: [(String, String, String, String)]())
  var myRequestedReputationDataRelay = BehaviorRelay(value: [(String, String, String, String, String)]())
  var receivedReputationDataRelay = BehaviorRelay(value: [(String, String, String, String, String)]())
  
  func deleteReputation(requester: String, target: String) {
    let docId = "\(requester)-\(target)"
    FirebaseManager.shared.db.collection("reputationRequests").document(docId)
      .delete { error in
        if error != nil {
          print("삭제 실패")
        } else {
          print("삭제 성공")
        }
        
      }
  }
  
  func fetchReputationInfo() {
    guard let userId = UserDefaults.standard.string(forKey: "loggedInUserId") else { return }
    FirebaseManager.shared.fetchReputationInfo(userId: userId) { reputationRequests, error in
      if error != nil {
        print("error")
      }
      guard let reputationRequests else { return }
      
      var friendReputationData: [(String, String, String, String)] = []
      var myRequestedReputationData: [(String, String, String, String, String)] = []
      var receivedReputationData: [(String, String, String, String, String)] = []

      for reputationRequest in reputationRequests {
        
        guard let target = reputationRequest.target,
              let requester = reputationRequest.requester,
              let selectedFriends = reputationRequest.selectedFriends
        else { return }
        
        let requesterId = requester.userId ?? ""
        let targetId = target.userId ?? ""
        
        if userId == target.userId {
          let profileImage = requester.profileImage ?? ""
          let nickName = requester.nickName ?? ""
          let status = reputationRequest.status.rawValue
          receivedReputationData.append((profileImage, nickName, requesterId, targetId, status))
        }
        
        if userId == requester.userId {
          let profileImage = target.profileImage ?? ""
          let nickName = target.nickName ?? ""
          let status = reputationRequest.status.rawValue
          myRequestedReputationData.append((profileImage, nickName, requesterId, targetId, status))
        }
        
        if selectedFriends.contains(where: { $0.userId == userId }) {
          let profileImage = target.profileImage ?? ""
          let nickName = target.nickName ?? ""
          
          friendReputationData.append((profileImage, nickName, requesterId, targetId))
        }

        self.friendReputationDataRelay.accept(friendReputationData)
        self.receivedReputationDataRelay.accept(receivedReputationData)
        self.myRequestedReputationDataRelay.accept(myRequestedReputationData)
      }
    }
  }
  
  func transform(input: Input) -> Output {
    
    let fetchTrigger = input.refreshGesture
      .filter { $0.y < -100 }
      .map { _ in () }
    
    return Output(fetchTrigger: fetchTrigger)
  }
  
}



