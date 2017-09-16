//
//  UIScreen+iPhoneX.swift
//  Bulletin
//
//  Created by Mitch Treece on 9/15/17.
//

import Foundation

public struct UIScreenNotch {
    
    var size: CGSize
    var cornerRadius: CGFloat
    
}

public extension UIScreen {
    
    var topNotch: UIScreenNotch? {
        
        guard UIDevice.current.isPhoneX else { return nil}
        
        let size = CGSize(width: UIScreen.main.bounds.width - (cornerRadius! * 4), height: 30)
        let notch = UIScreenNotch(size: size, cornerRadius: 20)
        return notch
        
    }
    
    var cornerRadius: CGFloat? {
        
        guard UIDevice.current.isPhoneX else { return nil }
        return 44
        
    }
    
}
