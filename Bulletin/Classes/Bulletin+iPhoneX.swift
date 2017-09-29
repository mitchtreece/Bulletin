//
//  UIScreen+iPhoneX.swift
//  Bulletin
//
//  Created by Mitch Treece on 9/15/17.
//

import Foundation

/**
 A class representing a specific user-facing feature of or on the screen.
 */
@objcMembers
@objc public class UIDisplayFeature: NSObject {
    
    public var frame: CGRect = CGRect.zero
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    init(frame: CGRect) {
        self.frame = frame
    }
    
}

/**
 A display feature representing a cut-out (notch) in the screen.
 */
@objcMembers
@objc public class UINotch: UIDisplayFeature {
    
    public private(set) var cornerRadius: CGFloat = 20
    
}

/**
 A display feature representing the system "home-grabber" on the screen.
 */
@objcMembers
@objc public class UIHomeGrabber: UIDisplayFeature {}

public extension UIDevice {
    
    /**
     Boolean indicating whether the current device is an iPhone X.
     */
    @objc public var isPhoneX: Bool {
        return UIScreen.main.bounds.height == 812
    }
    
}

public extension UIScreen {
    
    /**
     The screen's display feature insets. These take into account features like: status-bars, notches, home-grabbers, etc.
     */
    @objc public var displayFeatureInsets: UIEdgeInsets {
        
        let statusBar = UIApplication.shared.statusBarFrame.height
        
        guard UIDevice.current.isPhoneX else {
            return UIEdgeInsets(top: statusBar, left: 0, bottom: 0, right: 0)
        }
        
        let bottom = UIScreen.main.homeGrabber?.height ?? 0
        return UIEdgeInsets(top: statusBar, left: 0, bottom: bottom, right: 0)
        
    }
    
    /**
     The screen's corner radius.
     */
    @objc public var cornerRadius: CGFloat {
        
        guard UIDevice.current.isPhoneX else { return 0 }
        return 44
        
    }
    
    /**
     The screen's top notch.
     */
    @objc public var notch: UINotch? {

        guard UIDevice.current.isPhoneX else { return nil }
        let size = CGSize(width: 209, height: 31)
        let frame = CGRect(x: ((UIScreen.main.bounds.width - size.width) / 2), y: 0, width: size.width, height: size.height)
        let notch = UINotch(frame: frame)
        return notch

    }

    /**
     The screen's bottom home-grabber.
     */
    @objc public var homeGrabber: UIHomeGrabber? {

        guard UIDevice.current.isPhoneX else { return nil }
        let size = CGSize(width: UIScreen.main.bounds.width, height: 23)
        let frame = CGRect(x: 0, y: (UIScreen.main.bounds.height - size.height), width: size.width, height: size.height)
        let grabber = UIHomeGrabber(frame: frame)
        return grabber

    }

}
