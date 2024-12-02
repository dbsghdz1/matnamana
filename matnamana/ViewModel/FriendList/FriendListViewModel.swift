//
//  FriendListViewModel.swift
//  matnamana
//
//  Created by 김윤홍 on 8/27/24.
//

import FirebaseCore
import FirebaseFirestore
import RxCocoa
import RxSwift

final class FriendListViewModel: ViewModelType {
  
  struct Input {
    let fetchFriends: Observable<Void>
    let searchText: Observable<String>
    let acceptTap: Observable<User.Friend>
    let rejectTap: Observable<User.Friend>
  }
  
  struct Output {
    let friendList: Driver<[FriendsSection]>
    let searchResult: Driver<Bool>
    let errorMessage: Driver<String>
  }
  
  private var friends = BehaviorRelay<[User.Friend]>(value: [])
  var disposeBag = DisposeBag()
  private var fetchFriendsSubject = PublishSubject<Void>()
  
  func fetchFriends() {
    fetchFriendsSubject.onNext(())
  }
  
  func fetchFriendList() -> Observable<[User.Friend]> {
    guard let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") else { return .empty() }
    return Observable.create { observer in
      FirebaseManager.shared.readUser(documentId: loggedInUserId) { user, error in
        if let error = error {
          observer.onError(error)
        } else if let user = user {
          observer.onNext(user.friendList)
          observer.onCompleted()
        } else {
          observer.onNext([])
          observer.onCompleted()
        }
      }
      return Disposables.create()
    }
  }
  
  private func searchFriend(by nickname: String) -> Observable<User?> {
    return Observable.create { observer in
      FirebaseManager.shared.getUserInfo(nickName: nickname) { user, error in
        if let error = error {
          observer.onError(error)
        } else {
          observer.onNext(user)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  func transform(input: Input) -> Output {
    Observable.merge([input.fetchFriends, fetchFriendsSubject.asObservable()])
      .flatMapLatest { [weak self] _ -> Observable<[User.Friend]> in
        guard let self = self else { return Observable.just([]) }
        return self.fetchFriendList()
      }
      .bind(to: friends)
      .disposed(by: disposeBag)
    
    input.acceptTap
      .flatMapLatest { [weak self] friend -> Observable<Void> in
        guard let self = self else { return .empty() }
        guard let id = UserDefaults.standard.string(forKey: "loggedInUserId") else { return .empty() }
        
        var updatedFriends = self.friends.value
        if let index = updatedFriends.firstIndex(where: { $0.friendId == friend.friendId }) {
          updatedFriends[index].status = .accepted
          
          return Observable<Void>.create { observer in
            FirebaseManager.shared.updateFriendList(userId: id, newFriendList: updatedFriends, friendId: friend.friendId) { success, error in
              if let error = error {
                observer.onError(error)
              } else {
                observer.onNext(())
                observer.onCompleted()
              }
            }
            return Disposables.create()
          }
        } else {
          return .empty()
        }
      }
      .flatMapLatest { [weak self] _ -> Observable<[User.Friend]> in
        guard let self = self else { return .just([]) }
        return self.fetchFriendList()
      }
      .subscribe(onNext: { [weak self] updatedFriends in
        guard let self = self else { return }
        self.friends.accept(updatedFriends)
      })
      .disposed(by: disposeBag)
    
    input.rejectTap
      .flatMapLatest { [weak self] friend -> Observable<Void> in
        guard let self = self else { return .empty() }
        guard let id = UserDefaults.standard.string(forKey: "loggedInUserId") else { return .empty() }
        
        var updatedFriends = self.friends.value
        
        if let index = updatedFriends.firstIndex(where: { $0.friendId == friend.friendId }) {
          updatedFriends[index].status = .rejected
          
          return Observable<Void>.create { observer in
            FirebaseManager.shared.deleteFriendList(userId: id, newFriendList: updatedFriends, friendId: friend.friendId) { success, error in
              if let error = error {
                observer.onError(error)
              } else {
                observer.onNext(())
                observer.onCompleted()
              }
            }
            return Disposables.create()
          }
        } else {
          return .empty()
        }
      }
      .flatMapLatest { [weak self] _ -> Observable<[User.Friend]> in
        guard let self = self else { return .just([]) }
        return self.fetchFriendList()
      }
      .subscribe(onNext: { [weak self] updatedFriends in
        guard let self = self else { return }
        self.friends.accept(updatedFriends)
      })
      .disposed(by: disposeBag)
    
    let friendList = friends
      .map { friends -> [FriendsSection] in
        guard let id = UserDefaults.standard.string(forKey: "loggedInUserId"),
              !id.isEmpty else {
          return []
        }
        print(id)
        let acceptedFriends = friends.filter { $0.status == .accepted }
        let pendingFriends = friends.filter { $0.status == .pending && $0.targetId != id }
        let myRequest = friends.filter { $0.status == .pending && $0.targetId == id }
        
        return [
          FriendsSection(header: "보낸 친구 요청", items: myRequest),
          FriendsSection(header: "받은 친구 요청", items: pendingFriends),
          FriendsSection(header: "친구 목록", items: acceptedFriends)
        ]
      }
      .asDriver(onErrorJustReturn: [])
    
    let searchResult = input.searchText
      .flatMapLatest { [weak self] nickname -> Observable<Bool> in
        guard let self = self else { return Observable.just(false) }
        guard UserDefaults.standard.string(forKey: "loggedInUserId") != nil else { return Observable.just(false) }
        return self.searchFriend(by: nickname)
          .map { user -> Bool in
            if user != nil {
              return true
            } else {
              return false
            }
          }
      }
      .asDriver(onErrorJustReturn: false)
    
    let errorMessage = input.searchText
      .flatMap { [weak self] nickname -> Observable<String> in
        guard let self = self else { return Observable.just("") }
        return self.searchFriend(by: nickname)
          .compactMap { user in
            return user == nil ? "해당 닉네임의 사용자가 없습니다." : nil
          }
      }
      .asDriver(onErrorJustReturn: "")
    
    return Output(friendList: friendList,
                  searchResult: searchResult,
                  errorMessage: errorMessage)
  }
}
