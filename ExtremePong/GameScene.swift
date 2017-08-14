//
//  GameScene.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BodyCategory: UInt32 {
    case ball = 1
    case powerup = 2
    case powerdown = 4
    case paddle = 8
    case border = 16
    case goal = 32
    case midline = 64
}

private let Player1Name = "player1"
private let Player2Name = "player2"

class GameScene: SKScene {

    fileprivate let player1 = Player(name: Player1Name)
    fileprivate let player2 = Player(name: Player2Name)

    fileprivate var p1View = GestureView(frame: CGRect.zero)
    fileprivate var p2View = GestureView(frame: CGRect.zero)

    fileprivate var p1Goal = SKShapeNode(rect: CGRect.zero)
    fileprivate var p2Goal = SKShapeNode(rect: CGRect.zero)

    fileprivate var playing = false

    fileprivate let p1GoalName = "p1Goal"
    fileprivate let p2GoalName = "p2Goal"
    fileprivate let midlineName = "midline"

    fileprivate var selectedNode = SKShapeNode()
    fileprivate var powerEffect: PowerEffect? = nil

    fileprivate var powerEffectTimer = Timer()

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        self.setupPhysics()
        self.setupField()

        let padding: CGFloat = 10
        var labelWidth = self.player1.score.frame.width
        let labelHeight = self.player1.score.frame.height
        self.player1.score.position = CGPoint(x: view.frame.width - labelWidth, y: view.frame.midY - labelHeight - padding)
        self.player1.score.fontColor = Player1Color
        self.addChild(self.player1.score)

        labelWidth = self.player2.score.frame.width
        self.player2.score.position = CGPoint(x: view.frame.width - labelWidth, y: view.frame.midY + padding)
        self.player2.score.fontColor = Player2Color
        self.addChild(self.player2.score)

