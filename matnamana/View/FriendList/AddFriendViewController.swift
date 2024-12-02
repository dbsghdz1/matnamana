//
//  AddFriendViewController.swift
//  matnamana
//
//  Created by 김윤홍 on 9/1/24.
//

import UIKit

import RxCocoa
import RxSwift

final class AddFriendViewController: BaseViewController {
  
  private var addFriendView = AddFriendView(frame: .zero)
  private var friendType = ""
  private var status = ""
  private let viewModel = AddFriendViewModel()
  var userInfo: String
  var userImage: String
  var userName: String
  var completion: (() -> Void)?
  
  init(userInfo: String,
       userImage: String,
       userName: String,
       completion: @escaping (() -> Void)) {
    self.userInfo = userInfo
    self.userImage = userImage
    self.userName = userName
    self.completion = completion
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .gray
  }
  
  override func setupView() {
    super.setupView()
    addFriendView = AddFriendView(frame: UIScreen.main.bounds)
    self.view = addFriendView
  }
  
  override func bind() {
    super.bind()
    addFriendView.closeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.dismiss(animated: true, completion: nil)
      }).disposed(by: disposeBag)
    
    addFriendView.familyButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.friendType = "family"
        self.status = "pending"
        addFriendView.familyButton.backgroundColor = .manatextColor
        addFriendView.familyButton.setTitleColor(.white, for: .normal)
        addFriendView.friendButton.backgroundColor = .white
        addFriendView.colleagueButton.backgroundColor = .white
        addFriendView.colleagueButton.setTitleColor(.manatextColor, for: .normal)
        addFriendView.friendButton.setTitleColor(.manatextColor, for: .normal)
      }).disposed(by: disposeBag)
    
    addFriendView.friendButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.friendType = "friend"
        self.status = "pending"
        addFriendView.familyButton.backgroundColor = .white
        addFriendView.friendButton.setTitleColor(.white, for: .normal)
        addFriendView.friendButton.backgroundColor = .manatextColor
        addFriendView.colleagueButton.backgroundColor = .white
        addFriendView.colleagueButton.setTitleColor(.manatextColor, for: .normal)
        addFriendView.familyButton.setTitleColor(.manatextColor, for: .normal)
      }).disposed(by: disposeBag)
    
    addFriendView.colleagueButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.friendType = "colleague"
        self.status = "pending"
        addFriendView.familyButton.backgroundColor = .white
        addFriendView.colleagueButton.setTitleColor(.white, for: .normal)
        addFriendView.friendButton.backgroundColor = .white
        addFriendView.colleagueButton.backgroundColor = .manatextColor
        addFriendView.friendButton.setTitleColor(.manatextColor, for: .normal)
        addFriendView.familyButton.setTitleColor(.manatextColor, for: .normal)

      }).disposed(by: disposeBag)
    
    addFriendView.sendButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        let input = AddFriendViewModel.Input(addFriend: .just([userInfo,
                                                               self.friendType,
                                                               userImage,
                                                               self.status,
                                                               self.userName
                                                              ]))
        let output = self.viewModel.transform(input: input)
        
        output.addFriendResult
          .drive(onNext: { [weak self] success in
            guard let self else { return }
            if success {
              print("성공")
            } else {
              print("실패")
            }
            guard let completion = completion else { return }
            self.dismiss(animated: true) {
              print(self)
              self.completion?()
            }
          }).disposed(by: self.disposeBag)
      }).disposed(by: disposeBag)
  }
}
