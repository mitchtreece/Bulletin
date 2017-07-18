//
//  NavigationController.swift
//  Bulletin_Example
//
//  Created by Mitch Treece on 7/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        
        return topViewController
        
    }
    
}
