//
//  PlayerModel.swift
//  CrossyRoads
//
//  Created by Mykyta Kurochka on 02.02.2025.
//

import Foundation
struct Player: Identifiable, Codable {
    let id = UUID()
    var name: String = "Player"
    var score: Int
    let date: Date = Date()
}
