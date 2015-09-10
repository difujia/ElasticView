//
//  ElasticView.swift
//  ElasticUI
//
//  Created by di, frank (CHE-LPR) on 9/9/15.
//  Copyright © 2015 Daniel Tavares. All rights reserved.
//

import UIKit

class ElasticView: UIView {

    @IBInspectable
    var overshootAmount: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private let topControlPointView = UIView()
    private let leftControlPointView = UIView()
    private let bottomControlPointView = UIView()
    private let rightControlPointView = UIView()
    
    private lazy var elasticShape: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.fillColor = self.backgroundColor?.CGColor
        return shape
    }()
    
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != UIColor.clearColor() {
                elasticShape.fillColor = backgroundColor?.CGColor
            }
            super.backgroundColor = UIColor.clearColor()
        }
    }

    private func commonInit() {
        layer.addSublayer(elasticShape)
        backgroundColor = UIColor.clearColor()
        clipsToBounds = false
        
        for controlPoint in [topControlPointView, rightControlPointView, bottomControlPointView, leftControlPointView] {
            addSubview(controlPoint)
        }
        positionControlPoints()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !isAnimating {
            animateControlPoints()
        }
    }
    
    func animateControlPoints() {
        let overshootAmount = self.overshootAmount
        
        startUpdateLoop()
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: [], animations: {
            self.topControlPointView.center.y -= overshootAmount
            self.rightControlPointView.center.x += overshootAmount
            self.bottomControlPointView.center.y += overshootAmount
            self.leftControlPointView.center.x -= overshootAmount
            }, completion: { _ in
                UIView.animateWithDuration(0.45, delay: 0, usingSpringWithDamping: 0.15, initialSpringVelocity: 5.5, options: [], animations: {
                    self.positionControlPoints()
                    }, completion: { _ in
                        self.stopUpdateLoop()
                })
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionControlPoints()
        updateElasticShape()
    }
    
    private func positionControlPoints() {
        topControlPointView.center = CGPoint(x: bounds.midX, y: 0)
        rightControlPointView.center = CGPoint(x: bounds.maxX, y: bounds.midY)
        bottomControlPointView.center = CGPoint(x: bounds.midX, y: bounds.maxY)
        leftControlPointView.center = CGPoint(x: 0, y: bounds.midY)
    }

    private lazy var displayLink: CADisplayLink = {
        let link = CADisplayLink(target: self, selector: "updateElasticShape")
        link.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        return link
    }()
    
    @objc private func updateElasticShape() {
        elasticShape.path = bezierPathForControlPoints()
    }
    
    private func bezierPathForControlPoints() -> CGPathRef {
        let path = UIBezierPath()
        
        let top = isAnimating ? topControlPointView.layer.presentationLayer()!.position : topControlPointView.center
        let right = isAnimating ? rightControlPointView.layer.presentationLayer()!.position : rightControlPointView.center
        let bottom = isAnimating ? bottomControlPointView.layer.presentationLayer()!.position : bottomControlPointView.center
        let left = isAnimating ? leftControlPointView.layer.presentationLayer()!.position : leftControlPointView.center
        
        let topLeft = CGPoint(x: bounds.minX, y: bounds.minY)
        let topRight = CGPoint(x: bounds.maxX, y: bounds.minY)
        let bottomRight = CGPoint(x: bounds.maxX, y: bounds.maxY)
        let bottomLeft = CGPoint(x: bounds.minX, y: bounds.maxY)
        
        path.moveToPoint(topLeft)
        path.addQuadCurveToPoint(topRight, controlPoint: top)
        path.addQuadCurveToPoint(bottomRight, controlPoint: right)
        path.addQuadCurveToPoint(bottomLeft, controlPoint: bottom)
        path.addQuadCurveToPoint(topLeft, controlPoint: left)
        
        return path.CGPath
    }
    
    private var isAnimating = false
    private func startUpdateLoop() {
        isAnimating = true
        displayLink.paused = false
    }
    
    private func stopUpdateLoop() {
        isAnimating = false
        displayLink.paused = true
        updateElasticShape()
    }
}
