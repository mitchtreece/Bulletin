//
//  NotificationView.swift
//  Bulletin_Example
//
//  Created by Mitch Treece on 7/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    
    var backgroundBlurView: UIVisualEffectView!
    
    var topContentView: UIView!
    var iconImageView: UIImageView!
    var iconTitleLabel: UILabel!
    var timeLabel: UILabel!
    
    var titleLabel: UILabel!
    var messageLabel: UILabel!
    
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
        
        backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        addSubview(backgroundBlurView)
        backgroundBlurView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        topContentView = UIView()
        topContentView.backgroundColor = UIColor.clear
        addSubview(topContentView)
        topContentView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(34)
        }
        
        iconImageView = UIImageView()
        iconImageView.backgroundColor = UIColor.clear
        iconImageView.contentMode = .scaleToFill
        topContentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.equalTo(12)
            make.bottom.equalTo(-8)
            make.width.equalTo(iconImageView.snp.height)
        }
        
        timeLabel = UILabel()
        timeLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textAlignment = .right
        topContentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-12)
            make.top.bottom.equalTo(0)
        }
        
        iconTitleLabel = UILabel()
        iconTitleLabel.textColor = UIColor.black.withAlphaComponent(0.4)
        iconTitleLabel.font = UIFont.systemFont(ofSize: 12)
        topContentView.addSubview(iconTitleLabel)
        iconTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(6)
            make.top.bottom.equalTo(0)
            make.right.equalTo(timeLabel.snp.left).offset(-6)
        }
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topContentView.snp.bottom)
            make.left.equalTo(12)
            make.right.equalTo(-12)
        }
        
        messageLabel = UILabel()
        messageLabel.textColor = UIColor.black
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.numberOfLines = 0
        messageLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        messageLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(-12)
        }
        
    }
    
}
