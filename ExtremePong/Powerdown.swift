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
        while let _ = PowerdownType(rawValue: maxValue) {
            maxValue += 1
        }
        return maxValue
    }()

    static func randomPowerup() -> PowerdownType {
        let rand = arc4random_uniform(count)
        return PowerdownType(rawValue: rand)!
    }
}

class Powerdown: PowerEffect {

    private(set) var powerdownType: PowerdownType? = nil

    static func powerdown() -> Powerdown {
        let powerdown = Powerdown(circleOfRadius: PowerEffectRadius)
        powerdown.setupPowerdown()
        return powerdown
    }

    fileprivate func setupPowerdown() {
        self.setupPowerEffect(SKColor.red, bitMaskCategory: BodyCategory.powerdown.rawValue)
        self.powerdownType = PowerdownType.randomPowerup()
        self.definePowerdown(self.powerdownType!)
    }

    fileprivate func definePowerdown(_ powerdown: PowerdownType) {
        var labelText: String
        switch powerdown {
        case .longGoal:
            labelText = "<G>"
        case .minusPaddle:
            labelText = "P-"
        case .shortPaddles:
            labelText = ">P<"
        }

        let label = self.createLabel(withText: labelText)
        self.addChild(label)
    }
}