        self.p1View.frame = CGRect(x: 0, y: view.frame.height/2, width: view.frame.width, height: view.frame.height/2)
        self.p2View.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2)

        self.p1View.delegate = self
        self.p2View.delegate = self

        view.addSubview(self.p1View)
        view.addSubview(self.p2View)

        self.createBall()

        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GameScene.handlePanForPowerEffect(_:)))
        self.view!.addGestureRecognizer(gestureRecognizer)

        self.startTimer()
    }

    fileprivate func startTimer() {
        self.powerEffectTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GameScene.createRandomPowerEffect), userInfo: nil, repeats: false)
        self.powerEffect?.removeFromParent()
    }

    fileprivate func checkForMatchingPaddle(_ physicsBody: SKPhysicsBody) -> (player: Player, paddle: Paddle)? {
        for paddle in self.player1.paddles {
            if paddle.physicsBody == physicsBody {
                return (self.player1, paddle)
            }
        }
        for paddle in self.player2.paddles {
            if paddle.physicsBody == physicsBody {
                return (self.player2, paddle)
            }
        }
        return nil
    }

    fileprivate func createBall() {
        let ball = Ball.ball()

        guard let viewFrame = self.view?.frame else {
            return
        }
        ball.position = CGPoint(x: viewFrame.midX, y: viewFrame.midY)
        self.addChild(ball)
        var dy: Int = 0
        let dx = Int(arc4random_uniform(6) + 4)

        let positiveOrNegative = Int(arc4random_uniform(2))
        if positiveOrNegative == 1 {
            dy = dx - 10
        } else {
            dy = 10 - dx
        }

        let impulse = CGVector(dx: dx, dy: dy)
        ball.physicsBody?.applyImpulse(impulse)
        self.playing = true
    }

    fileprivate func createPowerup() {
        let powerup = Powerup.powerup()
        if let viewFrame = self.view?.frame {
            powerup.position = CGPoint(x: viewFrame.midX, y: viewFrame.midY)
            self.powerEffect = powerup
            self.addChild(self.powerEffect!)
        }
    }

    fileprivate func createPowerdown() {
        let powerdown = Powerdown.powerdown()
        if let viewFrame = self.view?.frame {
            powerdown.position = CGPoint(x: viewFrame.midX, y: viewFrame.midY)
            self.powerEffect = powerdown
            self.addChild(self.powerEffect!)
        }
    }

    @objc fileprivate func createRandomPowerEffect() {
        let rand = arc4random_uniform(2)
        if rand == 0 {
            self.createPowerup()
        } else {
            self.createPowerdown()
        }
    }

    fileprivate func placePaddle(_ paddle: Paddle, player: Player, position: CGPoint, angle: CGFloat) {
        if self.playing {
            player.addPaddle(paddle, completion: { 
                paddle.zRotation = angle
                paddle.position = position
                self.addChild(paddle)

                if !self.paddleSafeToPlace(paddle) {
                    player.removePaddle(paddle)
                    paddle.removeFromParent()
                }
            })
        }
    }

    fileprivate func placeDrawnPaddle(_ paddle: Paddle,
                                      player: Player,
                                      position: CGPoint,
                                      angle: CGFloat) {
        if self.playing && player.canAddPaddle(paddle) {
            paddle.zRotation = angle
            paddle.position = position
            self.addChild(paddle)

            guard let drawnPaddle = player.drawnPaddle else {
                player.drawnPaddle = paddle
                return
            }

            drawnPaddle.removeFromParent()
            if !self.paddleSafeToPlace(paddle) {
                paddle.removeFromParent()
                self.addChild(drawnPaddle)
            } else {
                player.drawnPaddle = paddle
            }

            //make sure to add the Player.drawnPaddle to list of paddles but with physics rather than a new calculation
        }
    }

    fileprivate func paddleSafeToPlace(_ paddle: Paddle) -> Bool {
        guard let
            p1Goal = self.childNode(withName: self.p1GoalName),
            let p2Goal = self.childNode(withName: self.p2GoalName),
            let midline = self.childNode(withName: self.midlineName),
            let ball = self.childNode(withName: BallName)
            else {
                return false
        }

        var safeToPlace = true;
        if paddle.intersects(p1Goal)
            || paddle.intersects(p2Goal)
            || paddle.intersects(midline)
            || paddle.intersects(ball) {

            safeToPlace = false
        }
        return safeToPlace
    }

    fileprivate func setupPhysics() {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        borderBody.restitution = 1
        borderBody.linearDamping = 0
        borderBody.angularDamping = 0
        borderBody.categoryBitMask = BodyCategory.border.rawValue
        self.physicsBody = borderBody
    }

    fileprivate func setupField() {
        if let viewFrame = self.view?.frame {
            let midline = SKShapeNode(rect: CGRect(x: 0, y: viewFrame.height/2 - 1, width: viewFrame.width, height: 1))
            midline.strokeColor = SKColor.lightGray
            midline.lineWidth = 1
            midline.fillColor = SKColor.lightGray
            midline.name = self.midlineName
            self.addChild(midline)

            let midCircle = SKShapeNode(circleOfRadius: viewFrame.width/10)
            midCircle.strokeColor = SKColor.lightGray
            midCircle.lineWidth = 2
            midCircle.position = CGPoint(x: viewFrame.midX, y: viewFrame.midY)
            self.addChild(midCircle)

            let goalHeightRatio: CGFloat = 12
            let goalWidthRatio: CGFloat = 3
            let goalYOffset: CGFloat = 5

            let goalHeight = viewFrame.height/goalHeightRatio
            let goalWidth = viewFrame.width/goalWidthRatio

            let goalRect = CGRect(x: 0, y: 0, width: goalWidth, height: goalHeight)
            var goalPosition = CGPoint(x: viewFrame.midX - goalWidth/2, y: viewFrame.height - goalHeight + goalYOffset)

            self.player2.createPlayerGoal(goalRect, position: goalPosition)
            self.player2.goal.name = self.p2GoalName
            self.player2.goal.strokeColor = Player2Color
            self.addChild(self.player2.goal)

            goalPosition = CGPoint(x: viewFrame.midX - goalWidth/2, y: -goalYOffset)

            self.player1.createPlayerGoal(goalRect, position: goalPosition)
            self.player1.goal.name = self.p1GoalName
            self.player1.goal.strokeColor = Player1Color
            self.addChild(self.player1.goal)
        }
    }

    fileprivate func clearField() {
        for paddle in self.player1.paddles {
            self.player1.removePaddle(paddle)
            paddle.removeFromParent()
        }

        for paddle in self.player2.paddles {
            self.player2.removePaddle(paddle)
            paddle.removeFromParent()
        }

        let ball = self.childNode(withName: BallName)
        ball?.removeFromParent()
    }

    fileprivate func isLocatedInBottomHalfView(_ node: SKNode) -> Bool {
        let position = node.position

        if let viewFrame = self.view?.frame {
            let convertedPoint = self.convertPoint(fromView: CGPoint(x: 0, y: viewFrame.midY))
            if position.y < convertedPoint.y {
                return true
            }
        }
        return false
    }

    fileprivate func updateScoreForPlayer(_ player: Player) {
        if let scoreText = player.score.text {
            guard var score = Int(scoreText) else {
                return
            }
            score += 1
            player.score.text = "\(score)"
            self.clearField()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if !self.playing {
            self.createBall()
            self.startTimer()
        }
    }

    @objc fileprivate func handlePanForPowerEffect(_ recognizer : UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            var touchLocation = recognizer.location(in: recognizer.view)
            touchLocation = self.convertPoint(fromView: touchLocation)

            self.selectNodeForTouch(touchLocation)
            break

        case .changed:
            var translation = recognizer.translation(in: recognizer.view!)
            translation = CGPoint(x: translation.x, y: -translation.y)

            self.panForTranslation(translation)

            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
            break

        default:
            break
        }
    }

    func panForTranslation(_ translation : CGPoint) {
        let position = selectedNode.position
        selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
    }

    func selectNodeForTouch(_ touchLocation : CGPoint) {
        let touchedNode = self.atPoint(touchLocation)

        if touchedNode is PowerEffect {
            if !selectedNode.isEqual(touchedNode) {
                selectedNode = touchedNode as! PowerEffect
            }
        }
    }

    fileprivate func isPowerEffectTouched(_ touch: UITouch) -> Bool {
        let touchLocation = touch.location(in: self)
        let touchedNode = self.atPoint(touchLocation)

        guard let powerEffect = self.powerEffect else {
            return false
        }
        if touchedNode == powerEffect || touchedNode.inParentHierarchy(powerEffect) {
            return true
        }
        return false
    }
}

