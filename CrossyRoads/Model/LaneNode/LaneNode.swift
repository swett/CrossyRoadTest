//
//  LaneNode.swift
//  CrossyRoads
//
//  Created by Mykyta Kurochka on 27.01.2025.
//

import Foundation
import SpriteKit

enum LaneType {
    case grass, road
}
struct PhysicsCategory {
    static let car: UInt32 = 0x1 << 0
    static let player: UInt32 = 0x1 << 1
}


class TrafficNode: SKSpriteNode {
    let type: Int
    let directionRight: Bool
    
    init(type: Int, directionRight: Bool, size: CGSize) {
        self.type = type
        self.directionRight = directionRight
        super.init(texture: nil, color: .clear, size: size)
        
        setupTraffic()
    }
    
    private func setupTraffic() {
        // Ensure that these textures are available
        let textureName: String
        switch type {
        case 0: textureName = "left_car"
        case 1: textureName = "right_car"
        case 2: textureName = "left_car"
        default: textureName = "right_car"
        }
        
        let vehicle = SKSpriteNode(imageNamed: textureName)
        vehicle.size = CGSize(width: 60, height: 30)
        vehicle.zPosition = 1
        vehicle.physicsBody = SKPhysicsBody(rectangleOf: vehicle.size)
        vehicle.physicsBody?.isDynamic = true
        vehicle.physicsBody?.categoryBitMask = PhysicsCategory.car
        vehicle.physicsBody?.contactTestBitMask = PhysicsCategory.player
        vehicle.physicsBody?.collisionBitMask = 0
        addChild(vehicle)
        
        // Adjust direction
        if !directionRight {
            vehicle.xScale = -1 // Flip horizontally
        }
    }

    func moveTraffic() {
        // Ensure traffic is moving left or right continuously
        let moveAction = SKAction.moveBy(x: directionRight ? 10 : -10, y: 0, duration: 0.1)
        run(moveAction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class LaneNode: SKSpriteNode {
    let type: LaneType
    var trafficNode: TrafficNode?
    let laneHeight: CGFloat = 50
    
    init(type: LaneType, width: CGFloat) {
            self.type = type
            super.init(texture: nil, color: .clear, size: CGSize(width: width, height: laneHeight))
            
            setupLane()
            if type == .road {
                setupTraffic()
            } else {
                // setupVegetation() // If you want to add vegetation, you can do it here
            }
        }

        func setupLane() {
            // Ensure textures "road" and "grass" are available in assets
            let textureName = (type == .grass) ? "grass" : "road"
            let texture = SKTexture(imageNamed: textureName)
            
            // Preserve aspect ratio
            let aspectRatio = texture.size().width / texture.size().height
            let newHeight: CGFloat = laneHeight
            let newWidth = newHeight * (aspectRatio + 20)
            
            // Set the texture and size
            self.texture = texture
            self.size = CGSize(width: newWidth, height: newHeight)
            zPosition = 0
        }
        
    func setupTraffic() {
            // Continuously spawn traffic
            let spawnAction = SKAction.run {
                let randomType = Int.random(in: 0...2)
                let directionRight = Bool.random()
                let traffic = TrafficNode(type: randomType, directionRight: directionRight, size: self.size)

                let startX = directionRight ? -self.size.width / 2 : self.size.width / 2
                let endX = directionRight ? self.size.width / 2 : -self.size.width / 2

                traffic.position = CGPoint(x: startX, y: 0)
                self.addChild(traffic)

                let moveAction = SKAction.moveTo(x: endX, duration: 4)
                let removeAction = SKAction.removeFromParent()
                traffic.run(SKAction.sequence([moveAction, removeAction]))
            }

            let spawnDelay = SKAction.wait(forDuration: TimeInterval.random(in: 2...4))
            let spawnSequence = SKAction.sequence([spawnAction, spawnDelay])
            let spawnForever = SKAction.repeatForever(spawnSequence)
            run(spawnForever)
        }

        func moveTraffic() {
            children.forEach { node in
                if let traffic = node as? TrafficNode {
                    let moveAction = SKAction.moveBy(x: traffic.directionRight ? 2 : -2, y: 0, duration: 0.1)
                    traffic.run(moveAction)
                }
            }
        }
        
        func resetLane() {
            // Reset the lane when it goes out of view
            trafficNode?.removeFromParent()
            trafficNode = nil
            if type == .road {
                setupTraffic()
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
