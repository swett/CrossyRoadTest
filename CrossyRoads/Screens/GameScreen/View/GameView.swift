//
//  GameView.swift
//  CrossyRoads
//
//  Created by Mykyta Kurochka on 27.01.2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    var body: some View {
        ZStack {
            // Background
            Color.white
                .ignoresSafeArea()
            GameViewSpriteKit(viewModel: viewModel)
                .ignoresSafeArea(.all)
            VStack {
                // Top: Score Counter and Pause/Resume Buttons
                HStack {
                    Text("Score: \(viewModel.score)")
                        .font(.title)
                        .foregroundStyle(Color.white)
                    Spacer()

                    Button {
                        viewModel.togglePause()
                    } label: {
                        Image(systemName: viewModel.isGamePaused ? "play.fill" : "pause")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.white)
                            
                    }
                }
                .padding(.horizontal, 16)
                Spacer()
            }
            if viewModel.isGamePaused {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea(.all)
                    VStack(spacing: 20) {
                        Text("\(viewModel.isGameOver ? "You are lose" : "Pause")")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        if !viewModel.isGameOver {
                            Button {
                                viewModel.togglePause()
                            } label: {
                                Text("Continue")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 15, weight: .bold))
                                
                                
                            }
                        }
                        Button {
                            viewModel.resetScore()
                            viewModel.gameScene?.resetGame()
                        } label: {
                            Text("Restart")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 15, weight: .bold))
                        }
                        Button {
                            
                        } label: {
                            Text("Quit")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 15, weight: .regular))
                        }
                        
                        
                        LeaderboardView(players: viewModel.players)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

#Preview {
    GameView()
}
