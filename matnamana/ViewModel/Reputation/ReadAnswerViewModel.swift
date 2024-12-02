//
//  ReadAnswerViewModel.swift
//  matnamana
//
//  Created by pc on 9/19/24.
//

import Foundation

import RxCocoa
import RxSwift

final class ReadAnswerViewModel {
  private let db = FirebaseManager.shared.db

  let questionListRelay = BehaviorRelay<[QuestionList]>(value: [])
  
  func fetchQandA(requester: String, target: String) {
    let documentName = "\(requester)-\(target)"
    
    db.collection("reputationRequests").document(documentName)
      .getDocument { [weak self] documentSnapshot, error in
        guard let self else { return }
        do {
          if let reputation = try documentSnapshot?.data(as: ReputationRequest.self) {
            let qandaList = reputation.questionList
            self.questionListRelay.accept(qandaList)
          }
        } catch {
          print(error)
        }
      }
  }
  
  func readFriendId(nickName: String, completion: @escaping (String, Error?) -> Void) {
    
    db.collection("users").whereField("info.name", isEqualTo: nickName )
      .getDocuments { querySnapshot, error in
        if let error = error {
          completion("", error)
          return
        }
        guard let document = querySnapshot?.documents.first else {
          completion("", nil)
          return
        }
        completion(document.documentID, nil)
      }
  }
}
