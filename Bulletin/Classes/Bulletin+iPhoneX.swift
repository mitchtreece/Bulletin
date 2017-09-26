//
//  UIScreen+iPhoneX.swift
//  Bulletin
//
//  Created by Mitch Treece on 9/15/17.
//

import Foundation

public struct UINotch {
    
    public var size: CGSize
    public var cornerRadius: CGFloat
    
}

public struct UIGrabber {
    
    public var height: CGFloat
    
}

public extension UIDevice {
    
    public var isPhoneX: Bool {
        return UIScreen.main.bounds.height == 812
    }
    
}

public extension UIScreen {
    
    public var topNotch: UINotch? {
        
        guard UIDevice.current.isPhoneX else { return nil }
        let size = CGSize(width: (UIScreen.main.bounds.width - (cornerRadius * 4)), height: 30)
        let notch = UINotch(size: size, cornerRadius: 20)
        return notch
        
    }
    
    public var bottomGrabber: UIGrabber? {
        
        guard UIDevice.current.isPhoneX else { return nil }
        let grabber = UIGrabber(height: 23)
        return grabber
        
    }
    
    public var cornerRadius: CGFloat {
        
        guard UIDevice.current.isPhoneX else { return 0 }
        return 44
        
    }
    
}

public extension UIScreen /* ObjC */ {
    
    @available(swift 1000)
    public var topNotchWidth: CGFloat {
        
        guard UIDevice.current.isPhoneX else { return 0 }
        return (UIScreen.main.bounds.width - (cornerRadius * 4))
        
    }
    
    @available(swift 1000)
    public var topNotchHeight: CGFloat {
        
        guard UIDevice.current.isPhoneX else { return 0 }
        return 30
        
    }
    
    @available(swift 1000)
    public var bottomGrabberHeight: CGFloat {
        
        guard UIDevice.current.isPhoneX else { return 0 }
        return 23
        
    }
    
}