// MARK: - GestureViewDelegate

extension GameScene: GestureViewDelegate {

    func didRecognizeSwipeInView(_ gestureView: GestureView,
                                 gestureRecognizer: UIGestureRecognizer,
                                 length: CGFloat,
                                 angle: CGFloat,
                                 center: CGPoint) {
        if self.playing {
            guard let view = self.view else {
                return
            }
            let player = self.p1View == gestureView ? self.player1 : self.player2

            let tempPoint = view.convert(center, from: gestureView)
            let positionInScene = view.convert(tempPoint, to: self)
            //adding negative to angle since UIKit coordinates are flipped compared to SceneKit coordinates
            let angleInScene = -angle

            var paddle: Paddle
            switch gestureRecognizer.state {
            case .changed:
                paddle = Paddle.drawnPaddle(length)
                self.placeDrawnPaddle(paddle,
                                      player: player,
                                      position: positionInScene,
                                      angle: angleInScene)
                break
            case .ended:
                paddle = Paddle.paddle(length)
                self.placePaddle(paddle,
                                 player: player,
                                 position: positionInScene,
                                 angle: angleInScene)
                break
            default:
                break
            }

//            if self.p1View == gestureView {
//                self.placePaddle(paddle,
//                                 player: self.player1,
//                                 position: positionInScene,
//                                 angle: angleInScene)
//
//            } else if self.p2View == gestureView {
//                self.placePaddle(paddle,
//                                 player: self.player2,
//                                 position: positionInScene,
//                                 angle: angleInScene)
//            }
        }
    }

    func shouldRecognizeSwipeInView(_ gestureView: GestureView, touch: UITouch) -> Bool {
        print("shouldRecognize touch delegate")

        if self.isPowerEffectTouched(touch) {
            return false
        }
        return true
    }

    func maxTranslationInGestureView(_ gestureView: GestureView) -> CGFloat {
        let player = self.p1View == gestureView ? self.player1 : self.player2
        let maxLength = MaximumPaddleLength * player.paddleXScale
        return maxLength
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        print("contact")

        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.categoryBitMask == BodyCategory.ball.rawValue && secondBody.categoryBitMask == BodyCategory.paddle.rawValue {
            //check that ball and paddle collided
            if let playerAndPaddle = self.checkForMatchingPaddle(secondBody) {
                let player = playerAndPaddle.player
                let paddle = playerAndPaddle.paddle

                player.removePaddle(paddle)
                paddle.removeFromParent()
            }
        }

        if firstBody.categoryBitMask == BodyCategory.ball.rawValue && secondBody.categoryBitMask == BodyCategory.goal.rawValue {
            //check for a goal
            if playing {
                if let
                    innerGoal = secondBody.node,
                    let goal = innerGoal.parent
                {
                    if self.isLocatedInBottomHalfView(goal) {
                        self.updateScoreForPlayer(self.player2)
                    } else {
                        self.updateScoreForPlayer(self.player1)
                    }
                    self.playing = false
                    self.player1.removeAllEffects()
                    self.player2.removeAllEffects()
                    self.powerEffectTimer.invalidate()
                    self.powerEffect?.removeFromParent()
                    self.powerEffect = nil
                }
            }
        }

        //Powerup contact with goal
        if firstBody.categoryBitMask == BodyCategory.powerup.rawValue && secondBody.categoryBitMask == BodyCategory.goal.rawValue {
            if playing {
                if let powerup = firstBody.node as? Powerup {
                    if let
                        innerGoal = secondBody.node,
                        let goal = innerGoal.parent
                    {
                        if self.isLocatedInBottomHalfView(goal) {
                            self.player1.addPowerup(powerup)
                        } else {
                            self.player2.addPowerup(powerup)
                        }
                        powerup.removeFromParent()
                        self.startTimer()
                    }
                }
            }
        }

        //Powerdown contact with goal
        if firstBody.categoryBitMask == BodyCategory.powerdown.rawValue && secondBody.categoryBitMask == BodyCategory.goal.rawValue {
            if playing {
                if let powerdown = firstBody.node as? Powerdown {
                    if let
                        innerGoal = secondBody.node,
                        let goal = innerGoal.parent
                    {
                        if self.isLocatedInBottomHalfView(goal) {
                            self.player1.addPowerdown(powerdown)
                        } else {
                            self.player2.addPowerdown(powerdown)
                        }
                        powerdown.removeFromParent()
                        self.startTimer()
                    }
                }
            }
        }
    }
}
