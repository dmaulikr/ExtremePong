//
//  GameViewController.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)

            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! SKScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene,
            let skView = self.view as? SKView {
            // Configure the view.
            scene.size = skView.bounds.size
            skView.showsFPS = true
            skView.showsNodeCount = true

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = false

            skView.presentScene(scene)
        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
