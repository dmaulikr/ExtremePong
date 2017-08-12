//
//  Paddle.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import SpriteKit

let DefaultPaddleLength: CGFloat = 75

class Paddle: SKShapeNode {

    static func paddle() -> Paddle {
        let paddle = Paddle(rectOf: CGSize(width: DefaultPaddleLength, height: 10), cornerRadius: 5)
        paddle.setupPaddle()
        return paddle
    }

    fileprivate func setupPaddle() {
        self.fillColor = SKColor.white
        guard let path = self.path else {
            return
        }
        let physicsBody = SKPhysicsBody(edgeLoopFrom: path)
        physicsBody.affectedByGravity = false
        physicsBody.pinned = true
        physicsBody.isDynamic = false
        physicsBody.restitution = 1
        physicsBody.friction = 0
        physicsBody.linearDamping = 0
        physicsBody.angularDamping = 0
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = BodyCategory.paddle.rawValue
        self.physicsBody = physicsBody
    }
}
