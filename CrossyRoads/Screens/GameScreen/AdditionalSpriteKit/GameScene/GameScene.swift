//
//  GameScene.swift
//  CrossyRoads
//
//  Created by Mykyta Kurochka on 27.01.2025.
//

import Foundation
import SpriteKit
class GameScene: SKScene, SKPhysicsContactDelegate {
    private var player: SKSpriteNode!
    private let playerSize = CGSize(width: 40, height: 40)
    private var lanes: [LaneNode] = []
    private let laneHeight: CGFloat = 50
    private let laneCount = 90
    private let playerSpeed: CGFloat = 50
    var isGamePaused = false
    var isColliding = false
    private var viewModel: GameViewModel?
    private var previousPlayerY: CGFloat = 0
    private var lastScoredLaneIndex: Int = 0
    var roadCrossedCount = 0
    var lastYPosition: CGFloat = 0
    // Collision categories
    private let playerCategory: UInt32 = 0x1 << 0
    private let carCategory: UInt32 = 0x1 << 1
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        
        backgroundColor = .white
        physicsWorld.gravity = .zero // No gravity
        physicsWorld.contactDelegate = self
        
        
        
        setupPlayer()
        setupLanes()
        setupCamera()
        
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        DispatchQueue.main.async {
            self.player.position = CGPoint(x: self.size.width / 2, y: 600)
        }
    }

    
    func connect(viewModel: GameViewModel) {
        self.viewModel = viewModel
        viewModel.gameScene = self
    }
    
    private func setupCamera() {
        // Create and assign a camera node
        let cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
        // Position the camera to follow the player's initial position
        cameraNode.position = player.position
    }
    
    private func setupPlayer() {
        player = SKSpriteNode(imageNamed: "character") // Ensure "character" is in your assets
        player.size = playerSize
        // Set the player's position to the bottom-center of the screen
//        player.position = CGPoint(x: size.width / 2, y: playerSize.height / 2 + 20) // 20 is padding
        player.zPosition = 1
        
        // Add physics body
        player.physicsBody = SKPhysicsBody(rectangleOf: playerSize)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.car
        player.physicsBody?.collisionBitMask = 0 // No physical collision, only detection
        
        addChild(player)
    }
    
    private func setupLanes() {
        for i in 0..<laneCount {
            let laneType: LaneType = (i % 2 == 0) ? .grass : .road
            let lane = LaneNode(type: laneType, width: size.width)
            // Center the lane horizontally
            lane.position = CGPoint(x: size.width / 2, y: CGFloat(i) * laneHeight)
            lane.zPosition = 0 // Ensure lanes are behind the player
            addChild(lane)
            lanes.append(lane)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard !isGamePaused else { return }
        
        // Scroll lanes downward
        for lane in lanes {
            if lane.position.y < -laneHeight {
                lane.position.y = lanes.last!.position.y + laneHeight
                lanes.append(lane)
                lanes.removeFirst()
                lane.resetLane()
            }
        }
        
        // Move traffic in all lanes
        for lane in lanes where lane.type == .road {
            lane.moveTraffic()
        }
        
        // Update camera to follow the player
        camera?.position = CGPoint(x: size.width / 2, y: player.position.y)
    }
    
    func laneMove() {
        for lane in lanes {
            lane.position.y -= 50
        }
    }
    
    func movePlayer(direction: String) {
        guard !isGamePaused else {
                print("movePlayer not called because isGamePaused is true")
                return
            }
        print("movePlayer called with direction: \(direction)")
        let moveDistance = playerSpeed
        let moveAction: SKAction
        
        switch direction {
        case "up":
            moveAction = SKAction.moveBy(x: 0, y: moveDistance, duration: 0.2)
            player.run(moveAction, completion: { [weak self] in
                guard let self = self else { return }
                print("moved")
//                let currentLaneIndex = Int(self.player.position.y / self.laneHeight)
//                if currentLaneIndex > self.lastScoredLaneIndex && currentLaneIndex % 2 == 1 {
//                    
//                    self.lastScoredLaneIndex = currentLaneIndex
//                }
//                self.viewModel?.score += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let self = self else { return }
                    
                    // If the player was not hit by a car, add score
                    if !self.isColliding {
                        self.viewModel?.score += 1
                        print("Score: \(self.viewModel?.score ?? 0)")
                    }
                    
                    // Reset collision flag
                    self.isColliding = false
                }
            })
            laneMove()
            
        case "left":
            moveAction = SKAction.moveBy(x: -moveDistance, y: 0, duration: 0.2)
            player.run(moveAction)
            
        case "right":
            moveAction = SKAction.moveBy(x: moveDistance, y: 0, duration: 0.2)
            player.run(moveAction)
            
        default:
            return
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if abs(location.x - player.position.x) <= player.size.width / 2 {
            if location.y > player.position.y {
                print("make up")
                movePlayer(direction: "up")
            }
        } else if location.x < player.position.x {
            movePlayer(direction: "left")
        } else if location.x > player.position.x {
            movePlayer(direction: "right")
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.categoryBitMask
        let bodyB = contact.bodyB.categoryBitMask
        
        if (bodyA == playerCategory && bodyB == carCategory) || (bodyA == carCategory && bodyB == playerCategory) {
            isColliding = true
            handleGameOver()
        }
    }
    
    // Handle Game Over
    func handleGameOver() {
        isGamePaused = true
        viewModel?.gameOver()
    }
    
    // Pause Game
    func pauseGame() {
        self.isGamePaused = true
        self.isPaused = true
        physicsWorld.speed = 0
        viewModel?.isGamePaused = true // Notify ViewModel
        print("Game Paused") // Debug print
    }

    func resumeGame() {
        self.isGamePaused = false
        self.isPaused = false
        physicsWorld.speed = 1
        viewModel?.isGamePaused = false // Notify ViewModel
        print("Game Resumed") // Debug print
    }

    
    // Reset Game
    func resetGame() {
        isGamePaused = false
        isColliding = false
        self.isPaused = false
        physicsWorld.speed = 1
        viewModel?.resetScore()
        lastScoredLaneIndex = 0
        
        // Reset player position to bottom-center with the same padding as in setupPlayer.
        self.player.position = CGPoint(x: self.size.width / 2, y: 600)
        
        // Remove old lanes and create new ones (with centered positions)
        lanes.forEach { $0.removeFromParent() }
        lanes.removeAll()
        setupLanes()
        print("Game reset. isGamePaused = \(isGamePaused), scene.isPaused = \(self.isPaused)")
    }
}







