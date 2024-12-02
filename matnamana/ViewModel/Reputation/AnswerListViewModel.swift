//
//  AnswerListViewModel.swift
//  matnamana
//
//  Created by pc on 9/19/24.
//

import Foundation

import RxCocoa
import RxSwift

final class AnswerListViewModel {
  private let db = FirebaseManager.shared.db
  
  let reputationRequest = BehaviorRelay<[UserProfile]>(value: [])
  
  func fetchFriendList(requester: String, target: String) {
    let documentName = "\(requester)-\(target)"
    
    db.collection("reputationRequests").document(documentName)
      .getDocument { [weak self] documentSnapshot, error in
        guard let self else { return }
        do {
          if let reputation = try documentSnapshot?.data(as: ReputationRequest.self) {
            guard let selectedFriends = reputation.selectedFriends else { return }
            self.reputationRequest.accept(selectedFriends)
            print(reputationRequest.value)
          }
        } catch {
          print(error)
        }
      }
  }
  
  
}
