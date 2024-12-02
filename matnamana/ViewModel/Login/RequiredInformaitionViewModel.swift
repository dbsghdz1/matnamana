
//
//  Created by pc on 8/30/24.
//

import Foundation

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import RxSwift


final class RequiredInfoViewModel {

  private let disposeBag = DisposeBag()
  private let db = FirebaseManager.shared.db
  
  let isNicknameValid = PublishSubject<Bool>()
  let isNicknameDuplicate = PublishSubject<Bool>()
  
  func validateNickname(_ nickname: String) {
    let allowedCharacters = CharacterSet.lowercaseLetters.union(.decimalDigits)
    let characterSet = CharacterSet(charactersIn: nickname)
    let containsForbiddenWord = ForbiddenWords.words.contains {
      nickname.lowercased().contains($0)
    }
    let isValid = nickname.count <= 15 && allowedCharacters.isSuperset(of: characterSet) && !containsForbiddenWord
    isNicknameValid.onNext(isValid)
  }

  func checNicknameDuplicate(nickname: String) {
    db.collection("users")
      .whereField("info.nickName",isEqualTo: nickname)
      .getDocuments { [weak self] querySnapshot, error in
        guard let self = self else { return }
        if error != nil {
          print("error")
        }
        if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
          print("중복된 닉네임")
          self.isNicknameDuplicate.onNext(true)
        } else {
          print("중복되지 않음")
          self.isNicknameDuplicate.onNext(false)
        }
      }
  }

  func saveLoginState(userId: String) {
    UserDefaults.standard.set(true, forKey: "isLoggedIn")
    UserDefaults.standard.set(userId, forKey: "loggedInUserId")
  }

  func makeUserInformation(name: String, nickName: String, shortDescription: String, completion: @escaping (User) -> Void ) {
    guard let appleUser = Auth.auth().currentUser else { return }
    UserDefaults.standard.setValue(name, forKey: "userName")
    UserDefaults.standard.setValue(nickName, forKey: "userNickName")
    UserDefaults.standard.setValue("", forKey: "userImage")
    let user = User(
      info: User.Info(
        career: "",
        education: "",
        email: "",
        location: "",
        name: name,
        phoneNumber: "",
        shortDescription: shortDescription,
        profileImage: "https://firebasestorage.googleapis.com/v0/b/matnamana-65c65.appspot.com/o/profile%20(1).png?alt=media&token=bcda4a76-95ff-4281-a4e1-b32f26a75bff",
        nickName: nickName,
        birth: "",
        university: "",
        companyName: ""
      ),
      preset: [],
      friendList: [],
      userId: appleUser.uid
    )
    FirebaseManager.shared.addData(to: .user, data: user, documentId: appleUser.uid)
    completion(user)
  }
}
