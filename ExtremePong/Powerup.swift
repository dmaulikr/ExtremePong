//
//  Powerup.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import Foundation

import SpriteKit

enum PowerupType: UInt32 {
    case
    extraPaddle,
    longPaddles,
    shortGoal

    fileprivate static let count: PowerupType.RawValue = {
        // find the maximum enum value
        var maxValue: UInt32 = 0
        while let _ = PowerupType(rawValue: maxValue) { }
        maxValue += 1;
        return maxValue
    }()

    static func randomPowerup() -> PowerupType {
        let rand = arc4random_uniform(count)
        return PowerupType(rawValue: rand)!
    }
}

class Powerup: PowerEffect {

    var powerupType: PowerupType? = nil

    static func powerup() -> Powerup {
        let powerup = Powerup(circleOfRadius: PowerEffectRadius)
        powerup.setupPowerup()
        return powerup
    }

    fileprivate func setupPowerup() {
        self.fillColor = SKColor.green
        self.strokeColor = SKColor.lightGray
        self.lineWidth = 2.0

        guard let path = self.path else {
            return
        }
        let physicsBody = SKPhysicsBody(polygonFrom: path)
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false
        physicsBody.categoryBitMask = BodyCategory.powerup.rawValue
        physicsBody.collisionBitMask = BodyCategory.border.rawValue
        self.physicsBody = physicsBody

        self.powerupType = PowerupType.randomPowerup()
        self.definePowerup(self.powerupType!)
    }

    fileprivate func definePowerup(_ powerup: PowerupType) {
        let powerupLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerupLabel.fontSize = 18.0
        powerupLabel.fontColor = SKColor.white

        switch powerup {
        case .extraPaddle:
            powerupLabel.text = "P+"
        case .longPaddles:
            powerupLabel.text = "<P>"
        case .shortGoal:
            powerupLabel.text = ">G<"
        }

        self.addChild(powerupLabel)
        powerupLabel.horizontalAlignmentMode = .center
        powerupLabel.verticalAlignmentMode = .center
    }

    func startTimer() {
        timer.fire()
    }
    
    fileprivate func timeUp() {
        
    }
}
