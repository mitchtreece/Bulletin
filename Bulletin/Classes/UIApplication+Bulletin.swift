//
//  UIApplication+Bulletin.swift
//  Bulletin
//
//  Created by Mitch Treece on 7/17/17.
//  Copyright © 2017 Mitch Treece. All rights reserved.
//

import UIKit

internal typealias UIStatusBarAppearance = (style: UIStatusBarStyle, hidden: Bool)

internal extension UIApplication {
    
    var currentStatusBarAppearance: UIStatusBarAppearance {
        
        guard let rootVC = keyWindow?.rootViewController else { return (.default, false) }
        
        if let nav = rootVC as? UINavigationController {
            
            let style = nav.topViewController?.preferredStatusBarStyle ?? .default
            let hidden = nav.topViewController?.prefersStatusBarHidden ?? false
            return (style, hidden)
            
        }
        else if let tab = rootVC as? UITabBarController {
            
            let style = tab.selectedViewController?.preferredStatusBarStyle ?? .default
            let hidden = tab.selectedViewController?.prefersStatusBarHidden ?? false
            return (style, hidden)
            
        }
        
        return (rootVC.preferredStatusBarStyle, rootVC.prefersStatusBarHidden)
        
    }
    
    var currentKeyboardWindow: UIWindow? {

        for window in UIApplication.shared.windows {
            if NSStringFromClass(window.classForCoder) == "UIRemoteKeyboardWindow" {
                return window
            }
        }
        
        return nil
        
    }
    
}
