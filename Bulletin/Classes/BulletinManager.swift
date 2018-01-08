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

internal class BulletinQueue: CustomStringConvertible, CustomDebugStringConvertible {
    
    private var bulletins = [BulletinView]()
    
    var top: BulletinView? {
        return bulletins.last
    }
    
    var isEmpty: Bool {
        return bulletins.isEmpty
    }
    
    @discardableResult
    func add(_ bulletin: BulletinView) -> BulletinView? {
        
        guard bulletin.priority != .required else {
            
            let _bulletin = pop()
            bulletins.append(bulletin)
            return _bulletin
            
        }
        
        let lastLower = bulletins.reversed().first(where: { bulletin.priority.rawValue < $0.priority.rawValue })
        let firstEqual = bulletins.first(where: { bulletin.priority == $0.priority })
        let firstGreater = bulletins.first(where: { bulletin.priority.rawValue > $0.priority.rawValue })
        
        if let _bulletin = firstEqual, let idx = bulletins.index(of: _bulletin) {
            
            bulletins.insert(bulletin, at: idx)
            
        }
        else if let _bulletin = firstGreater, let idx = bulletins.index(of: _bulletin) {
            
            bulletins.insert(bulletin, at: idx)
            
        }
        else if let _bulletin = lastLower, let idx = bulletins.index(of: _bulletin) {
            
            bulletins.insert(bulletin, at: (idx))
            
        }
        else {
            
            // Only element. insert.
            bulletins.append(bulletin)
            
        }
        
        return nil
        
    }
    
    @discardableResult
    func pop() -> BulletinView? {
        guard !bulletins.isEmpty else { return nil }
        return bulletins.removeLast()
    }
    
    // MARK: CustomStringConvertible
    
    var description: String {
        
        guard !self.isEmpty else { return "<BulletinQueue - 0 elements>" }
        
        var string = ""
        
        for b in bulletins {
            
            switch b.priority {
            case .low: string += "L, "
            case .default: string += "D, "
            case .high: string += "H, "
            case .required: string += "R, "
            }
            
        }
        
        let index = string.index(string.endIndex, offsetBy: -2)
        string = String(string[..<index])
        
        return "<BulletinQueue - \(bulletins.count) elements, [\(string)]>"
        
    }
    
    var debugDescription: String {
        return description
    }
    
}

internal class BulletinManager {
    
    static let shared = BulletinManager()
    
    private(set) var bulletinWindow: BulletinWindow?
    private var bulletinViewController: BulletinViewController?
    
    private(set) var queue = BulletinQueue()
    private(set) var currentBulletin: BulletinView?

    fileprivate var timer: Timer?
    private var soundPlayer: AVAudioPlayer?
    
    private init() {
        
        // Swizzle UIViewController's present() function
        // so we can properly handle bulletin window levels
        
        UIViewController.bulletin_swizzlePresent()
        
    }
    
    func enqueue(_ bulletin: BulletinView) {
        
        guard !queue.isEmpty else {
            
            queue.add(bulletin)
            present(bulletin: bulletin)
            return
            
        }
        
        if let popped = queue.add(bulletin) {
            
            // Dismiss popped bulletin & present next in queue
            
            dismiss(popped, shouldPopAndPresentNext: false, completion: { [weak self] in
                guard let _self = self, let next = _self.queue.top else { return }
                _self.present(bulletin: next, popped: true)
            })
            
        }
        
    }
    
