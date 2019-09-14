//
//  BulletinView+ObjC.swift
//  Bulletin
//
//  Created by Mitch Treece on 8/9/17.
//  Copyright © 2017 Mitch Treece. All rights reserved.
//

import UIKit

public extension BulletinView /* ObjC */ {
    
    /**
     Sets the bulletin's on-screen position.
     
     `0 = top`, `1 = center`, `2 = bottom`
     */
    @available(swift 1000)
    @objc(setPosition:)
    func set(position: Int) {
        
        switch position {
        case 0: self.position = .top
        case 1: self.position = .center
        case 2: self.position = .bottom
        default: self.position = .top
        }
        
    }
    
    /**
     Sets the bulletin's on-screen duration.
     
     Note: A duration less-than-or-equal-to `0` will create a persistent bulletin.
     */
    @available(swift 1000)
    @objc(setDuration:)
    func set(duration: TimeInterval) {
        
        if duration <= 0 {
            self.duration = .forever
            return
        }
        
        self.duration = .limit(duration)
        
    }
    
    /**
     Sets the bulletin's on-screen level.
     
     `0 = default`, `1000 = statusBar`, `2000 = alert`
     */
    @available(swift 1000)
    @objc(setLevel:)
    func set(level: Int) {
        
        switch level {
        case 0: self.level = .default
        case 1000: self.level = .statusBar
        case 2000: self.level = .alert
        default: self.level = .default
        }
        
    }
    
    /**
     Sets the bulletin's edge insets.
     */
    @available(swift 1000)
    @objc(setEdgeInsets:)
    func set(edgeInsets: UIEdgeInsets) {
        self.style.edgeInsets = edgeInsets
    }
    
    /**
     Sets the bulletin's corner radius.
     */
    @available(swift 1000)
    @objc(setCornerRadius:)
    func set(cornerRadius: CGFloat) {
        
        self.style.roundedCorners = [.allCorners]
        self.style.roundedCornerRadius = cornerRadius
        
    }
    
    /**
     Sets the bulletin's background effect style.
     
     `0 = none`, `1 = darken (light)`, `2 = darken (medium)`, `3 = darken (high)`,
     `4 = blur (light)`, `5 = blur (extra light)`, `6 = blur (dark)`
     */
    @available(swift 1000)
    @objc(setBackgroundEffect:)
    func set(backgroundEffect: Int) {
        
        switch backgroundEffect {
        case 0: self.style.backgroundEffect = .none
        case 1: self.style.backgroundEffect = .darken(alpha: 0.25)
        case 2: self.style.backgroundEffect = .darken(alpha: 0.5)
        case 3: self.style.backgroundEffect = .darken(alpha: 0.75)
        case 4: self.style.backgroundEffect = .blur(style: .light)
        case 5: self.style.backgroundEffect = .blur(style: .extraLight)
        case 6: self.style.backgroundEffect = .blur(style: .dark)
        default: self.style.backgroundEffect = .none
        }
        
    }
    
    /**
     Presents the bulletin.
     */
    @available(swift 1000)
    func present() {
        self.present(after: 0)
    }
    
    /**
     Embeds a content view into the bulletin using the view's intrinsic content height.
     - parameter content: The content view to embed.
     */
    @available(swift 1000)
    @objc(embedContent:)
    func embed(content: UIView) {
        self.embed(content: content, usingStrictHeight: nil)
    }
    
    /**
     Embeds a content view into the bulletin.
     - parameter content: The content view to embed.
     - parameter height: The height for the content view. If no height is provided, the content view's intrinsic size will be used.
     */
    @available(swift 1000)
    @objc(embedContent:usingStrictHeight:)
    func embed(content: UIView, usingStrictHeight height: CGFloat) {
        self.embed(content: content, usingStrictHeight: height)
    }
    
}
