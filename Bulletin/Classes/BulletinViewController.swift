//
//  BulletinViewController.swift
//  Bulletin
//
//  Created by Mitch Treece on 7/16/17.
//  Copyright © 2017 Mitch Treece. All rights reserved.
//

import UIKit

internal class BulletinViewController: UIViewController {
    
    private var darkeningEffectView: UIView?
    private var blurEffectView: UIVisualEffectView?
    
    var bulletin: BulletinView?
    
    var previousStatusBarStyle: UIStatusBarStyle?
    var isStatusBarHidden: Bool = false
    
    private var statusBarStyleOverride: UIStatusBarStyle?
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        guard statusBarStyleOverride == nil else { return statusBarStyleOverride! }
        return bulletin?.style.statusBar ?? previousStatusBarStyle ?? .default
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
    }
    
    func animateIn() {
        
        guard let bulletin = bulletin else { return }
        
        switch bulletin.style.backgroundEffect {
        case .none: break
        case .darken(let alpha):
            
            darkeningEffectView = UIView()
            darkeningEffectView!.backgroundColor = UIColor.black.withAlphaComponent(alpha)
            darkeningEffectView!.alpha = 0
            view.addSubview(darkeningEffectView!)
            darkeningEffectView!.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
            }
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundEffectView(_:)))
            darkeningEffectView!.addGestureRecognizer(recognizer)
            
        case .blur(let style):
            
            blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
            blurEffectView!.alpha = 0
            view.addSubview(blurEffectView!)
            blurEffectView!.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
            }
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundEffectView(_:)))
            blurEffectView!.addGestureRecognizer(recognizer)
            
        }
        
        view.addSubview(bulletin)
        bulletin.snp.makeConstraints { (make) in
            
            make.left.equalTo(bulletin.style.edgeInsets.left)
            make.right.equalTo(-bulletin.style.edgeInsets.right)
            
            if bulletin.position == .top {
                make.top.equalTo(bulletin.style.edgeInsets.top)
            }
            else if bulletin.position == .bottom {
                make.bottom.equalTo(-bulletin.style.edgeInsets.bottom)
            }
            else if bulletin.position == .center {
                make.center.equalTo(view)
            }
            
        }
        
        bulletin.layoutIfNeeded()
        
        let duration = bulletin.presentationAnimation.duration
        let damping = bulletin.presentationAnimation.springDamping
        let velocity = bulletin.presentationAnimation.springVelocity
        
        if bulletin.position == .center {
            bulletin.alpha = 0
            bulletin.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
        else {
            let inset = (bulletin.position == .top) ? bulletin.style.edgeInsets.top : bulletin.style.edgeInsets.bottom
            let yOffset = (bulletin.bounds.height + inset)
            let ty = (bulletin.position == .bottom) ? yOffset : -yOffset
            bulletin.transform = CGAffineTransform(translationX: 0, y: ty)
        }
        
        if damping > 0 && velocity > 0 {
            
            // Spring
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [], animations: {
                
                self.darkeningEffectView?.alpha = 1
                self.blurEffectView?.alpha = 1
                
                bulletin.transform = CGAffineTransform.identity
                bulletin.alpha = 1
                
            }, completion: nil)
            
        }
        else {
            
            UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
                
                self.darkeningEffectView?.alpha = 1
                self.blurEffectView?.alpha = 1
                
                bulletin.transform = CGAffineTransform.identity
                bulletin.alpha = 1
                
            }, completion: nil)
            
        }
        
    }
    
    func animateOut(withDuration duration: TimeInterval, damping: CGFloat, velocity: CGFloat, completion: (()->())?) {
        
        guard let bulletin = bulletin else { return }
        
        statusBarStyleOverride = previousStatusBarStyle ?? .default
        setNeedsStatusBarAppearanceUpdate()
        
        if bulletin.position == .center {
            
            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState], animations: {
                
                self.darkeningEffectView?.alpha = 0
                self.blurEffectView?.alpha = 0
                
                bulletin.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                bulletin.alpha = 0
                
            }, completion: { (finished) in
                
                self.darkeningEffectView?.removeFromSuperview()
                self.darkeningEffectView = nil
                
                self.blurEffectView?.removeFromSuperview()
                self.blurEffectView = nil
                
                completion?()
                
            })
            
        }
        else {
            
            let inset = (bulletin.position == .top) ? bulletin.style.edgeInsets.top : bulletin.style.edgeInsets.bottom
            let shadowOffset = (bulletin.style.shadowRadius + bulletin.style.shadowOffset.height)
            let yOffset = (bulletin.bounds.height + inset + shadowOffset)
            let ty = (bulletin.position == .bottom) ? yOffset : -yOffset
            let normalizedVelocity = ((-1 * velocity) / ty)
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: normalizedVelocity, options: [.beginFromCurrentState], animations: {
                
                self.darkeningEffectView?.alpha = 0
                self.blurEffectView?.alpha = 0
                bulletin.transform = CGAffineTransform(translationX: 0, y: ty)
                
            }) { (finished) in
                
                self.darkeningEffectView?.removeFromSuperview()
                self.darkeningEffectView = nil
                
                self.blurEffectView?.removeFromSuperview()
                self.blurEffectView = nil
                                
                completion?()
                
            }
            
        }
        
    }
    
    @objc private func didTapBackgroundEffectView(_ recognizer: UITapGestureRecognizer) {
        
        guard let bulletin = bulletin, bulletin.style.isBackgroundDismissEnabled == true else { return }
        BulletinManager.shared.dismissCurrentBulletin()
        bulletin.appearanceDelegate?.bulletinViewWasInteractivelyDismissed?(bulletin)
        
    }
    
}
