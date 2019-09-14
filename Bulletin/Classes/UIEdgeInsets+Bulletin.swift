//
//  UIEdgeInsets+Bulletin.swift
//  Bulletin
//
//  Created by Mitch Treece on 9/25/17.
//

import UIKit

public extension UIEdgeInsets {
    
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
}
