//
//  GameViewModel.swift
//  CrossyRoads
//
//  Created by Mykyta Kurochka on 27.01.2025.
//

import Foundation
import SwiftUI
class GameViewModel: ObservableObject {
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isGamePaused: Bool = false
    @Published var players: [Player] = []
    weak var gameScene: GameScene? {
        didSet {
            // Sync the pause state when gameScene is set
            isGamePaused = gameScene?.isGamePaused ?? false
        }
    }
    init() {
        loadPlayers()
    }
    
    func togglePause() {
        if gameScene?.isGamePaused == true {
            print("Trying to resume game...") // Debug print
            isGamePaused = false
            gameScene?.resumeGame()
        } else {
            print("Trying to pause game...") // Debug print
            isGamePaused = true
            gameScene?.pauseGame()
        }
    }
    
    func increaseScore() {
        score += 1
    }
    
    func gameOver() {
        isGamePaused = true
        isGameOver = true
        addPlayer(score: score)
    }
    
    func resetScore() {
        score = 0
        isGameOver = false
        isGamePaused = false
    }
    
    func addPlayer(score: Int) {
        let newPlayer = Player(score: score)
        players.append(newPlayer)
        players.sort { $0.score > $1.score }
        savePlayers()
    }
    
    private func savePlayers() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(players) {
            UserDefaults.standard.set(encoded, forKey: "players")
        }
    }
    
    func loadPlayers() {
        if let data = UserDefaults.standard.data(forKey: "players") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Player].self, from: data) {
                players = decoded
            }
        }
    }
}
