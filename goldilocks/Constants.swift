//
//  Constants.swift
//  goldilocks
//
//  Created by Harry Merzin on 2/13/23.
//

import SwiftUI
import Foundation

let URL_HOME = "http://10.0.0.38:5000"
let URL_PROD = "https://snackbot-server.herokuapp.com"

let color_choices: [Color] = [.blue, .green, .orange, .yellow, .red]
let emoji_choices: [String] = ["🐠", "🍣", "🐡", "🎣", "🐟"]

let BASE_URL = URL_PROD

func randomFish() -> String {
  return emoji_choices.randomElement() ?? "🐠"
}

func randomColor() -> Color {
  return color_choices.randomElement() ?? .blue
}
