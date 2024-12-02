//
//  SearchController.swift
//  matnamana
//
//  Created by 김윤홍 on 8/23/24.
//

import UIKit

import RxCocoa
import RxSwift

final class TotalQuestionController: BaseViewController {
  
  private var viewModel = TotalQuestionViewModel()
  private var totalQuestionView = TotalQuestionView(frame: .zero)
  private let isCustom: Bool
  private let addQuestion: Bool
  private var selectedQuestions = [String]()
  private var isSelected = Array(repeating: Array(repeating: false, count: 1000), count: 3)
  var onQuestionSelected: ((String) -> Void)?
  let customButton = UIButton(type: .system)
  
  init(isCustom: Bool,
       addQuestion: Bool) {
    self.isCustom = isCustom
    self.addQuestion = addQuestion
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupView() {
    super.setupView()
    totalQuestionView = TotalQuestionView(frame: UIScreen.main.bounds)
    self.view = totalQuestionView
  }
  
  override func setNavigation() {
    super.setNavigation()
    self.title = "전체 질문 리스트"
    
    if addQuestion {
      let rightButton = UIBarButtonItem(image: UIImage(named: "ListOff"), style: .plain, target: nil, action: nil)
      navigationItem.rightBarButtonItem = rightButton
      
      rightButton.rx.tap
        .subscribe(onNext: { [weak self] in
          guard let self else { return }
          let viewModel = CustomQuestionViewModel(presetQuestions: selectedQuestions)
          self.navigationController?.pushViewController(CustomQuestionController(viewModel: viewModel,
                                                                                 presetTitle: "새로운 질문",
                                                                                 addMode: true, cellIndexPath: 0
                                                                                ), animated: true)
        })
        .disposed(by: disposeBag)
    }
  }
  
  override func bind() {
    let input = TotalQuestionViewModel.Input(
      fetchQuestions: Observable.just(()),
      selectedSegment: totalQuestionView.questionSegement.rx.selectedSegmentIndex.asObservable()
    )
    let output = viewModel.transform(input: input)
    
    output.questionList
      .drive(totalQuestionView.questionList.rx
        .items(cellIdentifier: String(describing: QuestionListCell.self),
               cellType: QuestionListCell.self)) { [weak self] row, question, cell in
        guard let self else { return }
        let count = question.contentDescription.count
//        if self.isSelected.count != count {
//          self.isSelected = Array(repeating: false, count: 100)
//        }
        if self.addQuestion {
          cell.customButton.isHidden = false
          let image = UIImage(systemName: "plus")
          cell.customButton.setImage(image, for: .normal)
          cell.customButton.setTitle("", for: .normal)
        } else {
          cell.customButton.isHidden = true
        }
        cell.configureCell(questionCell: question.contentDescription)
        
        if self.isSelected[totalQuestionView.questionSegement.selectedSegmentIndex][row] {
          cell.customButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
          cell.customButton.tintColor = UIColor.manaMainColor
        } else {
          cell.customButton.setImage(UIImage(systemName: "plus"), for: .normal)
          cell.customButton.tintColor = UIColor.manaMainColor
        }
      }.disposed(by: disposeBag)
    
    totalQuestionView.questionList.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self else { return }
        if self.isSelected[totalQuestionView.questionSegement.selectedSegmentIndex][indexPath.row] {
          self.isSelected[totalQuestionView.questionSegement.selectedSegmentIndex][indexPath.row] = false
        } else {
          self.isSelected[totalQuestionView.questionSegement.selectedSegmentIndex][indexPath.row] = true
        }
        if self.containsTrue() {
          navigationItem.rightBarButtonItem?.image = UIImage(named: "ListOn")
        } else {
          navigationItem.rightBarButtonItem?.image = UIImage(named: "ListOff")
        }

        if let selectedCell = self.totalQuestionView.questionList.cellForRow(at: indexPath) as? QuestionListCell {
          let selectedQuestion = selectedCell.questionLabel.text ?? ""
          
          if let index = self.selectedQuestions.firstIndex(of: selectedQuestion) {
            self.selectedQuestions.remove(at: index)
            selectedCell.customButton.setImage(UIImage(systemName: "plus"), for: .normal)
            selectedCell.customButton.tintColor = UIColor.manaMainColor
          } else {
            if self.selectedQuestions.count < 5 {
              self.selectedQuestions.append(selectedQuestion)
              selectedCell.customButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
              selectedCell.customButton.tintColor = UIColor.manaMainColor
            } else {
              self.showToast(message: "최대 5개의 질문만 선택할 수 있습니다.", duration: 1.0)
            }
          }
          self.onQuestionSelected?(selectedQuestion)
        }
        
        if !addQuestion {
          self.navigationController?.popViewController(animated: true)
        }
      }).disposed(by: disposeBag)
    
    totalQuestionView.questionSegement.rx.selectedSegmentIndex
      .subscribe(onNext: { [weak self] _ in
        guard let self else { return }
        self.totalQuestionView.questionList.reloadData()
        let rowCount = self.totalQuestionView.questionList.numberOfRows(inSection: 0)
        
        if rowCount > 0 {
          let firstIndexPath = IndexPath(row: 0, section: 0)
          self.totalQuestionView.questionList.scrollToRow(at: firstIndexPath, at: .top, animated: false)
        }
      }).disposed(by: disposeBag)
  }
  
  private func containsTrue() -> Bool {
    return isSelected.contains { innerArray in
      innerArray.contains(true)
    }
  }
}

extension UIViewController {
  func showToast(message: String, duration: Double) {
    let toastLabel = UILabel()
    toastLabel.text = message
    toastLabel.backgroundColor = UIColor.manaMainColor.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center
    toastLabel.font = UIFont.systemFont(ofSize: 14.0)
    toastLabel.numberOfLines = 0
    
    let maxSize = CGSize(width: self.view.frame.size.width - 40, height: self.view.frame.size.height - 40)
    var expectedSize = toastLabel.sizeThatFits(maxSize)
    expectedSize.width += 20
    expectedSize.height += 20
    
    toastLabel.frame = CGRect(x: (self.view.frame.size.width - expectedSize.width) / 2,
                              y: self.view.frame.size.height - 150,
                              width: expectedSize.width,
                              height: expectedSize.height)
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds = true
    
    self.view.addSubview(toastLabel)
    
    UIView.animate(withDuration: 1.0, delay: duration, options: .curveEaseOut, animations: {
      toastLabel.alpha = 0.0
    }, completion: { _ in
      toastLabel.removeFromSuperview()
    })
  }
}
