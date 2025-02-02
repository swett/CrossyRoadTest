//
//  GameViewSpriteKit.swift
//  CrossyRoads
//
//  Created by Mykyta Kurochka on 27.01.2025.
//

import Foundation

import SwiftUI
import SpriteKit

struct GameViewSpriteKit: UIViewRepresentable {
    @ObservedObject var viewModel: GameViewModel
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        
        let initialSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let scene = GameScene(size: initialSize)
        scene.scaleMode = .resizeFill
        scene.connect(viewModel: viewModel)
        skView.presentScene(scene)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // We can implement this method to handle any dynamic updates to the view
    }
    
}
