# 맞나만나


---

## 📱 프로젝트 소개

- 프로젝트 명 : 맞나만나
- 소개
    - 한줄 소개
        - 맞나만나 ‘맞나만나’ 서비스는 평판조회 시스템을 연애에 접목시켜 상대방을 만나기전 신뢰를 형성함
    - 주요 기능
        - 나만의 질문을 만들고 관리하기
        - 친구를 추가, 삭제를 통한 친구목록 관리하기
        - 맞나만나를 통해 질문을 전달하고 답변을 받을 수 있음
    - 내용 
    https://apps.apple.com/kr/app/맞나만나/id6670377080

## 🧑🏻‍💻 팀원 소개 (Team)

- **팀장**: 김인규 (디자인, 기획)
- **부팀장**: 김윤홍 (메인 화면, 친구 목록)
- **개발**:
  - 최 건 (맞나만나, 로그인)
  - 이진규 (마이페이지)

## ⚒️ 기술 스택 (Tech Stack)

- **UIKit**
- **Swift**
- **Firebase**:
  - FirebaseAuth
  - FirebaseFirestore
- **SnapKit**
- **Then**

## 📱 주요 기능

기능 시연 영상 : [https://youtu.be/EXk_NXo28A4](https://www.youtube.com/watch?v=HtArwd0cgyw)

## 📱 스크린샷

<img width="982" alt="스크린샷 2024-10-21 02 03 41" src="https://github.com/user-attachments/assets/feda14f3-236a-4dfc-9ce5-e03cc7fc93a0">

## 5. 트러블 슈팅

### 친구에게 질문을 보낼 때 앱이 크래시가 났던 경우.(최 건)

- 애플 로그인, 카카오톡 로그인 구현 중 화면전환

```swift
private let authResultSubject = PublishSubject<Bool>()
  func authResultObservable() -> Observable<Bool> {
    return authResultSubject.asObservable()
  }
  
  func startSignInWithAppleFlow(/*completion: @escaping (Result<Void, Error>) -> Void*/) {
    let nonce = randomNonceString()
    currentNonce = nonce
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }
  
  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      
      let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                     rawNonce: nonce,
                                                     fullName: appleIDCredential.fullName)
      
      Auth.auth().signIn(with: credential) { [weak self] authResult, error in
        guard let self = self else { return }
        if let error = error {
          print ("Error Apple sign in: %@", error)
          self.authResultSubject.onNext(false)
          return
        }
        self.authResultSubject.onNext(true)
      }
    }
  }
```
❓ 문제
startSignInWithAppleFlow 실행 후 로그인 완료 후에 화면 전환이 이루어져야 하지만, startSignInWithAppleFlow 실행 직후 화면 전환이 발생해 문제가 생김.
escaping 클로저를 사용해 보았으나, 원하는 대로 동작하지 않음.

❗ 해결
private let authResultSubject = PublishSubject<Bool>()를 생성하여 인증이 완료된 시점에 Bool 값을 넘겨주는 방식으로 해결.

Modal을 dismiss한 후에 navigationController를 pop해야 하는 경우

