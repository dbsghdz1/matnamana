//
//  QuestionModel.swift
//  matnamana
//
//  Created by 김윤홍 on 8/27/24.
//

struct Question: Codable {
  let contents: [Content]
}

extension Question {
  struct Content: Codable {
    let contentType: String
    let contentDescription: String
  }
}

enum QuestionType: String {
  case couple = "연애 질문"
  case simpleMannam = "느슨한 만남"
  case bussiness = "비즈니스"
}

enum DocumentTranslation: String {
  case iceBreaking = "iceBreaking"
  case bestFriend = "BestFriend"
  case bestFamily = "BestFamily"
  case bestMeeting = "BestMeeting"
  case bestCoworker = "BestCoworker"
  
  var koreanTranslation: String {
    switch self {
    case .iceBreaking:
      return "느슨한 만남 질문"
    case .bestFriend:
      return "Best 친구 질문"
    case .bestFamily:
      return "Best 가족 질문"
    case .bestMeeting:
      return "Best 소개팅 질문"
    case .bestCoworker:
      return "Best 동료 질문"
    }
  }
  
  static func fromKorean(_ koreanText: String) -> DocumentTranslation? {
    switch koreanText {
    case "아이스 브레이킹 질문":
      return .iceBreaking
    case "Best 친구 질문":
      return .bestFriend
    case "Best 가족 질문":
      return .bestFamily
    case "Best 소개팅 질문":
      return .bestMeeting
    case "Best 동료 질문":
      return .bestCoworker
    default:
      return nil
    }
  }
}

struct DocumentModel {
  static func translateKorean(_ documentId: String) -> String {
    return DocumentTranslation(rawValue: documentId)?.koreanTranslation ?? "알 수 없는 문서"
  }
  
  static func translateEnglish(_ koreanText: String) -> String {
    return DocumentTranslation.fromKorean(koreanText)?.rawValue ?? "알 수 없는 문서"
  }
}
