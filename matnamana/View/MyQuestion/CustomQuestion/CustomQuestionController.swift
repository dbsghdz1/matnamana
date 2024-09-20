//
//  CustomQuestionController.swift
//  matnamana
//
//  Created by 김윤홍 on 9/12/24.
//

import UIKit

import RxCocoa
import RxSwift

final class CustomQuestionController: BaseViewController {
  
  private var customQuestion = CustomQuestionView(frame: .zero)
  private let viewModel: CustomQuestionViewModel
  private var selectedIndexPath: IndexPath?
  private var presetTitle: String
  private var addMode: Bool
  
  init(viewModel: CustomQuestionViewModel, presetTitle: String, addMode: Bool) {
    self.viewModel = viewModel
    self.presetTitle = presetTitle
    self.addMode = addMode
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupView() {
    super.setupView()
    customQuestion = CustomQuestionView(frame: UIScreen.main.bounds)
    self.view = customQuestion
  }
  
  override func bind() {
    super.bind()
    
    let input = CustomQuestionViewModel.Input(questions: Observable.just(()))
    let output = viewModel.transform(input: input)
    
    output.questions
      .asObservable()
      .map { questions -> [(String, Bool)] in
        let emptyQuestions = Array(repeating: ("새로운 질문을 추가해 보세요", true), count: max(0, 5 - questions.count))
        let actualQuestions = questions.map { ($0, false) }
        return actualQuestions + emptyQuestions
      }
      .asDriver(onErrorJustReturn: [])
      .drive(customQuestion.customTable.rx.items(cellIdentifier: String(describing: QuestionListCell.self), cellType: QuestionListCell.self)) { [weak self] row, question, cell in
        guard let self else { return }
        let (questionText, isEmptyQuestion) = question
        cell.configureCell(questionCell: questionText)
        if isEmptyQuestion {
          cell.questionLabel.textColor = .lightGray
        }
        customQuestion.questionTitle.text = self.presetTitle
      }
      .disposed(by: disposeBag)
    
    customQuestion.customTable.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self else { return }
        self.selectedIndexPath = indexPath
        
        let totalQuestionController = TotalQuestionController(isCustom: true, addQuestion: false)
        totalQuestionController.onQuestionSelected = { [weak self] selectedQuestion in
          guard let self,
                let selectedIndexPath = self.selectedIndexPath else { return }
          self.viewModel.updateQuestion(at: selectedIndexPath.row, with: selectedQuestion)
          self.updateSelectedCell(at: selectedIndexPath, with: selectedQuestion)
        }
        
        if addMode {
          self.navigationController?.popViewController(animated: true)
        } else {
          self.navigationController?.pushViewController(totalQuestionController, animated: true)
        }
      }).disposed(by: disposeBag)
    
    customQuestion.saveButton.rx.tap
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        guard let id = UserDefaults.standard.string(forKey: "loggedInUserId") else {
          return
        }
        
        FirebaseManager.shared.getPresetList(documentId: id) { questionList, error in
          if error != nil {
            return
          }
          
          var updatedQuestions = questionList ?? []
          let newPresetTitle = self.customQuestion.questionTitle.text ?? "새로운 질문"
          let presetQuestions = User.PresetQuestion(presetTitle: newPresetTitle, presetQuestion: self.viewModel.questions)
          
          // 수정인지, 추가인지 구분하는 로직
          if let existingIndex = updatedQuestions.firstIndex(where: { $0.presetTitle == newPresetTitle }) {
            // 질문이 이미 존재하면 수정
            updatedQuestions[existingIndex] = presetQuestions
            print("기존 질문 수정")
          } else {
            // 질문이 존재하지 않으면 추가
            updatedQuestions.append(presetQuestions)
            print("새로운 질문 추가")
          }
          
          // Firestore에 업데이트
          FirebaseManager.shared.updatePresetQuestions(for: id, presetQuestions: updatedQuestions) { success, error in
            if success {
              print("preset 질문 추가/수정 성공")
            } else {
              print("preset 질문 추가/수정 실패")
            }
          }
        }
        
        self.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  private func updateSelectedCell(at indexPath: IndexPath, with question: String) {
    if let cell = customQuestion.customTable.cellForRow(at: indexPath) as? QuestionListCell {
      cell.configureCell(questionCell: question)
    }
  }
}
