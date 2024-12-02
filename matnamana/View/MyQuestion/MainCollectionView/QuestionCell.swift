//
//  QuestionCell.swift
//  matnamana
//
//  Created by 김윤홍 on 9/12/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import Then

final class QuestionCell: UICollectionViewCell {
  
  var disposeBag = DisposeBag()
  
  var totalButtonTap: Observable<Void> {
    return totalQuestionButton.rx.tap.asObservable()
  }
  
  var coupleButtonTap: Observable<Void> {
    return coupleQuestonButton.rx.tap.asObservable()
  }
  
  var simpleMannamButtonTap: Observable<Void> {
    return simpleMannamButton.rx.tap.asObservable()
  }
  
  var businessButtonTap: Observable<Void> {
    return bussinessButton.rx.tap.asObservable()
  }
  
  let totalQuestionButton = UIButton().then {
    let buttonImage = UIImage(named: "mainBannerImage")
    $0.backgroundColor = .manaMainColor
    $0.layer.cornerRadius = 16
    $0.setTitle("전체 질문 리스트", for: .normal)
  }
  
  let coupleQuestonButton = UIButton().then {
    let buttonImage = UIImage(named: "coupleImage")
    $0.setImage(buttonImage, for: .normal)
  }
  
  let simpleMannamButton = UIButton().then {
    let buttonImage = UIImage(named: "mannamImage")
    $0.setImage(buttonImage, for: .normal)
  }
  
  let bussinessButton = UIButton().then {
    let buttonImage = UIImage(named: "bussinessImage")
    $0.setImage(buttonImage, for: .normal)
  }
  
  private let coupleLabel = UILabel().then {
    $0.text = "연애 질문"
    $0.textAlignment = .center
  }
  
  private let mannamLabel = UILabel().then {
    $0.text = "느슨한 만남"
    $0.textAlignment = .center
  }
  
  private let bussinessLabel = UILabel().then {
    $0.text = "비즈니스"
    $0.textAlignment = .center
  }
  
  private let labelStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
    $0.distribution = .fillEqually
  }
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 10
    $0.distribution = .fillEqually
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [
      coupleQuestonButton,
      simpleMannamButton,
      bussinessButton
    ].forEach { buttonStackView.addArrangedSubview($0) }
    
    [
      coupleLabel,
      mannamLabel,
      bussinessLabel
    ].forEach { labelStackView.addArrangedSubview($0) }
    
    [
      totalQuestionButton,
      buttonStackView,
      labelStackView
    ].forEach { contentView.addSubview($0) }
  }
  
  private func setConstraints() {
    
    totalQuestionButton.snp.makeConstraints {
      $0.top.equalTo(labelStackView.snp.bottom).offset(10)
      $0.horizontalEdges.equalToSuperview().inset(20)
      $0.height.equalTo(56)
      $0.bottom.equalToSuperview()
    }
    
    buttonStackView.snp.makeConstraints {
      $0.top.horizontalEdges.equalToSuperview().inset(20)
      $0.horizontalEdges.equalToSuperview().inset(20)
      $0.height.equalTo(110)
    }
    
    labelStackView.snp.makeConstraints {
      $0.top.equalTo(buttonStackView.snp.bottom).offset(10)
      $0.horizontalEdges.equalToSuperview().inset(20)
      
    }
  }
}
