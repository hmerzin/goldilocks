//
//  Constants.swift
//  goldilocks
//
//  Created by Harry Merzin on 2/13/23.
//

import SwiftUI
import Foundation

let URL_HOME = "http://10.0.0.38:8080"
let URL_PROD = "https://snackbot-server.herokuapp.com"

let color_choices: [Color] = [.blue, .green, .orange, .yellow, .red]
let emoji_choices: [String] = ["🐠", "🍣", "🐡", "🎣", "🐟"]

let BASE_URL = URL_PROD //URL_HOME

let preview_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IisxNjMxMzE3NTg4NSIsImlhdCI6MTY3Njc0ODcyOCwiZXhwIjoxNzA4MzA2MzI4fQ.bhJuT_NKpdjiTgezvpkQ_68LPU52Xnsfi3Z9fqGRED4"

func randomFish() -> String {
  return emoji_choices.randomElement() ?? "🐠"
}

func randomColor() -> Color {
  return color_choices.randomElement() ?? .blue
}
