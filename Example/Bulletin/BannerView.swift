//
//  BannerView.swift
//  Bulletin_Example
//
//  Created by Mitch Treece on 7/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit 

class BannerView: UIView {
    
    var backgroundBlurView: UIVisualEffectView!
    var statusBarView: UIView!
    
    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var timeLabel: UILabel!
    var messageLabel: UILabel!
    var grabberView: UIView!
    
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
        
        statusBarView = UIView()
        statusBarView.backgroundColor = UIColor.clear
        addSubview(statusBarView)
        statusBarView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(UIApplication.shared.statusBarFrame.height)
        }
        
        grabberView = UIView()
        grabberView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        grabberView.layer.cornerRadius = 3
        addSubview(grabberView)
        grabberView.snp.makeConstraints { (make) in
            make.bottom.equalTo(-6)
            make.centerX.equalTo(self)
            make.width.equalTo(44)
            make.height.equalTo(6)
        }
        
        iconImageView = UIImageView()
        iconImageView.backgroundColor = UIColor.clear
        iconImageView.contentMode = .scaleToFill
        iconImageView.layer.cornerRadius = 6
        iconImageView.clipsToBounds = true
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(statusBarView.snp.bottom).offset(6)
            make.left.equalTo(12)
            make.width.height.equalTo(22)
        }
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(8)
        }
        
        timeLabel = UILabel()
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        timeLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.right.equalTo(-12)
            make.bottom.equalTo(titleLabel)
        }
        
        messageLabel = UILabel()
        messageLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.numberOfLines = 0
        messageLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        messageLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-12)
            make.bottom.equalTo(grabberView.snp.top).offset(-12)
        }
        
    }
    
}
