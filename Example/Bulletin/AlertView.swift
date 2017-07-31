//
//  AlertView.swift
//  Bulletin_Example
//
//  Created by Mitch Treece on 7/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

protocol AlertViewDelegate: class {
    func alertViewDidTapButton(_ alert: AlertView)
}

class AlertView: UIView {
    
    var backgroundBlurView: UIVisualEffectView!
    
    var titleLabel: UILabel!
    var messageLabel: UILabel!
    
    var buttonDividerView: UIView!
    var button: UIButton!
    
    weak var delegate: AlertViewDelegate?
    
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
        
        button = UIButton()
        button.setBackgroundImage(image(from: UIColor.clear), for: .normal)
        button.setBackgroundImage(image(from: UIColor.black.withAlphaComponent(0.06)), for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(#colorLiteral(red: 0.2251080871, green: 0.5581823587, blue: 0.9731199145, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        addSubview(button)
        button.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        buttonDividerView = UIView()
        buttonDividerView.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        addSubview(buttonDividerView)
        buttonDividerView.snp.makeConstraints { (make) in
            make.top.equalTo(button)
            make.left.right.equalTo(0)
            make.height.equalTo(1)
        }
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(24)
            make.left.equalTo(24)
            make.right.equalTo(-24)
        }
        
        messageLabel = UILabel()
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.textColor = UIColor.black
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        messageLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        messageLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)
        addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(button.snp.top).offset(-24)
        }
        
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        
        delegate?.alertViewDidTapButton(self)
        
    }
    
    private func image(from color: UIColor) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
    
}