    private func present(bulletin: BulletinView, popped: Bool = false) {
        
        let delay: TimeInterval = popped ? 0 : bulletin.delay
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            
            guard let _self = self else { return }
            
            bulletin._delegate = self
            bulletin.soundEffectPlayer?.play()
            bulletin.tapticFeedback(for: bulletin.taptics.presentation)
            
            _self.timer?.invalidate()
            _self.currentBulletin = bulletin
            _self._animateBulletinIn(bulletin)
            
            // Needs to be called after animateBulletinIn() so frame is set correctly
            bulletin.appearanceDelegate?.bulletinViewWillAppear?(bulletin)

            var duration: TimeInterval = 0
            if case .limit(let time) = bulletin.duration {
                duration = time
            }

            if duration > 0 {
                
                _self.timer = Timer.scheduledTimer(timeInterval: duration,
                                                   target: _self,
                                                   selector: #selector(_self.bulletinTimerDidFire(_:)),
                                                   userInfo: ["bulletin": bulletin],
                                                   repeats: false)
                
            }
            
        }
        
    }
    
    private func popAndPresentNextBulletinIfNeeded() {
        
        queue.pop()
        
        guard let next = queue.top else { return }
        present(bulletin: next, popped: true)
        
    }
    
    internal func dismiss(_ bulletin: BulletinView,
                          velocity: CGFloat = 0.3,
                          shouldPopAndPresentNext: Bool = true,
                          completion: (()->())? = nil) {
        
        // Invalidate timer
        
        timer?.invalidate()
        timer = nil
        
        // Animate bullet in out
        
        bulletin.appearanceDelegate?.bulletinViewWillDisappear?(bulletin)
        // _animateBulletinOut(bulletin, velocity: velocity, completion: completion)
        
        _animateBulletinOut(bulletin, velocity: velocity) { [weak self] in
            
            completion?()
            
            if shouldPopAndPresentNext {
                self?.popAndPresentNextBulletinIfNeeded()
            }
            
        }
        
    }
    
    fileprivate func _animateBulletinOut(_ bulletin: BulletinView, velocity: CGFloat, completion: (()->())?) {
        
        bulletinViewController?.animateOut(withDuration: 0.4, damping: 0.8, velocity: velocity, completion: {
            
            self.currentBulletin?.removeFromSuperview()
            self.currentBulletin = nil
            
            self.bulletinViewController?.view.removeFromSuperview()
            self.bulletinViewController = nil
            
            self.bulletinWindow?.removeFromSuperview()
            self.bulletinWindow?.isHidden = true
            self.bulletinWindow = nil
            
            completion?()
            
        })
        
    }
    
    fileprivate func _animateBulletinIn(_ bulletin: BulletinView) {
                
        bulletinWindow = BulletinWindow()
        bulletinWindow!.backgroundColor = UIColor.clear
        bulletinWindow!.windowLevel = bulletin.level.rawValue
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
    
    @objc fileprivate func bulletinTimerDidFire(_ timer: Timer) {
        
        guard let info = timer.userInfo as? [String: Any],
            let bulletin = info["bulletin"] as? BulletinView else { return }
        
        dismiss(bulletin) {
            bulletin.appearanceDelegate?.bulletinViewWasAutomaticallyDismissed?(bulletin)
        }
        
    }
    
}

extension BulletinManager: BulletinViewDelegate {
    
    func bulletinViewDidTap(_ bulletin: BulletinView) {
        
        guard let action = bulletin.action else { return }
        
        bulletin.tapticFeedback(for: bulletin.taptics.action)
        
        dismiss(bulletin) {
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
            
            dismiss(bulletin, velocity: velocity.y, completion: {
                bulletin.appearanceDelegate?.bulletinViewWasInteractivelyDismissed?(bulletin)
            })
            
        }
        else {
            
            let damping = (bulletin.presentationAnimation.springDamping > 0) ? 0.7 : 0
            let velocity = (bulletin.presentationAnimation.springVelocity > 0) ? 0.4 : 0
            
            if damping > 0 && velocity > 0 {
                
                // Presented with a spring, snap back with one
                
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 0.4,
                               options: [.curveEaseOut],
                               animations: {
                                
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
            
            // Reset timer
                        
            var duration: TimeInterval = 0
            if case .limit(let time) = bulletin.duration {
                duration = time
            }
            
            if duration > 0 {
                
                timer = Timer.scheduledTimer(timeInterval: duration,
                                             target: self,
                                             selector: #selector(bulletinTimerDidFire(_:)),
                                             userInfo: ["bulletin": bulletin],
                                             repeats: false)
                
            }

        }
        
    }
    
}
