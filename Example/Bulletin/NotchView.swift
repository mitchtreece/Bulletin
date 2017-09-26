//
//  NotchView.swift
//  Bulletin_Example
//
//  Created by Mitch Treece on 9/25/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class NotchView: UIView {
    
    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = UIColor.black
        
        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(UIScreen.main.notch!.height)
            make.left.bottom.right.equalTo(0)
        }
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let cornerRadii = CGSize(width: UIScreen.main.notch!.cornerRadius, height: UIScreen.main.notch!.cornerRadius)
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: cornerRadii).cgPath
        
        layer.mask = mask
        
    }
    
}
