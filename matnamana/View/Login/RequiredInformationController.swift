//
//  LoginController.swift
//  matnamana
//
//  Created by 김윤홍 on 8/23/24.
//

import UIKit

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import RxCocoa
import RxSwift

final class RequiredInformationController: BaseViewController {
  
  private var requiredInformationView = RequiredInformationView(frame: .zero)
  private let requiredInfoViewModel = RequiredInfoViewModel()
  
  var appleLogin: Bool
  
  init(appleLogin: Bool) {
    self.appleLogin = appleLogin
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupView() {
    super.setupView()
    requiredInformationView = RequiredInformationView(frame: UIScreen.main.bounds)
    if appleLogin {
      let userName = UserDefaults.standard.string(forKey: "userName")
      requiredInformationView.hidename()
      requiredInformationView.nameTextField.text = userName
    }
    self.view = requiredInformationView
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupDismissKeyboardGesture()
  }

  override func bind() {
    super.bind()
    bindJoinButton()
    bindViewModel()
  }
  private func bindJoinButton() {
    requiredInformationView.joinButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        if requiredInformationView.nickNameTextField.text == "" {
          self.alertMessage(title: "닉네임을 입력해주세요.", message: "", okTitle: "확인", next: false)
        } else if requiredInformationView.shortDescriptionTextField.text == "" {
          self.alertMessage(title: "소개글을 입력해주세요.", message: "", okTitle: "확인", next: false)
        } else if requiredInformationView.duplicateCheckLabel.isHidden == false {
          self.alertMessage(title: "유효하지 않은 닉네임입니다.", message: "(영문 알파벳, 숫자 15자 이내)", okTitle: "확인", next: false)
        } else {
          let nickName = self.requiredInformationView.pickNickname()
          self.requiredInfoViewModel.checNicknameDuplicate(nickname: nickName)
        }
      }).disposed(by: disposeBag)
  }
  
  private func bindViewModel() {
    
    requiredInformationView.nickNameTextField.rx.text
      .orEmpty
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] nickname in
        guard let self else { return }
        self.requiredInfoViewModel.validateNickname(nickname)
      }).disposed(by: disposeBag)
    
    requiredInfoViewModel.isNicknameValid
      .subscribe(onNext: { [weak self] isValid in
        guard let self else { return }
        if isValid {
          self.requiredInformationView.hideduplicateCheck()
        } else {
          self.requiredInformationView.validCheck()
        }
      }).disposed(by: disposeBag)
    
    requiredInfoViewModel.isNicknameDuplicate
      .subscribe(onNext: {  [weak self] isDuplicate in
        guard let self = self else { return }
        if isDuplicate {
          self.requiredInformationView.showduplicateCheck()
        } else {
          self.requiredInformationView.hideduplicateCheck()
          self.alertMessage(title: "가입을 환영합니다!", message: "나만의 탁월한 질문을 만들어 보세요!", okTitle: "이동하기", next: true)
          self.requiredInfoViewModel.makeUserInformation(
            name: self.requiredInformationView.pickName(),
            nickName: self.requiredInformationView.pickNickname(),
            shortDescription: self.requiredInformationView.pickShortDescription()) { user in
              self.requiredInfoViewModel.saveLoginState(userId: user.userId)
            }
        }
      }).disposed(by: disposeBag)
  }

  private func alertMessage(title: String, message: String, okTitle: String, next: Bool) {
    let alertMessage = UIAlertController(title: title,
                                            message: message,
                                         preferredStyle: .alert)
    let okAction = UIAlertAction(title: okTitle, style: .default) {_ in
      if next {
        self.transitionToViewController(TabBarController())
      }
    }
    alertMessage.addAction(okAction)
    present(alertMessage, animated: true, completion: nil)
  }
}
