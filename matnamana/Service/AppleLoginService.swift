//
//  login.swift
//  matnamana
//
//  Created by pc on 8/28/24.
//

import AuthenticationServices
import CryptoKit

import FirebaseAuth
import RxSwift

final class AppleLoginService: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  static let shared = AppleLoginService()
  private var currentNonce: String?
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
        guard
          let fullName = appleIDCredential.fullName,
          let familiyName = fullName.familyName,
          let givenName = fullName.givenName
        else { return }
        UserDefaults.standard.set("\(familiyName) \(givenName)", forKey: "userName")
      }
    }
  }
  
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return ASPresentationAnchor()
  }
  
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      return String(format: "%02x", $0)
    }.joined()
    
    return hashString
  }
  
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }
      
      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }
        
        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    return result
  }
  
}

