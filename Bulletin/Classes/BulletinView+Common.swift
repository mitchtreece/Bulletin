//
//  BulletinView+Common.swift
//  Bulletin
//
//  Created by Mitch Treece on 7/11/17.
//  Copyright © 2017 Mitch Treece. All rights reserved.
//

import UIKit
import SnapKit

extension BulletinView {
    
    public static func notification() -> BulletinView {
        
        return BulletinView()
        
    }
    
    public static func banner(sticky: Bool = false) -> BulletinView {
        
        let bulletin = BulletinView()
        bulletin.position = .top
        bulletin.duration = sticky ? .forever : .limit(5)
        bulletin.presentationAnimation.duration = 0.2
        bulletin.presentationAnimation.springDamping = 0
        bulletin.presentationAnimation.springVelocity = 0
        bulletin.style.verticalEdgeOffset = 0
        bulletin.style.horizontalEdgeOffset = 0
        bulletin.style.roundedCorners = []
        bulletin.style.roundedCornerRadius = 0
        bulletin.style.isStretchingEnabled = false
        bulletin.style.isAnimatedTouchEnabled = false
        bulletin.style.shadowAlpha = 0.08
        return bulletin
        
    }
    
    public static func statusBar() -> BulletinView {
        
        let bulletin = BulletinView()
        bulletin.position = .top
        bulletin.context = .overStatusBar
        bulletin.presentationAnimation.duration = 0.2
        bulletin.presentationAnimation.springDamping = 0
        bulletin.presentationAnimation.springVelocity = 0
        bulletin.style.verticalEdgeOffset = 0
        bulletin.style.horizontalEdgeOffset = 0
        bulletin.style.roundedCorners = []
        bulletin.style.roundedCornerRadius = 0
        bulletin.style.isStretchingEnabled = false
        bulletin.style.isAnimatedTouchEnabled = false
        bulletin.style.shadowAlpha = 0
        return bulletin
        
    }
    
    public static func alert() -> BulletinView {
        
        let bulletin = BulletinView()
        bulletin.position = .center
        bulletin.duration = .forever
        bulletin.style.backgroundEffect = .darken(alpha: 0.4)
        bulletin.style.horizontalEdgeOffset = 44
        bulletin.style.roundedCornerRadius = 10
        return bulletin
        
    }
    
    public static func sheet() -> BulletinView {
        
        let bulletin = BulletinView()
        bulletin.position = .bottom
        bulletin.duration = .forever
        bulletin.style.backgroundEffect = .darken(alpha: 0.4)
        bulletin.style.verticalEdgeOffset = 8
        bulletin.style.isStretchingEnabled = false
        bulletin.style.isAnimatedTouchEnabled = false
        return bulletin
        
    }
    
}
