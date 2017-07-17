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
    
    private var previousStatusBarStyle: UIStatusBarStyle?
    private var bulletinWindow: BulletinWindow?
    private var bulletinViewController: BulletinViewController?
    private var bulletinView: BulletinView?
    
    fileprivate var timer: Timer?
    private var soundPlayer: AVAudioPlayer?
    
    private init() {
        //
    }
    
    internal func present(_ bulletin: BulletinView, after delay: TimeInterval = 0) {
        
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
                
                bulletin.delegate = self
                bulletin.soundEffectPlayer?.play()
                bulletin.tapticFeedback(for: bulletin.taptics.presentation)
                
                _self.timer?.invalidate()
                _self.bulletinView = bulletin
                _self.animateBulletinIn(bulletin)
                
                // Needs to be called after animateBulletinIn() so frame is set correctly
                bulletin.interactionDelegate?.bulletinViewWillAppear?(bulletin)
                
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
    
    internal func dismissCurrentBulletin(withDuration duration: TimeInterval = 0.4, damping: CGFloat = 0.8, velocity: CGFloat = 0.3, completion: (()->())? = nil) {
        
        guard let cbv = bulletinView else { return }
        
        timer?.invalidate()
        timer = nil
        
        cbv.interactionDelegate?.bulletinViewWillDisappear?(cbv)
        animateCurrentBulletinOut(withDuration: duration, damping: damping, velocity: velocity, completion: completion)
        
    }
    
    internal func dismiss(_ bulletin: BulletinView) {
        
        guard let cbv = bulletinView, cbv == bulletin else { return }
        dismissCurrentBulletin()
        
    }
    
    private func animateBulletinIn(_ bulletin: BulletinView) {
        
        let window = UIApplication.shared.keyWindow!
        previousStatusBarStyle = window.rootViewController?.preferredStatusBarStyle
        
        bulletinWindow = BulletinWindow()
        bulletinWindow!.backgroundColor = UIColor.clear
        bulletinWindow!.windowLevel = (bulletin.context == .overStatusBar) ? (UIWindowLevelStatusBar + 1) : UIWindowLevelNormal
        bulletinWindow!.isHidden = false
        
        bulletinViewController = BulletinViewController()
        bulletinViewController!.bulletin = bulletin
        bulletinViewController!.isStatusBarHidden = window.rootViewController?.prefersStatusBarHidden ?? false
        bulletinWindow!.rootViewController = bulletinViewController
        bulletinViewController!.animateIn()
        bulletinViewController!.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    fileprivate func animateCurrentBulletinOut(withDuration duration: TimeInterval, damping: CGFloat, velocity: CGFloat, completion: (()->())?) {
        
        bulletinViewController?.statusBarStyle = previousStatusBarStyle
        bulletinViewController?.setNeedsStatusBarAppearanceUpdate()
        
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
        bulletin.interactionDelegate?.bulletinViewWasAutomaticallyDismissed?(bulletin)
        
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
        
        let threshold = bulletin.position == .top ? -(bulletin.bounds.height / 1.7) : (bulletin.bounds.height / 1.7)
        
        if bulletin.position == .top && (translation.y <= threshold || velocity.y <= -1200) {
            
            dismissCurrentBulletin(velocity: velocity.y)
            bulletin.interactionDelegate?.bulletinViewWasInteractivelyDismissed?(bulletin)
            
        }
        else if bulletin.position == .bottom && (translation.y >= threshold || velocity.y >= 1200) {
            
            dismissCurrentBulletin(velocity: velocity.y)
            bulletin.interactionDelegate?.bulletinViewWasInteractivelyDismissed?(bulletin)
            
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