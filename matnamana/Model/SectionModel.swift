//
//  SectionModel.swift
//  matnamana
//
//  Created by pc on 9/2/24.
//
import RxDataSources

enum Section: Int, CaseIterable {
  case friendRequest
  case myRequests
  case receivedRequests
  
  var title: String {
    switch self {
    case .friendRequest: return "친구 평판조회"
    case .myRequests: return "요청한 평판조회"
    case .receivedRequests: return "요청받은 평판조회"
    }
  }
}

struct Item {
  let userNickName: String
  let profileImageUrl: String
  let requesterId: String
  let targetId: String
  let status: String
  
  init(userNickName: String, profileImageUrl: String, requesterId: String, targetId: String, status: String) {
    self.userNickName = userNickName
    self.profileImageUrl = profileImageUrl
    self.requesterId = requesterId
    self.targetId = targetId
    self.status = status
  }
}

struct FriendsSection {
  var header: String
  var items: [User.Friend]
}

extension FriendsSection: SectionModelType {
  typealias Item = User.Friend
  
  init(original: FriendsSection, items: [User.Friend]) {
    self = original
    self.items = items
  }
}

struct PresetSection {
  var header: String
  var items: [Item]
}

extension PresetSection: SectionModelType {
  typealias Item = String  // Item을 String으로 설정 (필요시 다른 타입 사용 가능)
  
  init(original: PresetSection, items: [Item]) {
    self = original
    self.items = items
  }
}
