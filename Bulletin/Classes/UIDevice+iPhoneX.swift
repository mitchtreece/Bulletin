//
//  UIDevice+iPhoneX.swift
//  Bulletin
//
//  Created by Mitch Treece on 9/15/17.
//

import Foundation

public extension UIDevice {
    
    public var isPhoneX: Bool {
        return UIScreen.main.bounds.height == 812
    }
    
}
