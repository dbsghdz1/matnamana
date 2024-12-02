//
//  aceptRequestController.swift
//  matnamana
//
//  Created by pc on 9/9/24.
//

import UIKit

import RxCocoa
import RxSwift

class AcceptRequestController: FriendListController {
  
  private let viewModel: AcceptRequestViewModel
  private let requester: String
  private let target: String
  
  
  init(viewModel: AcceptRequestViewModel, requester: String, target: String) {
    self.viewModel = viewModel
    self.requester = requester
    self.target = target
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    friendListView.friendList.allowsMultipleSelection = true
    self.navigationItem.rightBarButtonItem = sendButton()
  }
  
  override func bind() {
    super.bind()
    
    friendListView.friendList.rx.itemDeselected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        if let cell = self.friendListView.friendList.cellForRow(at: indexPath) as? FriendListCell {
          guard let selectedFriends = cell.userName.text else { return }
          self.viewModel.removeItem(at: indexPath, selectedFriends: selectedFriends)
        }
      }).disposed(by: disposeBag)
    
    viewModel.selectedItems
      .asDriver()
      .drive(onNext: { [weak self] selectedItems in
        guard let self = self else { return }
        let allIndexPaths = self.friendListView.friendList.indexPathsForSelectedRows ?? []
        if selectedItems.count > 2 {
          self.viewModel.removeFirstItem()
        }
        allIndexPaths.forEach { indexPath in
          if let cell = self.friendListView.friendList.cellForRow(at: indexPath) as? FriendListCell {
            guard let selectedFriends = cell.userName.text else { return }
            if !selectedItems.contains(selectedFriends) {
              self.friendListView.friendList.deselectRow(at: indexPath, animated: true)
            }
          }
        }
        print("현재 선택된 항목들: \(selectedItems)")
      }).disposed(by: disposeBag)
  }
  
  override func bindFriendsSelect() {
    friendListView.friendList.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        if let cell = self.friendListView.friendList.cellForRow(at: indexPath) as? FriendListCell {
          guard let selectedFriends = cell.userName.text else { return }
          self.viewModel.selectItem(selectedFriends: selectedFriends)
        }
      }).disposed(by: disposeBag)
  }
  
  private func sendButton() -> UIBarButtonItem {
    let button = UIButton(type: .system)
    button.setTitle("보내기", for: .normal)
    button.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] in
        guard let self else { return }
        if viewModel.selectedItems.value.count == 0 {
          self.alertMessage()
        }else if viewModel.selectedItems.value.count == 1 {
          self.viewModel.removeFirstItem()
          self.alertMessage()
        } else {
          self.viewModel.sendData(requester: requester, target: target)
          self.viewModel.updateStatus(requester: requester, target: target)
          dismiss(animated: true)
        }
      }).disposed(by: disposeBag)
    
    return UIBarButtonItem(customView: button)
  }
  private func alertMessage() {
    let alertMessage = UIAlertController(title: "두명의 친구를 선택해 주세요!",
                                         message: "",
                                         preferredStyle: .alert)
    let okAction = UIAlertAction(title: "확인", style: .default) 
    alertMessage.addAction(okAction)
    present(alertMessage, animated: true, completion: nil)
  }
  
}
