//
//  replyController.swift
//  matnamana
//
//  Created by pc on 9/12/24.
//

import UIKit

import RxCocoa
import RxSwift

final class ReplyController: BaseViewController {
  
  private var name: String
  private let viewModel = ReplyViewModel()
  private var replyView = ReplyView(frame: .zero)
  
  init(name: String) {
    self.name = name
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.fetchQuestionList(nickName: name)
  }
  
  override func bind() {
    super.bind()
    
    viewModel.questionDataRelay
      .observe(on: MainScheduler.instance)
      .bind(to: replyView.tableView.rx.items(cellIdentifier: "QuestionCell")) { _, text, cell in
        cell.textLabel?.text = text
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.numberOfLines = 0
      }
      .disposed(by: disposeBag)
    
    replyView.tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self else { return }
        let selectedQuestion = self.viewModel.questionDataRelay.value[indexPath.row]
        if self.viewModel.answers.contains(where: { $0.question == selectedQuestion }) {
          return
        }
        let answerController = AnswerController(replyViewModel: viewModel, name: name, question: selectedQuestion)
        pushViewController(answerController)
      })
    
    replyView.sendButton.rx.tap
      .subscribe(onNext: { [weak self] text in
        guard let self else { return }        
        self.viewModel.sendAnswers(nickName: name)
      }).disposed(by: disposeBag)
  }
  
  override func setupView() {
    super.setupView()
    replyView = ReplyView(frame: UIScreen.main.bounds)
    self.view = replyView
    
    replyView.reName(name: name)
  }
  
}
