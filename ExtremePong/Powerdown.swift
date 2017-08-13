//
//  Powerdown.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import SpriteKit

enum PowerdownType: UInt32 {
    case
    longGoal,
    shortPaddles,
    minusPaddle

    fileprivate static let count: PowerdownType.RawValue = {
        // find the maximum enum value
        var maxValue: UInt32 = 0
        while let _ = PowerdownType(rawValue: maxValue) { maxValue += 1
        }
        return maxValue
    }()

    static func randomPowerup() -> PowerdownType {
        let rand = arc4random_uniform(count)
        return PowerdownType(rawValue: rand)!
    }
}

class Powerdown: PowerEffect {

    var powerdownType: PowerdownType? = nil

    static func powerdown() -> Powerdown {
        let powerdown = Powerdown(circleOfRadius: PowerEffectRadius)
        powerdown.setupPowerdown()
        return powerdown
    }

    fileprivate func setupPowerdown() {
        self.fillColor = SKColor.red
        self.strokeColor = SKColor.lightGray
        self.lineWidth = 2.0

        guard let path = self.path else {
            return
        }
        let physicsBody = SKPhysicsBody(polygonFrom: path)
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = BodyCategory.powerdown.rawValue
        physicsBody.collisionBitMask = BodyCategory.border.rawValue
        self.physicsBody = physicsBody

        self.powerdownType = PowerdownType.randomPowerup()
        self.definePowerdown(self.powerdownType!)
    }

    fileprivate func definePowerdown(_ powerdown: PowerdownType) {
        let powerdownLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerdownLabel.fontSize = 18.0
        powerdownLabel.fontColor = SKColor.white

        switch powerdown {
        case .longGoal:
            powerdownLabel.text = "<G>"
        case .minusPaddle:
            powerdownLabel.text = "P-"
        case .shortPaddles:
            powerdownLabel.text = ">P<"
        }

        self.addChild(powerdownLabel)
        powerdownLabel.horizontalAlignmentMode = .center
        powerdownLabel.verticalAlignmentMode = .center
    }
}
