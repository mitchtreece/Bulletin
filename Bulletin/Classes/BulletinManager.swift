//
//  BulletinManager.swift
//  Bulletin
//
//  Created by Mitch Treece on 7/10/17.
//  Copyright © 2017 Mitch Treece. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

internal class BulletinManager {
    
    static let shared = BulletinManager()
    
    private(set) var bulletinWindow: BulletinWindow?
    private var bulletinViewController: BulletinViewController?
    private(set) var bulletinView: BulletinView?
    
    fileprivate var timer: Timer?
    private var soundPlayer: AVAudioPlayer?
    
    private init() {
        
        // Swizzle UIViewController's present() function
        // so we can properly handle bulletin window levels
        
        UIViewController.bulletin_swizzlePresent()
        
    }
    
    func present(_ bulletin: BulletinView, after delay: TimeInterval = 0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            
            guard let _self = self else { return }
            
            if let _ = _self.bulletinView {
                
                // Already displaying a bulletin,
                // dismiss and call present again
                
                _self.dismissCurrentBulletin(completion: {
                    _self.present(bulletin)
                })
                
            }
            else {
                
                bulletin._delegate = self
                bulletin.soundEffectPlayer?.play()
                bulletin.tapticFeedback(for: bulletin.taptics.presentation)
                
                _self.timer?.invalidate()
                _self.bulletinView = bulletin
                _self.animateBulletinIn(bulletin)
                
                // Needs to be called after animateBulletinIn() so frame is set correctly
                bulletin.appearanceDelegate?.bulletinViewWillAppear?(bulletin)
                
                var duration: TimeInterval = 0
                if case .limit(let time) = bulletin.duration {
                    duration = time
                }
                
                if duration > 0 {
                    _self.timer = Timer.scheduledTimer(timeInterval: duration, target: _self, selector: #selector(_self.bulletinTimerDidFire(_:)), userInfo: ["bulletin": bulletin], repeats: false)
                }
                
            }
            
        }
        
    }
    
    func dismissCurrentBulletin(withDuration duration: TimeInterval = 0.4, damping: CGFloat = 0.8, velocity: CGFloat = 0.3, completion: (()->())? = nil) {
        
        guard let cbv = bulletinView else { return }
        
        timer?.invalidate()
        timer = nil
        
        cbv.appearanceDelegate?.bulletinViewWillDisappear?(cbv)
        animateCurrentBulletinOut(withDuration: duration, damping: damping, velocity: velocity, completion: completion)
        
    }
    
    func dismiss(_ bulletin: BulletinView) {
        
        guard let cbv = bulletinView, cbv == bulletin else { return }
        dismissCurrentBulletin()
        
    }
    
    private func animateBulletinIn(_ bulletin: BulletinView) {
                
        bulletinWindow = BulletinWindow()
        bulletinWindow!.backgroundColor = UIColor.clear
        bulletinWindow!.windowLevel = UIWindow.Level(rawValue: bulletin.level.rawValue)
        bulletinWindow!.isHidden = false
        
        if let keyboardWindow = UIApplication.shared.currentKeyboardWindow, bulletin.level == .keyboard {
            keyboardWindow.addSubview(bulletinWindow!)
        }
        
        bulletinViewController = BulletinViewController()
        bulletinViewController!.bulletin = bulletin
        bulletinViewController!.previousStatusBarStyle = UIApplication.shared.currentStatusBarAppearance.style
        bulletinViewController!.isStatusBarHidden = UIApplication.shared.currentStatusBarAppearance.hidden
        bulletinWindow!.rootViewController = bulletinViewController
        bulletinViewController!.animateIn()
        
    }
    
    fileprivate func animateCurrentBulletinOut(withDuration duration: TimeInterval, damping: CGFloat, velocity: CGFloat, completion: (()->())?) {
        
        bulletinViewController?.animateOut(withDuration: duration, damping: damping, velocity: velocity, completion: {
            
            self.bulletinView?.removeFromSuperview()
            self.bulletinView = nil
            
            self.bulletinViewController?.view.removeFromSuperview()
            self.bulletinViewController = nil
            
            self.bulletinWindow?.removeFromSuperview()
            self.bulletinWindow?.isHidden = true
            self.bulletinWindow = nil
            
            completion?()
            
        })
        
    }
    
    @objc fileprivate func bulletinTimerDidFire(_ timer: Timer) {
        
        guard let info = timer.userInfo as? [String: Any],
            let bulletin = info["bulletin"] as? BulletinView else { return }
        
        dismissCurrentBulletin()
        bulletin.appearanceDelegate?.bulletinViewWasAutomaticallyDismissed?(bulletin)
        
    }
    
}

extension BulletinManager: BulletinViewDelegate {
    
    func bulletinViewDidTap(_ bulletin: BulletinView) {
        
        guard let action = bulletin.action else { return }
        
        bulletin.tapticFeedback(for: bulletin.taptics.action)
        
        dismissCurrentBulletin {
            self.dismissCurrentBulletin()
            action()
        }
        
    }
    
    func bulletinViewDidBeginPanning(_ bulletin: BulletinView) {
        
        timer?.invalidate()
        
    }
    
    func bulletinViewDidEndPanning(_ bulletin: BulletinView, withTranslation translation: CGPoint, velocity: CGPoint) {
        
        let maxTranslation = (bulletin.style.edgeInsets.top + (bulletin.bounds.height / 2))
        let maxVelocity: CGFloat = 500
        
        let yTranslation = (bulletin.position == .top) ? -translation.y : translation.y
        let yVelocity = (bulletin.position == .top) ? -velocity.y : velocity.y
        
        // print("translation = (\(yTranslation) / \(maxTranslation)), velocity = (\(yVelocity) / \(maxVelocity))")
        
        if yTranslation >= maxTranslation || yVelocity >= maxVelocity {
            
            dismissCurrentBulletin(velocity: velocity.y)
            bulletin.appearanceDelegate?.bulletinViewWasInteractivelyDismissed?(bulletin)
            
        }
        else {
            
            let damping = (bulletin.presentationAnimation.springDamping > 0) ? 0.7 : 0
            let velocity = (bulletin.presentationAnimation.springVelocity > 0) ? 0.4 : 0
            
            if damping > 0 && velocity > 0 {
                
                // Presented with a spring, snap back with one
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: [.curveEaseOut], animations: {
                    bulletin.transform = CGAffineTransform.identity
                }, completion: nil)
                
            }
            else {
                
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                    bulletin.transform = CGAffineTransform.identity
                }, completion: nil)
                
            }
            
            if bulletin.style.isStretchingEnabled {
                bulletin.tapticFeedback(for: bulletin.taptics.snapping)
            }
                        
            var duration: TimeInterval = 0
            if case .limit(let time) = bulletin.duration {
                duration = time
            }
            
            if duration > 0 {
                timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(bulletinTimerDidFire(_:)), userInfo: ["bulletin": bulletin], repeats: false)
            }

        }
        
    }
    
}
