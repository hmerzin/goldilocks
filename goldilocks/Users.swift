//
//  Users.swift
//  goldilocks
//
//  Created by Harry Merzin on 2/13/23.
//

import Foundation
import Alamofire

struct User: Decodable, Hashable, Identifiable {
  var id = UUID()
  var _id: String
  var phoneNumber: String
  var name: String
  enum CodingKeys: CodingKey {
//    case id
    case _id
    case phoneNumber
    case name
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
//    self      .id = UUID()
    self._id = try container.decode(String.self, forKey: ._id)
    self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
    self.name = try container.decode(String.self, forKey: .name)
  }
}

class Users: ObservableObject {
  @Published var users: [User] = [User]()
  
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
