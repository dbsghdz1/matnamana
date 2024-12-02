//
//  MainQuestionController.swift
//  matnamana
//
//  Created by 김윤홍 on 9/7/24.
//

import UIKit

import RxCocoa
import RxSwift

final class MainQuestionViewController: BaseViewController {
  
  private var mainQuestionView = MainQuestionView(frame: .zero)
  private let viewModel = MainQuestionViewModel()
  private var presetTitles = [String]()
  private var presetQuestions = [User.PresetQuestion]()
  
  override func setupView() {
    super.setupView()
    mainQuestionView = MainQuestionView(frame: UIScreen.main.bounds)
    self.view = mainQuestionView
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetchData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
  }
  
  private func fetchData() {
    viewModel.fetchQuestionList()
      .subscribe(onNext: { [weak self] questions in
        guard let self = self else { return }
        self.presetQuestions = questions
        self.mainQuestionView.mainCollection.reloadData()
      })
      .disposed(by: disposeBag)
  }
  
  private func setupCollectionView() {
    mainQuestionView.mainCollection.delegate = self
    mainQuestionView.mainCollection.dataSource = self
  }
  
  func bindCell(cell: QuestionCell) {
    
    cell.disposeBag = DisposeBag()
    
    let input = MainQuestionViewModel.Input(
      totalButtonTap: cell.totalButtonTap,
      coupleButtonTap: cell.coupleButtonTap,
      simpleMannamButtonTap: cell.simpleMannamButtonTap,
      businessButtonTap: cell.businessButtonTap,
      fetchQuestions: Observable.just(())
    )
    
    let output = viewModel.transform(input: input)
    
    output.presetTitles
      .drive(onNext: { [weak self] titles in
        guard let self else { return }
        self.presetTitles = titles
        self.mainQuestionView.mainCollection.reloadSections(IndexSet(integer: 2))
      })
      .disposed(by: cell.disposeBag)
    
    output.presetQuestions
      .drive(onNext: { [weak self] questions in
        guard let self else { return }
        self.presetQuestions = questions
        self.mainQuestionView.mainCollection.reloadSections(IndexSet(integer: 2))
      })
      .disposed(by: cell.disposeBag)
    
    output.navigateTo
      .subscribe(onNext: { [weak self] destination in
        guard let self else { return }
        
        let vc: UIViewController
        
        switch destination {
        case .totalQuestion:
          vc = TotalQuestionController(isCustom: false, addQuestion: false)
        case .coupleQuestion:
          let viewModel = TypeQuestionViewModel(questionId: "BestMeeting")
          vc = TypeQuestionController(viewModel: viewModel, title: "연애 질문")
          
        case .simpleMannam:
          let viewModel = TypeQuestionViewModel(questionId: "IceBreaking")
          vc = TypeQuestionController(viewModel: viewModel, title: "느슨한 만남")
          
        case .business:
          let viewModel = TypeQuestionViewModel(questionId: "BestCoworker")
          vc = TypeQuestionController(viewModel: viewModel, title: "비즈니스")
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: cell.disposeBag)
  }
  
  func bindCell(cell: CustomQuestionCell, indexPath: Int) {
    
    cell.disposeBag = DisposeBag()
    
    let input = MainQuestionViewModel.Input(
      totalButtonTap: Observable.empty(),
      coupleButtonTap: Observable.empty(),
      simpleMannamButtonTap: Observable.empty(),
      businessButtonTap: Observable.empty(),
      fetchQuestions: Observable.empty()
    )
    
    let output = viewModel.transform(input: input)
    
    output.presetTitles
      .drive(onNext: { [weak self] titles in
        guard let self = self else { return }
        print(titles)
        self.presetTitles = titles
        self.mainQuestionView.mainCollection.reloadSections(IndexSet(integer: 2))
      })
      .disposed(by: cell.disposeBag)
    
    cell.buttonTap
      .subscribe(onNext: { [weak self] in
        guard let self, let selectedQuestion = cell.selectedQuestion else { return }
        let viewModel = CustomQuestionViewModel(presetQuestions: selectedQuestion.presetQuestion)
        let vc = CustomQuestionController(viewModel: viewModel,
                                          presetTitle: selectedQuestion.presetTitle,
                                          addMode: false, cellIndexPath: indexPath)
        self.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: cell.disposeBag)
  }
  
  private func bindCell(cell: AddNewQuestionCell) {
    
    cell.disposeBag = DisposeBag()
    
    cell.buttonTap
      .subscribe(onNext: { [weak self] in
        guard let self else { return }
        self.navigationController?.pushViewController(TotalQuestionController(isCustom: true, addQuestion: true), animated: true)
      }).disposed(by: cell.disposeBag)
  }
}

extension MainQuestionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.section == 0 && indexPath.item == 0 {
      if let url = URL(string: "https://teaminpact.com") {
        UIApplication.shared.open(url, options: [:])
      }
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0, 1:
      return 1
    case 2:
      return presetTitles.count
    case 3:
      return 1
    default:
      return 0
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case 0:
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BannerCell.self), for: indexPath) as? BannerCell else { return UICollectionViewCell() }
      return cell
    case 1:
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: QuestionCell.self), for: indexPath) as? QuestionCell else { return UICollectionViewCell() }
      bindCell(cell: cell)
      return cell
    case 2:
      let selectedQuestion = presetQuestions[indexPath.row]
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CustomQuestionCell.self), for: indexPath) as? CustomQuestionCell else { return UICollectionViewCell() }
      cell.configure(title: presetTitles[indexPath.row], question: selectedQuestion)
      print(indexPath.row)
      bindCell(cell: cell, indexPath: indexPath.row)
      return cell
    case 3:
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AddNewQuestionCell.self), for: indexPath) as? AddNewQuestionCell else { return UICollectionViewCell() }
      bindCell(cell: cell)
      return cell
    default:
      fatalError("default cell")
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard kind == UICollectionView.elementKindSectionHeader, indexPath.section == 2 else {
      return UICollectionReusableView()
    }
    
    guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: HeaderView.self), for: indexPath) as? HeaderView else { return UICollectionReusableView() }
    header.configure(with: "나만의 질문")
    return header
  }
}
