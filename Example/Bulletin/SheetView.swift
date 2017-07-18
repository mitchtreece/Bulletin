//
//  SheetView.swift
//  Bulletin_Example
//
//  Created by Mitch Treece on 7/18/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

protocol SheetViewDelegate: class {
    func sheetViewDidTapButton(_ sheet: SheetView)
}

class SheetView: UIView {
    
    var mainContentView: UIView!
    var imageView: UIImageView!

    var topButton: UIButton!
    var bottomButton: UIButton!
    
    weak var delegate: SheetViewDelegate?
    
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
        
        bottomButton = UIButton()
        bottomButton.backgroundColor = UIColor.white
        bottomButton.setTitle("Cancel", for: .normal)
        bottomButton.setTitleColor(#colorLiteral(red: 0.2251080871, green: 0.5581823587, blue: 0.9731199145, alpha: 1), for: .normal)
        bottomButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        bottomButton.layer.cornerRadius = 14
        bottomButton.layer.masksToBounds = true
        addSubview(bottomButton)
        bottomButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(50)
        }
        
        topButton = UIButton()
        topButton.backgroundColor = UIColor.white
        topButton.setTitle("Okay", for: .normal)
        topButton.setTitleColor(#colorLiteral(red: 0.2251080871, green: 0.5581823587, blue: 0.9731199145, alpha: 1), for: .normal)
        topButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        topButton.layer.cornerRadius = 14
        topButton.layer.masksToBounds = true
        addSubview(topButton)
        topButton.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomButton.snp.top).offset(-8)
            make.height.equalTo(50)
        }
        
        mainContentView = UIView()
        mainContentView.backgroundColor = UIColor.white
        mainContentView.layer.cornerRadius = 14
        mainContentView.layer.masksToBounds = true
        addSubview(mainContentView)
        mainContentView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(topButton.snp.top).offset(-8)
        }
        
        imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.image = #imageLiteral(resourceName: "boss")
        imageView.contentMode = .scaleAspectFit
        mainContentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.height.equalTo(#imageLiteral(resourceName: "boss").size.height/2)
        }
        
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        
        delegate?.sheetViewDidTapButton(self)
        
    }
    
}
