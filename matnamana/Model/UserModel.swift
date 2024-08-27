//
//  UserModel.swift
//  matnamana
//
//  Created by 김윤홍 on 8/27/24.
//

struct User: Codable {
  let info: Info
  let preset: [PresetQuestion]
  let friendList: [Friend]
}

extension User {
  struct Info: Codable {
    let mbti: String
    let career: String
    let education: String
    let email: String
    let location: String
    let name: String
    let phoneNumber: String
    let shortDescription: String
    let profileImage: String
  }

  struct PresetQuestion: Codable {
    let presetTitle: String
    let indice: [Int]
  }

  struct Friend: Codable {
    let nickname: String
    let type: FriendType
  }
}

extension User.Friend {
  enum FriendType: String, Codable {
    case family
    case collegue
    case friend
  }
}
