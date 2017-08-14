//
//  Paddle.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import SpriteKit

let MaximumPaddleLength: CGFloat = 100

class Paddle: SKShapeNode {

    static func paddle(_ width: CGFloat) -> Paddle {
        let paddle = Paddle(rectOf: CGSize(width: width, height: 10), cornerRadius: 5)
        paddle.setupPaddle(withPhysics: true)
        return paddle
    }

    static func paddle(fromPaddle paddle: Paddle) -> Paddle {
        let paddleCopy = paddle.copy() as! Paddle
        paddleCopy.setupPaddle(withPhysics: true)
        return paddleCopy
    }

    static func drawnPaddle(_ width: CGFloat) -> Paddle {
        let paddle = Paddle(rectOf: CGSize(width: width, height: 10), cornerRadius: 5)
        paddle.setupPaddle(withPhysics: false)
        paddle.alpha = 0.3
        return paddle
    }

    fileprivate func setupPaddle(withPhysics: Bool) {
        self.fillColor = SKColor.white
        self.alpha = 1.0
        guard let path = self.path else {
            assert(false, "There should always be a valid path")
            return
        }

        if withPhysics {
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
}
