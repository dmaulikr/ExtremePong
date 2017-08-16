//
//  Ball.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import SpriteKit

let BallRadius: CGFloat = 10
let BallName = "ball"

class Ball: SKShapeNode {

    static func ball(emitterTargetNode node: SKNode) -> Ball {
        let ball = Ball(circleOfRadius: BallRadius)
        ball.setupBall(emitterTargetNode: node)
        ball.name = BallName
        return ball
    }

    fileprivate func setupBall(emitterTargetNode node: SKNode) {
        self.fillColor = SKColor.white
        guard let path = self.path else {
            assert(false, "There should always be a valid path")
            return
        }
        let physicsBody = SKPhysicsBody(polygonFrom: path)
        physicsBody.isDynamic = true
        physicsBody.restitution = 1
        physicsBody.friction = 0
        physicsBody.linearDamping = 0
        physicsBody.angularDamping = 0
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = BodyCategory.ball.rawValue
        physicsBody.collisionBitMask = BodyCategory.paddle.rawValue | BodyCategory.border.rawValue
        physicsBody.contactTestBitMask = BodyCategory.paddle.rawValue | BodyCategory.border.rawValue | BodyCategory.goal.rawValue
        self.physicsBody = physicsBody

        let ballTrail = SKEmitterNode(fileNamed: "BallTrail.sks")!
        ballTrail.targetNode = node
        self.addChild(ballTrail)
    }
}
