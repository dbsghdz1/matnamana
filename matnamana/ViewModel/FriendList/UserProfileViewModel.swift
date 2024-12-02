//
//  ProfileViewModel.swift
//  matnamana
//
//  Created by 김윤홍 on 9/1/24.
//

import FirebaseCore
import FirebaseFirestore
import RxCocoa
import RxSwift

final class UserProfileViewModel: ViewModelType {
  
  struct Input {
    let fetchUser: Observable<Void>
    let nickName: String
  }
  
  struct Output {
    let userInfo: Driver<User.Info>
    let userInfoWithName: Driver<User.Info>
    let friendCount: Driver<[User.Friend]>
  }
  
  func transform(input: Input) -> Output {
    let userInfo = input.fetchUser
      .flatMap { _ in
        self.fetchUserInfo(nickName: input.nickName)
      }
      .asDriver(onErrorDriveWith: .empty())
    
    let userInfoWithName = input.fetchUser
      .flatMap { _ in
        self.fetchUserInfoWithName(name: input.nickName)
      }
      .asDriver(onErrorDriveWith: .empty())
    
    if isKorean(input.nickName) {
      let friendCount = input.fetchUser
        .flatMap { _ in
          self.getUserFriendCount(name: input.nickName)
        }
        .asDriver(onErrorJustReturn: [])
      return Output(userInfo: userInfo, userInfoWithName: userInfoWithName, friendCount: friendCount)
    } else {
      let friendCountWithName = input.fetchUser
        .flatMap { _ in
          self.getUserFriendCount(nickName: input.nickName)
        }
        .asDriver(onErrorJustReturn: [])
      return Output(userInfo: userInfo, userInfoWithName: userInfoWithName, friendCount: friendCountWithName)
    }
  }
  
  func isKorean(_ text: String) -> Bool {
    for scalar in text.unicodeScalars {
      if !(scalar.value >= 0xAC00 && scalar.value <= 0xD7A3) {
        return false
      }
    }
    return true
  }
  
  
  private func fetchUserInfo(nickName: String) -> Observable<User.Info> {
    return Observable.create { observer in
      FirebaseManager.shared.getUserInfo(nickName: nickName) { user, error in
        if let user = user {
          observer.onNext(user.info)
        } else if let error = error {
          observer.onError(error)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  private func fetchUserInfoWithName(name: String) -> Observable<User.Info> {
    return Observable.create { observer in
      FirebaseManager.shared.getUserInfoWithName(name: name) { user, error in
        if let user = user {
          observer.onNext(user.info)
        } else if let error = error {
          observer.onError(error)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  private func getUserFriendCount(name: String) -> Observable<[User.Friend]> {
    return Observable.create { observer in
      FirebaseManager.shared.getUserInfoWithName(name: name) { user, error in
        if let user = user {
          observer.onNext(user.friendList)
        } else if let error = error {
          observer.onError(error)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  private func getUserFriendCount(nickName: String) -> Observable<[User.Friend]> {
    return Observable.create { observer in
      FirebaseManager.shared.getUserInfo(nickName: nickName) { user, error in
        if let user = user {
          observer.onNext(user.friendList)
        } else if let error = error {
          observer.onError(error)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
}
