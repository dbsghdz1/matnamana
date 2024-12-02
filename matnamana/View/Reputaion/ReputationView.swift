//
//  ReputationView.swift
//  matnamana
//
//  Created by pc on 9/6/24.
//

import UIKit

import SnapKit

final class ReputationView: BaseView {
  private let viewModel = ReputationViewModel()
  
  let searchFriend = UIButton(type: .system).then {
    let image = UIImage(systemName: "magnifyingglass.circle")
    $0.setImage(image, for: .normal)
    $0.imageView?.contentMode = .scaleAspectFit
    $0.setTitle("", for: .normal)
  }
  
  lazy var collecitonView = UICollectionView(frame: .zero,
                                                     collectionViewLayout: createLayout()).then {
    $0.register(DefaultCell.self,
                forCellWithReuseIdentifier: DefaultCell.id)
    $0.register(FriendRequestCell.self,
                forCellWithReuseIdentifier: FriendRequestCell.id)
    $0.register(MyRequestsCell.self,
                forCellWithReuseIdentifier: MyRequestsCell.id)
    $0.register(ReceivedRequestCell.self,
                forCellWithReuseIdentifier: ReceivedRequestCell.id)
    $0.register(ReputaionSectionHeaderView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ReputaionSectionHeaderView.id)
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
    
      switch Section(rawValue: sectionIndex) {

      case .friendRequest:
        return self.collectionViewLayout()
      case .myRequests:
        return self.otherCollectionViewLayout()
      case .receivedRequests:
        return self.otherCollectionViewLayout()
      default:
        return nil
      }
    }
    return layout
  }

  
  private func collectionViewLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .absolute(130),
      heightDimension: .absolute(160)
    )
    
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item]
    )
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.interGroupSpacing = 20
    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
    
    let headerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(44)
    )
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
    section.boundarySupplementaryItems = [header]
    
    return section
  }
  
  private func otherCollectionViewLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .absolute(350),
      heightDimension: .absolute(140)
    )
    
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item]
    )
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    section.interGroupSpacing = 10
    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
    
    let headerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(44)
    )
    
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
    section.boundarySupplementaryItems = [header]
    
    return section
  }
  
  override func configureUI() {
    self.addSubview(collecitonView)

  }
  
  override func setConstraints() {
    collecitonView.snp.makeConstraints {
      $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
      $0.centerX.equalToSuperview()
      $0.width.height.equalToSuperview()
      $0.bottom.equalTo(self.safeAreaLayoutGuide)
    }
  }
}
