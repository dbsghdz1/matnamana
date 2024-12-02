//
//  NetworkManager.swift
//  matnamana
//
//  Created by 김윤홍 on 8/28/24.
//

import FirebaseCore
import FirebaseFirestore

import RxCocoa
import RxSwift

final class FirebaseManager {
  
  static let shared = FirebaseManager()
  private init() {}
  let db = Firestore.firestore()
  
  enum CollectionName: String {
    case user = "users"
    case reputationRequest = "reputationRequests"
    case question = "questions"
    case answer = "answers"
    
    var title: Any {
      switch self {
      case .user: return User.self
      case .reputationRequest: return ReputationRequest.self
      case .question: return Question.self
      case .answer: return Answer.self
      }
    }
  }
  
  func addData<T: Codable>(to collectionName: CollectionName, data: T, documentId: String) {
    if let dataDictionary = data.asDictionary {
      db.collection(collectionName.rawValue).document(documentId).setData(dataDictionary) { error in
        if let error = error {
          print("\(collectionName.rawValue) 추가 실패: \(error.localizedDescription)")
        } else {
          print("\(collectionName.rawValue) 추가 성공")
        }
      }
    } else {
      print("\(collectionName.rawValue) 데이터 변환 실패")
    }
  }
  
  func updateField(in collectionName: CollectionName, documentId: String, field: String, value: Any, completion: @escaping (Bool, Error?) -> Void) {
    db.collection(collectionName.rawValue).document(documentId).updateData([field: value]) { error in
      if let error = error {
        print("\(collectionName.rawValue) \(field) 업데이트 실패: \(error.localizedDescription)")
        completion(false, error)
      } else {
        print("\(collectionName.rawValue) \(field) 업데이트 성공")
        completion(true, nil)
      }
    }
  }
  
  
  
  func updatePresetQuestions(for userId: String, presetQuestions: [User.PresetQuestion], completion: @escaping (Bool, Error?) -> Void) {
    let data: [[String: Any]] = presetQuestions.map { question in
      return [
        "presetTitle": question.presetTitle,
        "presetQuestion": question.presetQuestion
      ]
    }
    
    db.collection("users").document(userId).updateData([
      "preset": data
    ]) { error in
      if let error = error {
        print("preset 업데이트 실패: \(error.localizedDescription)")
        completion(false, error)
      } else {
        print("preset 업데이트 성공")
        completion(true, nil)
      }
    }
  }
  
  func getPresetList(documentId: String, completion: @escaping ([User.PresetQuestion]?, Error?) -> Void) {
    db.collection("users").document(documentId).getDocument { snapshot, error in
      if let error = error {
        completion(nil, error)
        print(error)
        return
      }
      guard let data = snapshot?.data() else {
        completion([], nil)
        print("60")
        return
      }
      
      do {
        let user = try Firestore.Decoder().decode(User.self, from: data)
        completion(user.preset, nil)
      } catch {
        completion(nil, error)
        print("error")
      }
    }
  }
  
  func listenToPresetList(documentId: String, completion: @escaping ([User.PresetQuestion]?, Error?) -> Void) -> ListenerRegistration {
    let docRef = db.collection("users").document(documentId).collection("presetQuestions")
    
    // Firestore 리스너 추가
    let listener = docRef.addSnapshotListener { snapshot, error in
      if let error = error {
        completion(nil, error)
        return
      }
      
      guard let documents = snapshot?.documents else {
        completion([], nil)
        return
      }
      
      // Firestore 문서 데이터를 PresetQuestion 모델로 변환
      let questions = documents.compactMap { doc -> User.PresetQuestion? in
        try? doc.data(as: User.PresetQuestion.self) // Codable을 준수하는 경우
      }
      
      // 변경된 데이터를 반환
      completion(questions, nil)
    }
    
    return listener
  }
  
  func readUser(documentId: String, completion: @escaping (User?, Error?) -> Void) {
    db.collection("users").document(documentId).getDocument { (documentSnapshot, error) in
      guard let document = documentSnapshot, document.exists, error == nil else {
        completion(nil, error)
        return
      }
      do {
        let user = try document.data(as: User.self)
        print(user)
        completion(user, nil)
      } catch {
        print(error)
        completion(nil, error)
      }
    }
  }
  
