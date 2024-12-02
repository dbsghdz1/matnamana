//
//  RequestMyQuestion.swift
//  matnamana
//
//  Created by 김윤홍 on 9/20/24.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift

final class RequestMyQuestionController: BaseViewController {
  
  private var requestMyQuestion = RequestMyQuestionView(frame: .zero)
  private let viewModel = RequestMyQuestionViewModel()
  private var presetQuestions = [User.PresetQuestion]()
  private var presetTitles = [String]()
  private var targetId: String
  
  init(targetId: String) {
    self.targetId = targetId
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupView() {
    super.setupView()
    requestMyQuestion = RequestMyQuestionView(frame: UIScreen.main.bounds)
    self.view = requestMyQuestion
  }
  
  override func setNavigation() {
    super.setNavigation()
    self.title = "나만의 질문"
    
    requestMyQuestion.myPresetQuestion.register(RequestMyQuestionCell.self, forCellWithReuseIdentifier: String(describing: RequestMyQuestionCell.self))
    requestMyQuestion.myPresetQuestion.register(AddPresetCell.self, forCellWithReuseIdentifier: String(describing: AddPresetCell.self))
  }
  
  override func bind() {
    super.bind()
    
    let input = RequestMyQuestionViewModel.Input(fetchQuestions: Observable.just(()))
    let output = viewModel.transform(input: input)
    
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<PresetSection>(
      configureCell: { dataSource, collectionView, indexPath, item in
        if indexPath.item < dataSource.sectionModels[indexPath.section].items.count - 1 {
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RequestMyQuestionCell.self), for: indexPath) as? RequestMyQuestionCell else { return UICollectionViewCell() }
          cell.configure(title: item)
          return cell
        } else {
          guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AddPresetCell.self), for: indexPath) as? AddPresetCell else { return UICollectionViewCell() }
          return cell
        }
      }
    )
    
    output.presetQuestions
      .drive(onNext: { [weak self] questions in
        guard let self else { return }
        self.presetQuestions = questions
      })
      .disposed(by: disposeBag)
    
    output.presetTitles
      .map { titles in
        let itemsWithAddCell = titles + ["질문 추가하기"]
        return [PresetSection(header: "Questions", items: itemsWithAddCell)]
      }
      .drive(requestMyQuestion.myPresetQuestion.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
    
    requestMyQuestion.myPresetQuestion.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self else { return }
        print(indexPath.row)
        print(presetTitles.count)
        let lastSectionIndex = requestMyQuestion.myPresetQuestion.numberOfSections - 1
        let lastItemIndex = requestMyQuestion.myPresetQuestion.numberOfItems(inSection: lastSectionIndex) - 1
        if indexPath.section == lastSectionIndex && indexPath.item == lastItemIndex {
          let alert = UIAlertController(title: "알림", message: "나만의 질문을 만들어보세요.", preferredStyle: .alert)
          let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
          alert.addAction(okAction)
          self.present(alert, animated: true, completion: nil)
          if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
          }
        } else {
          let selectedPreset = self.presetQuestions[indexPath.row]
          let selectedQuestions = selectedPreset.presetQuestion
          let presetTitles = selectedPreset.presetTitle
          let targetId = self.targetId
          let referenceVC = ReferenceCheckController(targetId: targetId, questions: selectedQuestions, presetTitle: presetTitles)
          self.navigationController?.pushViewController(referenceVC, animated: true)
        }
      })
      .disposed(by: disposeBag)
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
