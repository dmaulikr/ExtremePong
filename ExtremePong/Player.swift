//
//  Player.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import SpriteKit

let Player1Color = SKColor(red: 255/255.0, green: 148/255.0, blue: 26/255.0, alpha: 1.0)
let Player2Color = SKColor(red: 18/255.0, green: 174/255.0, blue: 252/255.0, alpha: 1.0)

let DefaultPaddleCount = 1

class Player {

    let name: String
    let color: SKColor
    let score: SKLabelNode

    private(set) var paddleCount: Int
    private(set) var paddleXScale: CGFloat = 1.0
    private(set) var goal = SKShapeNode(rect: CGRect.zero)
    private(set) var paddles = [Paddle]()
    private var powerups = [Powerup]()
    private var powerdowns = [Powerdown]()
    private var paddleAdditionTimer = Timer()

    var drawnPaddle: Paddle?

    init(name: String, color: SKColor) {
        self.paddleCount = DefaultPaddleCount
        self.name = name
        self.color = color
        self.score = SKLabelNode(text: "0")
        self.score.fontColor = color

        paddleAdditionTimer.fire()
    }

    func incrementScore() {
        if let scoreText = self.score.text {
            guard var score = Int(scoreText) else {
                return
            }
            score += 1
            self.score.text = "\(score)"
        }
    }

    func canAddPaddle() -> Bool {
        return !self.paddleAdditionTimer.isValid
    }

    func addPaddle(completion: (_ paddle: Paddle) -> Void) {
        guard let drawnPaddle = self.drawnPaddle else {
            return
        }
        if self.canAddPaddle() {
            let paddle = Paddle.paddle(fromPaddle: drawnPaddle)

            if self.paddleCount == 1 {
                self.clearAllPaddles()
                self.paddles.append(paddle)
            } else {
                if self.paddleCount == self.paddles.count {
                    self.removePaddle(atIndex: 0)
                }
                self.paddles.append(paddle)
            }

            self.drawnPaddle?.removeFromParent()
            self.drawnPaddle = nil
            self.paddleAdditionTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in })
            completion(paddle)
        }
    }

    func removePaddle(atIndex index: Int) {
        if !self.paddles.isEmpty {
            let paddle = self.paddles[index]
            paddle.removeFromParent()
            self.paddles.remove(at: index)
        }
    }

    func removePaddle(_ paddle: Paddle) {
        if let index = self.paddles.index(of: paddle) {
            self.paddles.remove(at: index)
        }
        paddle.removeFromParent()
    }

    func clearAllPaddles() {
        for (index, _) in self.paddles.enumerated() {
            self.removePaddle(atIndex: index)
        }

        self.drawnPaddle?.removeFromParent()
        self.drawnPaddle = nil
    }

    func addPowerup(_ powerup: Powerup) {
        self.powerups.append(powerup)
        self.addEffect(powerup)
    }

    func addPowerdown(_ powerdown: Powerdown) {
        self.powerdowns.append(powerdown)
        self.addEffect(powerdown)
    }

    fileprivate func addEffect(_ effect: PowerEffect) {
        if let powerup = effect as? Powerup {
            guard let powerupType = powerup.powerupType else {
                return
            }
            switch powerupType {
            case .extraPaddle:
                self.setPaddleCount(1)
            case .longPaddles:
                self.setPaddleXScale(1.5)
            case .shortGoal:
                self.changeGoalSize(0.75)
            }
        } else if let powerdown = effect as? Powerdown {
            guard let powerdownType = powerdown.powerdownType else {
                return
            }
            switch powerdownType {
            case .minusPaddle:
                self.setPaddleCount(-1)
            case .shortPaddles:
                self.setPaddleXScale(0.75)
            case .longGoal:
                self.changeGoalSize(1.5)
            }
        }
    }

    fileprivate func removeEffect(_ effect: PowerEffect) {
        if let powerup = effect as? Powerup {
            guard let powerupType = powerup.powerupType else {
                return
            }
            switch powerupType {
            case .extraPaddle:
                self.setPaddleCount(0)
            case .longPaddles:
                self.setPaddleXScale(1.0)
            case .shortGoal:
                self.changeGoalSize(1.0)
            }
        } else if let powerdown = effect as? Powerdown {
            guard let powerdownType = powerdown.powerdownType else {
                return
            }
            switch powerdownType {
            case .minusPaddle:
                self.setPaddleCount(0)
            case .shortPaddles:
                self.setPaddleXScale(1.0)
            case .longGoal:
                self.changeGoalSize(1.0)
            }
        }
    }

    func removeAllEffects() {
        self.powerups.removeAll()
        self.powerdowns.removeAll()
        self.setPaddleCount(0)
        self.setPaddleXScale(1.0)
        self.changeGoalSize(1.0)
    }

    fileprivate func setPaddleCount(_ count: Int) {
        if count < 0 {
            if self.paddleCount > 1 {
                self.paddleCount = DefaultPaddleCount + count
            }
        } else {
            self.paddleCount = DefaultPaddleCount + count
        }
    }

    fileprivate func setPaddleXScale(_ xScale: CGFloat) {
        self.paddleXScale = xScale
        for paddle in self.paddles {
            paddle.xScale = self.paddleXScale
        }
    }

    fileprivate func changeGoalSize(_ xScale: CGFloat) {
        let innerGoal = self.goal.childNode(withName: "innerGoal")
        self.goal.xScale = xScale
        innerGoal?.xScale = xScale
    }

    func createPlayerGoal(_ rect: CGRect, position: CGPoint) {
        let goal = SKShapeNode(rect: rect, cornerRadius: 5)
        goal.position = position
        goal.strokeColor = self.color
        goal.lineWidth = 2
        goal.name = "goal"

        let ballDiameter = BallRadius * 2

        let innerGoal = SKShapeNode(rect: CGRect(x: ballDiameter, y: ballDiameter, width: rect.width - ballDiameter*2, height: rect.height - ballDiameter*2))
        innerGoal.strokeColor = SKColor.clear
        innerGoal.fillColor = SKColor.clear
        innerGoal.name = "innerGoal"

        if let goalPath = innerGoal.path {
            let goalPhysicsBody = SKPhysicsBody(edgeLoopFrom: goalPath)
            goalPhysicsBody.pinned = true
            goalPhysicsBody.allowsRotation = false
            goalPhysicsBody.categoryBitMask = BodyCategory.goal.rawValue
            goalPhysicsBody.contactTestBitMask = BodyCategory.ball.rawValue | BodyCategory.powerup.rawValue | BodyCategory.powerdown.rawValue
            innerGoal.physicsBody = goalPhysicsBody
        }
        
        goal.addChild(innerGoal)
        
        self.goal = goal
    }
}
