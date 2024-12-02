//
//  AnswerListController.swift
//  matnamana
//
//  Created by pc on 9/17/24.
//

import UIKit

import RxCocoa
import RxSwift

final class AnswerListController: BaseViewController {
  private let viewModel = AnswerListViewModel()
  private var answerListView = AnswerListView(frame: .zero)
  
  private var nickName: String
  private var requester: String
  private var target: String
  
  private var selected = ""
  
  init(nickName: String, requester: String, target: String) {
    self.nickName = nickName
    self.requester = requester
    self.target = target
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.fetchFriendList(requester: requester, target: target)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func setupView() {
    super.setupView()
    answerListView = AnswerListView(frame: UIScreen.main.bounds)
    self.view = answerListView
    self.navigationItem.title = "답변확인"
  }
  
  override func bind() {
    super.bind()
    
    
    
    viewModel.reputationRequest
      .bind(to: answerListView.tableView.rx.items(cellIdentifier: String(describing: AnswerListCell.self), cellType: AnswerListCell.self)) { row, reputation, cell in
        cell.configure(with: reputation)
      }.disposed(by: disposeBag)
    
    answerListView.tableView.rx.itemSelected
      .subscribe { [weak self] indexPath in
        guard let self else { return }
        if let cell = self.answerListView.tableView.cellForRow(at: indexPath) as? AnswerListCell {
          let nickName = cell.userName.text ?? ""
          pushViewController(ReadAnserController(name: nickName, requester: requester, target: target))
        }
        
      }.disposed(by: disposeBag)
    
    answerListView.button.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.answerListView.backgroundView.isHidden = false
      }).disposed(by: disposeBag)
    
    answerListView.reputationReview.badButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.selected = "bad"
        self.answerListView.reputationReview.badButton.backgroundColor = .black
        self.answerListView.reputationReview.badButton.setTitleColor(.white, for: .normal)
        self.answerListView.reputationReview.goodButton.backgroundColor = .white
        self.answerListView.reputationReview.goodButton.setTitleColor(.black, for: .normal)
      }).disposed(by: disposeBag)
    
    answerListView.reputationReview.goodButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.selected = "good"
        self.answerListView.reputationReview.badButton.backgroundColor = .white
        self.answerListView.reputationReview.badButton.setTitleColor(.black, for: .normal)
        self.answerListView.reputationReview.goodButton.backgroundColor = .black
        self.answerListView.reputationReview.goodButton.setTitleColor(.white, for: .normal)
      }).disposed(by: disposeBag)
    
    answerListView.reputationReview.closeButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        answerListView.backgroundView.isHidden = true
        self.selected = ""
      }).disposed(by: disposeBag)
    
    answerListView.reputationReview.sendButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        if self.selected != "" {
          popViewController()
          if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
          }
        }
      }).disposed(by: disposeBag)
  }
}



