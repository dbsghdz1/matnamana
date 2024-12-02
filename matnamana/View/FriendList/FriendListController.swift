//
//  FriendListController.swift
//  matnamana
//
//  Created by 김윤홍 on 8/23/24.

import UIKit

import RxCocoa
import RxDataSources
import RxSwift

class FriendListController: BaseViewController, UISearchBarDelegate {
  
  private let viewModel = FriendListViewModel()
  var friendListView = FriendListView(frame: .zero)
  
  override func setupView() {
    super.setupView()
    friendListView = FriendListView(frame: UIScreen.main.bounds)
    self.view = friendListView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.fetchFriends()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tapGesture.cancelsTouchesInView = false
    self.view.addGestureRecognizer(tapGesture)
    
  }
  
  @objc override func dismissKeyboard() {
    self.view.endEditing(true)
  }
  
  override func bind() {
    super.bind()
    let acceptTapSubject = PublishSubject<User.Friend>()
    let rejectTapSubject = PublishSubject<User.Friend>()
    let input = FriendListViewModel.Input(
      fetchFriends: Observable.just(()),
      searchText: friendListView.searchBar.rx.searchButtonClicked
        .withLatestFrom(friendListView.searchBar.rx.text.orEmpty)
        .filter { !$0.isEmpty },
      acceptTap: acceptTapSubject.asObservable(),
      rejectTap: rejectTapSubject.asObservable()
    )
    
    let output = viewModel.transform(input: input)
    
    let dataSource = RxTableViewSectionedReloadDataSource<FriendsSection>(
      configureCell: { [weak self] dataSource, tableView, indexPath, friend in
        guard let self else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FriendListCell.self), for: indexPath) as? FriendListCell else { return UITableViewCell() }
        let friend = dataSource[indexPath]
        cell.configureCell(nickName: friend.name,
                           relation: friend.type.rawValue,
                           friendImage: friend.friendImage)
        
        cell.acceptButton.isHidden = true
        cell.refuseButton.isHidden = true
        cell.userName.isHidden = false
        cell.userRelation.isHidden = false
        cell.sendRequestLabel.isHidden = true
        cell.backgroundColor = .white
        
        if dataSource[indexPath.section].header == "보낸 친구 요청" {
          cell.acceptButton.isHidden = true
          cell.refuseButton.isHidden = true
          cell.userName.isHidden = true
          cell.userRelation.isHidden = true
          cell.sendRequestLabel.isHidden = false
          cell.backgroundColor = UIColor(red: 239/255, green: 248/255, blue: 225/255, alpha: 1)
          cell.updateRequestLabel(name: friend.name)
        } else if dataSource[indexPath.section].header == "받은 친구 요청" {
          cell.acceptButton.isHidden = false
          cell.refuseButton.isHidden = false
          cell.sendRequestLabel.isHidden = true
          
          cell.acceptButton.rx.tap
            .map { friend }
            .bind(to: acceptTapSubject)
            .disposed(by: self.disposeBag)
          
          cell.refuseButton.rx.tap
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
              guard let self = self else { return .empty() }
              
              return Observable<Bool>.create { observer in
                let alert = UIAlertController(title: "친구 요청 거절",
                                              message: "정말로 친구 요청을 거절하시겠습니까?",
                                              preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "확인", style: .destructive) { _ in
                  observer.onNext(true)
                  observer.onCompleted()
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                  observer.onNext(false)
                  observer.onCompleted()
                }
                
                alert.addAction(confirmAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
                return Disposables.create()
              }
            }
            .filter { $0 }
            .map { _ in friend }
            .bind(to: rejectTapSubject)
            .disposed(by: self.disposeBag)
        } else {
          cell.acceptButton.isHidden = true
          cell.refuseButton.isHidden = true
          cell.sendRequestLabel.isHidden = true
        }
        return cell
      },
      titleForHeaderInSection: { dataSource, index in
        return dataSource[index].header
      }
    )
    
    output.friendList
      .drive(friendListView.friendList.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    output.searchResult
      .drive(onNext: { [weak self] userExists in
        guard let self else { return }
        guard let userNickName = self.friendListView.searchBar.text else { return }
        if userExists {
          FirebaseManager.shared.getUserInfo(nickName: userNickName) { user, error in
            if let user = user {
              let profileVC = ProfileViewController(userInfo: user.info.nickName, isCellClicked: false, sendId: nil)
              profileVC.userInfo = user.info.nickName
              self.navigationController?.pushViewController(profileVC, animated: true)
            }
          }
        }
      }).disposed(by: disposeBag)
    
    output.errorMessage
      .drive(onNext: { [weak self] message in
        guard let self else { return }
        guard !message.isEmpty else { return }
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        self.present(alert, animated: true)
      })
      .disposed(by: disposeBag)
    
    bindFriendsSelect()
  }
  
  func bindFriendsSelect() {
    friendListView.friendList.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self else { return }
        
        guard let cell = self.friendListView.friendList.cellForRow(at: indexPath) as? FriendListCell else {
          return
        }
        print(cell.userName.text ?? "")
        let profileVC = ProfileViewController(userInfo: cell.userName.text ?? "",
                                              isCellClicked: true,
                                              sendId: cell.userName.text)
        profileVC.userInfo = cell.userName.text ?? ""
        self.navigationController?.pushViewController(profileVC, animated: true)
      }).disposed(by: disposeBag)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}
