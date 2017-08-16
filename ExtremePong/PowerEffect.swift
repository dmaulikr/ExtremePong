//
//  PowerEffect.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import SpriteKit

let PowerEffectRadius: CGFloat = 30

class PowerEffect: SKShapeNode {

    var timer = Timer()

    func setupPowerEffect(_ color: SKColor, bitMaskCategory: BodyCategory.RawValue) {
        self.fillColor = color
        self.strokeColor = SKColor.lightGray
        self.lineWidth = 2.0

        guard let path = self.path else {
            return
        }
        let physicsBody = SKPhysicsBody(polygonFrom: path)
        physicsBody.isDynamic = true
        physicsBody.friction = 0.6
        physicsBody.linearDamping = 0.6
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = bitMaskCategory
        physicsBody.collisionBitMask = BodyCategory.border.rawValue
        self.physicsBody = physicsBody
    }

    func createLabel(withText text: String) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.fontSize = 18.0
        label.fontColor = SKColor.white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = text
        return label
    }
}
