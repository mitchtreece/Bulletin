//
//  BulletinWindow.swift
//  Bulletin
//
//  Created by Mitch Treece on 7/16/17.
//  Copyright © 2017 Mitch Treece. All rights reserved.
//

import UIKit

internal class BulletinWindow: UIWindow {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        // There is only ever one root subview,
        // the BulletinViewController's view
        
        for subview in subviews {
            
            if subview.subviews.count > 1 {
                
                // If the BulletinViewController's view contains
                // more than one subview (i.e. the BulletinView),
                // then a background effect view is present
                // and should handle the touch
                
                return true
                
            }
            
            for _subview in subview.subviews {
                
                if let bulletin = _subview as? BulletinView, bulletin.frame.contains(point) {
                    
                    // If there is a BulletinView, and it contains
                    // our point, let the window handle the touch
                    
                    return true
                    
                }
                
            }
            
        }
        
        return false
        
    }
    
}
