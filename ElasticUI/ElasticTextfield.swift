//
//  ElasticTextfield.swift
//  ElasticUI
//
//  Created by di, frank (CHE-LPR) on 9/9/15.
//  Copyright © 2015 Daniel Tavares. All rights reserved.
//

import UIKit

class ElasticTextfield: UITextField {

    private lazy var elasticView: ElasticView = {
        let view = ElasticView(frame: self.bounds)
        view.overshootAmount = self.overshootAmount
        view.backgroundColor = self.backgroundColor
        view.userInteractionEnabled = false
        self.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    @IBInspectable var overshootAmount: CGFloat = 10 {
        didSet {
            elasticView.overshootAmount = overshootAmount
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != UIColor.clearColor() {
                elasticView.backgroundColor = backgroundColor
            }
            super.backgroundColor = UIColor.clearColor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = false
        borderStyle = .None
        addSubview(elasticView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        elasticView.frame = bounds
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        elasticView.touchesBegan(touches, withEvent: event)
    }

}
