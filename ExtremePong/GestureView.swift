//
//  GestureView.swift
//  ExtremePong
//
//  Created by Tony Dakhoul on 8/10/17.
//  Copyright © 2017 Tony Dakhoul. All rights reserved.
//

import UIKit

protocol GestureViewDelegate: class {
    func didRecognizeSwipeInView(_ gestureView: GestureView,
                                 gestureRecognizer: UIGestureRecognizer,
                                 length: CGFloat,
                                 angle: CGFloat,
                                 center: CGPoint)
    func shouldRecognizeSwipeInView(_ gestureView: GestureView, touch: UITouch) -> Bool

    func maxTranslationInGestureView(_ gestureView: GestureView) -> CGFloat
}

class GestureView: UIView, UIGestureRecognizerDelegate {

    weak var delegate: GestureViewDelegate?

    fileprivate let paddleCreationOffset: CGFloat = 30
    fileprivate var startPoint: CGPoint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GestureView.handlePan(_:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        guard let
            startPoint = self.startPoint,
            let maxLength = self.delegate?.maxTranslationInGestureView(self)
            else {
                return
        }

        let point = panGestureRecognizer.location(in: self)
        var length = self.distanceBetweenTwoPoints(startPoint, secondPoint: point)
        let angle = self.radianAngleBetweenTwoPoints(startPoint, secondPoint: point)

        length = length > maxLength ? maxLength : length
        let endPoint = self.endpointFromLengthAndAngle(initialPoint: startPoint,
                                                       length: length,
                                                       angle: angle)
        let center = self.centerBetweenTwoPoints(startPoint, secondPoint: endPoint)

        self.delegate?.didRecognizeSwipeInView(self,
                                               gestureRecognizer: panGestureRecognizer,
                                               length: length,
                                               angle: angle,
                                               center: center)
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

    fileprivate func distanceBetweenTwoPoints(_ firstPoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
        let xDist = firstPoint.x - secondPoint.x
        let yDist = firstPoint.y - secondPoint.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }

    fileprivate func centerBetweenTwoPoints(_ firstPoint: CGPoint, secondPoint: CGPoint) -> CGPoint {
        return CGPoint(x: (firstPoint.x + secondPoint.x)/2, y: (firstPoint.y + secondPoint.y)/2)
    }

    fileprivate func endpointFromLengthAndAngle(initialPoint: CGPoint,
                                                length: CGFloat,
                                                angle: CGFloat) -> CGPoint {
        let dx = length * cos(angle)
        let dy = length * sin(angle)
        return CGPoint(x: initialPoint.x + dx, y: initialPoint.y + dy)
    }
}
