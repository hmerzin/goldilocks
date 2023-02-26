//
//  Users.swift
//  goldilocks
//
//  Created by Harry Merzin on 2/13/23.
//

import Foundation
import Alamofire

struct Snack: Decodable, Hashable, Identifiable {
  var id = UUID()
  var _id: String
  var phoneNumber: String
  var createdAt: Date
  
  enum CodingKeys: CodingKey {
    case id
    case _id
    case phoneNumber
    case createdAt
  }
  
  init(_id: String, phoneNumber: String, createdAt: Date) {
    self._id = _id
    self.phoneNumber = phoneNumber
    self.createdAt = createdAt
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self._id = try container.decode(String.self, forKey: ._id)
    self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
    let crAt = try container.decode(Double.self, forKey: .createdAt)
    self.createdAt = Date(timeIntervalSince1970: crAt / 1000)
//    container.key
//    decoder.dateDecodingStrategy = .secondsSince1970
  }
  
  func formatDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EE, MMM d, yyyy"
    return dateFormatter.string(from: self.createdAt)
  }
  func formatTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm a"
    return dateFormatter.string(from: self.createdAt)
  }
  
}

struct User: Decodable, Hashable, Identifiable {
  var id = UUID()
  var _id: String
  var phoneNumber: String
  var name: String
  var snacks: [Snack]
  enum CodingKeys: CodingKey {
//    case id
    case _id
    case phoneNumber
    case name
    case snacks
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
//    self      .id = UUID()
    self._id = try container.decode(String.self, forKey: ._id)
    self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
    self.name = try container.decode(String.self, forKey: .name)
    self.snacks = try container.decode([Snack].self, forKey: .snacks)
  }
}

class Users: ObservableObject {
  @Published var users: [User] = [User]()
  
  func enroll() {
    if let token = UserDefaults.standard.value(forKey: "Token") {
      AF.request(
        "\(BASE_URL)/enroll", method: .post,
        headers: ["Authorization": "bearer \(token)"]
      ).response { response in
        debugPrint(response)
        if(response.response?.statusCode != 200) {
          print("error enrolling: ")
        }
      }
    }
  }
  
  func getUsers() {
    if let token = UserDefaults.standard.value(forKey: "Token") {
      print("requesting")
      AF.request(
        "\(BASE_URL)/users", method: .get,
        headers: ["Authorization": "bearer \(token)"]
      ).responseDecodable(of: [User].self) { response in
        debugPrint(response)
        guard let users = response.value else {
          self.users = []
          return
        }
        self.users = users
      }
    }
  }
}