  func searchUser(name: String) -> Observable<Bool> {
    return Observable.create { observer in
      self.db.collection("users").document(name).getDocument { (snapshot, error) in
        if let error = error {
          print(error)
          observer.onNext(false)
          observer.onCompleted()
          return
        }
        guard let document = snapshot, document.exists else {
          observer.onNext(false)
          observer.onCompleted()
          return
        }
        observer.onNext(true)
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  func getUserInfo(nickName: String, completion: @escaping (User?, Error?) -> Void) {
    let query = db.collection("users").whereField("info.nickName", isEqualTo: nickName)
    query.getDocuments { (snapShot, error) in
      guard let snapshot = snapShot, error == nil else {
        completion(nil, error)
        return
      }
      
      if let document = snapshot.documents.first {
        do {
          let user = try document.data(as: User.self)
          completion(user, nil)
        } catch {
          completion(nil, error)
        }
      } else {
        completion(nil, nil)
      }
    }
  }
  
  func getUserInfoWithName(name: String, completion: @escaping (User?, Error?) -> Void) {
    let query = db.collection("users").whereField("info.name", isEqualTo: name)
    query.getDocuments { (snapShot, error) in
      guard let snapshot = snapShot, error == nil else {
        completion(nil, error)
        return
      }
      
      if let document = snapshot.documents.first {
        do {
          let user = try document.data(as: User.self)
          completion(user, nil)
        } catch {
          completion(nil, error)
        }
      } else {
        completion(nil, nil)
      }
    }
  }
  
  func addFriend(friendId: String,
                 friendType: String,
                 friendImage: String,
                 status: String,
                 friendName: String,
                 targetId: String,
                 completion: @escaping (Bool, Error?) -> Void) {
    guard let userId = UserDefaults.standard.string(forKey: "loggedInUserId") else {
      print("userID없음 확인안됨")
      return
    }
    guard let type = User.Friend.FriendType(rawValue: friendType) else { return }
    let newFriend = User.Friend(name: friendName,
                                type: type,
                                friendId: friendId,
                                friendImage: friendImage,
                                status: .pending, targetId: targetId)
    guard let myName = UserDefaults.standard.string(forKey: "userName") else { return }
    guard let myNickName = UserDefaults.standard.string(forKey: "userNickName") else { return }
    
    let currentUser = User.Friend(name: myName,
                                  type: type,
                                  friendId: myNickName,
                                  friendImage: "",
                                  status: .pending,
                                  targetId: targetId)
    
    guard let friendData = newFriend.asDictionary else { return }
    guard let userData = currentUser.asDictionary else { return }
    
    let userDocument = db.collection("users").document(userId)
    let friendDocument = db.collection("users").whereField("info.nickName", isEqualTo: friendId)
    
    friendDocument.getDocuments { (snapshot, error) in
      
      guard let snapshot = snapshot, !snapshot.isEmpty else {
        completion(false, nil)
        return
      }
      
      if let document = snapshot.documents.first {
        let friendUUID = document.documentID
        
        let friendCollection = self.db.collection("users").document(friendUUID)
        
        friendCollection.updateData([
          "friendList": FieldValue.arrayUnion([userData])
        ]) { error in
          if let error = error {
            completion(false, error)
            return
          }
        }
        
        userDocument.updateData([
          "friendList": FieldValue.arrayUnion([friendData])
        ]) { error in
          if let error = error {
            completion(false, error)
          } else {
            completion(true, nil)
          }
        }
      }
    }
  }
  
  func getQuestionList(documentId: String, completion: @escaping (Question?, Error?) -> Void) {
    db.collection("questions").document(documentId).getDocument { (documentSnapshot, error) in
      guard let document = documentSnapshot, document.exists, error == nil else {
        completion(nil, error)
        return
      }
      do {
        let question = try document.data(as: Question.self)
        print(question)
        completion(question, nil)
      } catch {
        print(error)
        completion(nil, error)
      }
    }
  }
  
  func updateFriendList(userId: String, newFriendList: [User.Friend], friendId: String, completion: @escaping (Bool, Error?) -> Void) {
    let userDocument = db.collection("users").document(userId)
    let query = db.collection("users").whereField("info.nickName", isEqualTo: friendId)
    guard let userNickName = UserDefaults.standard.string(forKey: "userNickName") else { return }
    
    query.getDocuments { (snapshot, error) in
      guard let snapshot = snapshot, error == nil else {
        completion(false, error)
        return
      }
      
      if let document = snapshot.documents.first {
        do {
          let user = try document.data(as: User.self)
          var newFriendList = user.friendList
          for (index, friend) in newFriendList.enumerated() {
            if friend.friendId == userNickName {
              newFriendList[index].status = .accepted
              break
            }
          }
          let friendListData = newFriendList.map { $0.asDictionary }
          
          document.reference.updateData([
            "friendList": friendListData
          ]) { error in
            if let error = error {
              completion(false, error)
            } else {
              completion(true, nil)
            }
          }
          
        } catch {
          print("Error decoding user data: \(error)")
          completion(false, error)
        }
      } else {
        print("No document found with the provided friendId.")
        completion(false, nil)
      }
    }
    
    let friendListData = newFriendList.map { $0.asDictionary }
    userDocument.updateData([
      "friendList": friendListData
    ]) { error in
      if let error = error {
        print(error)
        completion(false, error)
      } else {
        completion(true, nil)
      }
    }
  }
  
  func deleteFriendList(userId: String, newFriendList: [User.Friend], friendId: String, completion: @escaping (Bool, Error?) -> Void) {
    let userDocument = db.collection("users").document(userId)
    let query = db.collection("users").whereField("info.nickName", isEqualTo: friendId)
    guard let userNickName = UserDefaults.standard.string(forKey: "userNickName") else { return }
    
    query.getDocuments { (snapshot, error) in
      guard let snapshot = snapshot, error == nil else {
        completion(false, error)
        return
      }
      
      if let document = snapshot.documents.first {
        do {
          let user = try document.data(as: User.self)
          var newFriendList = user.friendList
          for (index, friend) in newFriendList.enumerated() {
            if friend.friendId == userNickName {
              newFriendList[index].status = .rejected
              break
            }
          }
          let friendListData = newFriendList.map { $0.asDictionary }
          
          document.reference.updateData([
            "friendList": friendListData
          ]) { error in
            if let error = error {
              completion(false, error)
            } else {
              completion(true, nil)
            }
          }
          
        } catch {
          print("Error decoding user data: \(error)")
          completion(false, error)
        }
      } else {
        print("No document found with the provided friendId.")
        completion(false, nil)
      }
    }
    
    let friendListData = newFriendList.map { $0.asDictionary }
    userDocument.updateData([
      "friendList": friendListData
    ]) { error in
      if let error = error {
        print(error)
        completion(false, error)
      } else {
        completion(true, nil)
      }
    }
  }
  
  func fetchReputationInfo(userId: String, completion: @escaping ([ReputationRequest]?, Error?) -> Void) {
    db.collection("reputationRequests").whereFilter(Filter.orFilter([
      Filter.whereField("requester.userId", isEqualTo: userId),
      Filter.whereField("target.userId", isEqualTo: userId),
      Filter.whereField("selectedFriendsUserIds", arrayContains: userId)
    ]))
    .getDocuments { querySnapshot, error in
      if let error = error {
        completion(nil, error)
        return
      }
      guard let querySnapshot = querySnapshot else {
        completion([], error)
        return
      }
      var reputationRequests: [ReputationRequest] = []
      for document in querySnapshot.documents {
        do {
          let reputation = try document.data(as: ReputationRequest.self)
          reputationRequests.append(reputation)
        } catch {
          print(error)
          completion(nil, error)
          return
        }
      }
      print()
      completion(reputationRequests, nil)
    }
  }
  
  func fetchquestionList(userId: String, targetNickName: String, completion: @escaping ([ReputationRequest]?, Error?) -> Void) {
    db.collection("reputationRequests").whereFilter(Filter.andFilter([
      Filter.whereField("target.nickName", isEqualTo: targetNickName),
      Filter.whereField("selectedFriendsUserIds", arrayContains: userId)
    ]))
    .getDocuments { querySnapshot, error in
      if let error = error {
        completion(nil, error)
        return
      }
      guard let querySnapshot = querySnapshot else {
        completion([], error)
        return
      }
      var reputationRequests: [ReputationRequest] = []
      for document in querySnapshot.documents {
        do {
          let reputation = try document.data(as: ReputationRequest.self)
          reputationRequests.append(reputation)
          completion(reputationRequests, nil)
        } catch {
          completion(nil, error)
          return
        }
      }
    }
  }
  
}

extension Encodable {
  var asDictionary: [String: Any]? {
    guard let object = try? JSONEncoder().encode(self),
          let dictionary = try? JSONSerialization.jsonObject(with: object, options: [])
            as? [String: Any] else {
      return nil
    }
    return dictionary
  }
}
