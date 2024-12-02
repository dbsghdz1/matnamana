import Foundation
import FirebaseFirestore
import RxCocoa
import RxSwift

final class ProfileEditViewModel: ViewModelType {
  
  private let db = FirebaseManager.shared.db
  
  struct Input {
    let saveTap: Observable<Void>
//    let nicknameText: Observable<String>
//    let shortDescriptionText: Observable<String>
    let userInfoTexts: Observable<[String: String]>
    let profileImageUrl: Observable<String>  // 이미지 URL을 받을 Observable 추가
  }
  
  struct Output {
    let saveResult: Driver<Bool>
    let currentUserInfo: Observable<User.Info>  //
  }
  
  // Firebase에서 사용자 정보를 불러오는 메서드 추가
  func fetchProfileData() -> Observable<User> {  // 접근제어를 private에서 public으로 변경
    return Observable.create { observer in
      guard let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") else {
        observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"]))
        return Disposables.create()
      }
      
      FirebaseManager.shared.readUser(documentId: loggedInUserId) { user, error in
        if let error = error {
          observer.onError(error)
        } else if let user = user {
          observer.onNext(user)
          observer.onCompleted()
        } else {
          observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
        }
      }
      return Disposables.create()
    }
  }
  
  // 입력을 받아 사용자 정보 저장 및 업데이트하는 메서드
  func transform(input: Input) -> Output {
    let saveResult = input.saveTap
      .withLatestFrom(Observable.combineLatest( input.userInfoTexts, input.profileImageUrl))  // 이미지 URL 포함
      .flatMap { [weak self] ( userInfo, profileImageUrl) -> Observable<Bool> in
        guard let self = self else { return Observable.just(false) }
        guard let name = UserDefaults.standard.string(forKey: "userName") else { return Observable.just(false) }
        // 기존 데이터를 가져와 업데이트
        return self.fetchProfileData().flatMap { existingUser -> Observable<Bool> in
          let info = User.Info(
            career: userInfo["직업"] ?? existingUser.info.career,
            education: userInfo["최종학력"] ?? existingUser.info.education,
            email: userInfo["이메일"] ?? existingUser.info.email,
            location: userInfo["거주지"] ?? existingUser.info.location,
            name: name,
            phoneNumber: userInfo["휴대번호"] ?? existingUser.info.phoneNumber,
            shortDescription:userInfo["소개"] ?? existingUser.info.shortDescription,
            profileImage: profileImageUrl,
            nickName: userInfo["닉네임"] ?? existingUser.info.nickName,
            birth: userInfo["생일"] ?? existingUser.info.birth,
            university: userInfo["대학교"] ?? existingUser.info.university,
            companyName: userInfo["회사"] ?? existingUser.info.companyName
          )
          
          let updatedUser = User(info: info, preset: existingUser.preset, friendList: existingUser.friendList, userId: existingUser.userId)
          
          return self.saveUserData(user: updatedUser)
        }
      }
      .asDriver(onErrorJustReturn: false)
    
    // Firebase에서 사용자 정보를 불러오는 Observable
    let profileData = fetchProfileData().map { $0.info }
    
    return Output(saveResult: saveResult, currentUserInfo: profileData)
  }
  
  // Firebase에 사용자 데이터를 저장하는 메서드
  func saveUserData(user: User) -> Observable<Bool> {
    return Observable.create { observer in
      FirebaseManager.shared.addData(to: .user, data: user, documentId: user.userId)
      observer.onNext(true)
      observer.onCompleted()
      return Disposables.create()
    }
  }
}

