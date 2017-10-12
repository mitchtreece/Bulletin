//
//  UIViewController+Bulletin.swift
//  Bulletin
//
//  Created by Mitch Treece on 10/10/17.
//

import UIKit

internal extension UIViewController {
    
    @objc func orig_present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        
        guard let window = BulletinManager.shared.bulletinWindow,
            let rootVC = window.rootViewController,
            let cbv = BulletinManager.shared.bulletinView,
            viewControllerToPresent is UIAlertController,
            (cbv.level.rawValue < BulletinView.Level.alert.rawValue) else {
                
                orig_present(viewControllerToPresent, animated: animated, completion: completion)
                return
                
        }
        
        rootVC.orig_present(viewControllerToPresent, animated: animated, completion: completion)
        
    }
    
    class func bulletin_swizzlePresent() {
        
        // Swap implementations of our orig_present()
        // function and the native present() function
        
        let orig = class_getInstanceMethod(UIViewController.self, #selector(present(_:animated:completion:)))!
        let swizzled = class_getInstanceMethod(UIViewController.self, #selector(orig_present(_:animated:completion:)))!
        method_exchangeImplementations(orig, swizzled)
        
    }
    
}
