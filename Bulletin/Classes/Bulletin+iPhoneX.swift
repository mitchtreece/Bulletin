//
//  UIScreen+iPhoneX.swift
//  Bulletin
//
//  Created by Mitch Treece on 9/15/17.
//

import Foundation

public struct UINotch {
    
    public var frame: CGRect
    public var cornerRadius: CGFloat
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
}

public struct UIHomeGrabber {
    
    public var size: CGSize
    
}

public struct UISafeArea {
    
    public var insets: UIEdgeInsets {
        
        return UIEdgeInsets(top: UIScreen.main.notch?.height ?? UIApplication.shared.statusBarFrame.height,
                            left: 0,
                            bottom: UIScreen.main.homeGrabber?.size.height ?? 0,
                            right: 0)
        
    }
    
    public var frame: CGRect {
        
        return CGRect(x: insets.left,
                      y: insets.top,
                      width: UIScreen.main.bounds.width - (insets.left + insets.right),
                      height: UIScreen.main.bounds.height - (insets.top + insets.bottom))
        
    }
    
}

public extension UIScreen {

    public var safeArea: UISafeArea {
        return UISafeArea()
    }
    
    public var cornerRadius: CGFloat {
        
        guard UIDevice.current.isPhoneX else { return 0 }
        return 44
        
    }
    
    public var notch: UINotch? {

        guard UIDevice.current.isPhoneX else { return nil }
        let width: CGFloat = 209
        let frame = CGRect(x: ((UIScreen.main.bounds.width - width) / 2), y: 0, width: width, height: 31)
        let notch = UINotch(frame: frame, cornerRadius: 20)
        return notch

    }

    public var homeGrabber: UIHomeGrabber? {

        guard UIDevice.current.isPhoneX else { return nil }
        let grabber = UIHomeGrabber(size: CGSize(width: UIScreen.main.bounds.width, height: 23))
        return grabber

    }

}

public extension UIDevice {

    public var isPhoneX: Bool {
        return UIScreen.main.bounds.height == 812
    }

}
