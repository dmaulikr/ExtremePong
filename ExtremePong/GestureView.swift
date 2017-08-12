//
//  GestureView.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import UIKit

protocol GestureViewDelegate: class {
    func didRecognizeSwipeInView(_ gestureView: GestureView, angle: CGFloat, center: CGPoint)
    func shouldRecognizeSwipeInView(_ gestureView: GestureView, touch: UITouch) -> Bool
}

class GestureView: UIView, UIGestureRecognizerDelegate {

    weak var delegate: GestureViewDelegate?

    fileprivate let paddleCreationOffset: CGFloat = 30
    fileprivate var startPoint: CGPoint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GestureView.handlePan(_:)))
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        if panGestureRecognizer.state != .cancelled {
            let translation = panGestureRecognizer.translation(in: self)

            if abs(translation.x) >= self.paddleCreationOffset || abs(translation.y) >= self.paddleCreationOffset {

                guard let startPoint = self.startPoint else {
                    return
                }
                let point = panGestureRecognizer.location(in: self)
                let angle = self.radianAngleBetweenTwoPoints(startPoint, secondPoint: point)
                let center = self.centerBetweenTwoPoints(startPoint, secondPoint: point)

                panGestureRecognizer.isEnabled = false
                self.delegate?.didRecognizeSwipeInView(self, angle: angle, center: center)
            }
        } else {
            panGestureRecognizer.isEnabled = true;
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.startPoint = touch.location(in: self)
        guard let delegate = self.delegate else {
            return false
        }
        return delegate.shouldRecognizeSwipeInView(self, touch: touch)
    }

    fileprivate func radianAngleBetweenTwoPoints(_ firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        let originPoint = CGPoint(x: secondPoint.x - firstPoint.x, y: secondPoint.y - firstPoint.y)
        let bearingRadians = atan2f(Float(originPoint.y), Float(originPoint.x))
        return CGFloat(bearingRadians)
    }

    fileprivate func centerBetweenTwoPoints(_ firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint {
        let midPoint = CGPoint(x: (firstPoint.x + secondPoint.x)/2, y: (firstPoint.y + secondPoint.y)/2)
        return midPoint
    }
}
