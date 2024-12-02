//
//  File.swift
//  matnamana
//
//  Created by 김윤홍 on 8/29/24.
//

struct ReputationRequest: Codable {
  let requester: UserProfile?
  let target: UserProfile?
  let questionList: [QuestionList]
  let status: RequestStatus
  let selectedFriends: [UserProfile]?
  let selectedFriendsUserIds: [String]?
}


struct QuestionList: Codable {
  let answer: [String: String]?
  let contentDescription: String
}

extension ReputationRequest {
  enum RequestStatus: String, Codable {
    case pending
    case approved
    case rejected
  }
}

struct UserProfile: Codable {
  let nickName: String?
  let profileImage: String?
  let userId: String?
}
