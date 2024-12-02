//
//  FriendListViewModel.swift
//  matnamana
//
//  Created by 김윤홍 on 8/27/24.
//

import Foundation

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import RxSwift
import RxCocoa

final class LoginViewModel: ViewModelType {
  
  struct Input {
    let loggedInApple: ControlEvent<Void>
    let loggedInKakao: ControlEvent<Void>
  }
  
  struct Output {
    let isDuplicate: Observable<Bool>
    let appleLoggin: Observable<Bool>
  }
  
  private let db = FirebaseManager.shared.db
  
  func checkUidDuplicate() -> Observable<Bool> {
    return Observable.create { [weak self] observer in
      guard let self = self else {
        observer.onCompleted()
        return Disposables.create()
      }
      
      guard let user = Auth.auth().currentUser else {
        observer.onCompleted()
        return Disposables.create()
      }
      
      let documentRef = self.db.collection("users").document(user.uid)
      print(user.uid)
      documentRef.getDocument { document, error in
        if let error = error {
          observer.onError(error)
          return
        }
        
        if let document = document, document.exists {
          print("가입된 사용자")
          UserDefaults.standard.set(true, forKey: "isLoggedIn")
          UserDefaults.standard.set(user.uid, forKey: "loggedInUserId")
          observer.onNext(true)
        } else {
          print("가입되지 않은 사용자")
          observer.onNext(false)
        }
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }
  
  func transform(input: Input) -> Output {
    let appleLogin = input.loggedInApple
      .do(onNext: {
        AppleLoginService.shared.startSignInWithAppleFlow()
      })
      .flatMap { _ -> Observable<Bool> in
        AppleLoginService.shared.authResultObservable()
      }
    
    let kakaoLogin = input.loggedInKakao
      .do(onNext: {
        KakaoLoginService.shared.KakaoLogin()
      })
      .flatMap { _ -> Observable<Bool> in
        KakaoLoginService.shared.authResultObservable()
      }
    
    let isDuplicate = Observable.of(appleLogin, kakaoLogin)
      .merge()
      .filter { $0 == true }
      .flatMap { [weak self] _ -> Observable<Bool> in
        guard let self = self else {
          return .empty()
        }
        return self.checkUidDuplicate()
      }
    
    let selectApple = Observable
      .merge(
        input.loggedInApple.map { _ in true },
        input.loggedInKakao.map { _ in false }
      )
    
    return Output(isDuplicate: isDuplicate, appleLoggin: selectApple)
  }
}
