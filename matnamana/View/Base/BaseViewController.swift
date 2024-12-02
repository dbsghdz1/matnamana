//
//  BaseViewController.swift
//  matnamana
//
//  Created by 김윤홍 on 9/4/24.
//

import UIKit

import RxCocoa
import RxSwift
import RxKeyboard

class BaseViewController: UIViewController {
  var disposeBag = DisposeBag()
  
  override func loadView() {
    setupView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
    setNavigation()
    setupKeyboardHandling()
//    setupDismissKeyboardGesture()
    overrideUserInterfaceStyle = .light
    view.backgroundColor = .systemBackground
  }
  
  func setNavigation() {
//    navigationController?.navigationBar.prefersLargeTitles = true
//    navigationItem.largeTitleDisplayMode = .always
  }
  
  func bind() {
    
  }
  
  func setupView() {
    
  }

  private func setupKeyboardHandling() {
    RxKeyboard.instance.visibleHeight
      .drive(onNext: { [weak self] keyboardHeight in
        guard let self = self else { return }
        self.adjustForKeyboardHeight(keyboardHeight)
      })
      .disposed(by: disposeBag)
  }
  
  func adjustForKeyboardHeight(_ keyboardHeight: CGFloat) {

    // 전체 뷰의 subviews 중 UIScrollView 타입의 뷰에 대해 인셋 조정
    UIView.animate(withDuration: 0.3) {
      let inset = keyboardHeight > 0 ? keyboardHeight : 0
      if let scrollView = self.view as? UIScrollView {
        // self.view가 UIScrollView일 경우 처리
        scrollView.contentInset.bottom = inset
        scrollView.scrollIndicatorInsets.bottom = inset
      } else {
        // self.view의 서브뷰들 중 UIScrollView가 있을 경우 처리
        for subview in self.view.subviews where subview is UIScrollView {
          guard let scrollView = subview as? UIScrollView else { continue }
          scrollView.contentInset.bottom = inset
          scrollView.scrollIndicatorInsets.bottom = inset
        }
      }
    }
  }

  func setupDismissKeyboardGesture() {
    let tapGesture = UITapGestureRecognizer()
    self.view.addGestureRecognizer(tapGesture)
    
    tapGesture.rx.event
      .bind(onNext: { [weak self] _ in
        guard let self else { return }
        self.view.endEditing(true) // 키보드를 숨기기
      })
      .disposed(by: disposeBag)
  }
}

