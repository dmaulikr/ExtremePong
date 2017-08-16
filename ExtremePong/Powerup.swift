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

    private static let count: PowerupType.RawValue = {
        // find the maximum enum value
        var maxValue: UInt32 = 0
        while let _ = PowerupType(rawValue: maxValue) {
            maxValue += 1
        }
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
        self.setupPowerEffect(SKColor.green, bitMaskCategory: BodyCategory.powerup.rawValue)
        self.powerupType = PowerupType.randomPowerup()
        self.definePowerup(self.powerupType!)
    }

    fileprivate func definePowerup(_ powerup: PowerupType) {
        var labelText: String
        switch powerup {
        case .extraPaddle:
            labelText = "P+"
        case .longPaddles:
            labelText = "<P>"
        case .shortGoal:
            labelText = ">G<"
        }

        let label = self.createLabel(withText: labelText)
        self.addChild(label)
    }

    //eventually make powerups/powerdowns timed effects via a timer
    func startTimer() {
        timer.fire()
    }
    
    fileprivate func timeUp() {
        
    }
}
