//
//  HudView.swift
//  Bulletin_Example
//
//  Created by Mitch Treece on 7/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class HudView: UIView {
    
    var backgroundBlurView: UIVisualEffectView!
    var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = UIColor.clear
        
        backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        addSubview(backgroundBlurView)
        backgroundBlurView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(20)
        }
        
        activityIndicator.startAnimating()
        
    }

}
