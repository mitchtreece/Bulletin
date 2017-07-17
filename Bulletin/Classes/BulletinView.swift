//
//  BulletinView.swift
//  Bulletin
//
//  Created by Mitch Treece on 7/10/17.
//  Copyright © 2017 Mitch Treece. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

internal protocol BulletinViewDelegate: class {
    func bulletinViewDidTap(_ bulletin: BulletinView)
    func bulletinViewDidBeginPanning(_ bulletin: BulletinView)
    func bulletinViewDidEndPanning(_ bulletin: BulletinView, withTranslation translation: CGPoint, velocity: CGPoint)
}

@objc public protocol BulletinViewInteractionDelegate: class {
    @objc optional func bulletinViewWillAppear(_ bulletin: BulletinView)
    @objc optional func bulletinViewWillDisappear(_ bulletin: BulletinView)
    @objc optional func bulletinViewWasAutomaticallyDismissed(_ bulletin: BulletinView)
    @objc optional func bulletinViewWasInteractivelyDismissed(_ bulletin: BulletinView)
}

public class AnimationSettings {
    
    public var duration: TimeInterval = 0.4
    public var springDamping: CGFloat = 0.7
    public var springVelocity: CGFloat = 0.4
    
}

public class StyleSettings {
    
    public enum BackgroundEffect {
        case none
        case darken(alpha: CGFloat)
        case blur(style: UIBlurEffectStyle)
    }
    
    internal weak var shadowLayer: CAShapeLayer?
    
    public var statusBar: UIStatusBarStyle = .default
    public var backgroundEffect: BackgroundEffect = .none
    public var horizontalEdgeOffset: CGFloat = 8
    public var verticalEdgeOffset: CGFloat = 24
    
    public var roundedCorners: UIRectCorner = .allCorners
    public var roundedCornerRadius: CGFloat = 4
    
    public var isStretchingEnabled: Bool = true
    public var isAnimatedTouchEnabled: Bool = true
    public var isBackgroundDismissEnabled: Bool = true
    
    public var shadowColor: UIColor = .black {
        didSet {
            shadowLayer?.shadowColor = shadowColor.cgColor
        }
    }
    
    public var shadowOffset: CGSize = CGSize(width: 0, height: 2) {
        didSet {
            shadowLayer?.shadowOffset = shadowOffset
        }
    }
    
    public var shadowRadius: CGFloat = 3 {
        didSet {
            shadowLayer?.shadowRadius = shadowRadius
        }
    }
    
    public var shadowAlpha: Float = 0.15 {
        didSet {
            shadowLayer?.shadowOpacity = shadowAlpha
        }
    }
    
}

public class TapticSettings {
    
    public enum Style {
        case none
        case notification(UINotificationFeedbackType)
        case impact(UIImpactFeedbackStyle)
        case selectionChanged
    }
    
    public var presentation: Style = .notification(.success)
    public var action: Style  = .impact(.light)
    public var snapping: Style = .impact(.light)
    
}

public class BulletinView: UIView {
    
    public enum PresentationContext {
        case `default`
        case overStatusBar
    }
    
    public enum Duration {
        case forever
        case limit(TimeInterval)
    }
    
    public enum Position {
        case top
        case center
        case bottom
    }
    
    public var identifier: String?
    public var position: Position = .top
    public var duration: Duration = .limit(5)
    public var context: PresentationContext = .default
    public var info: [String: Any]?
    
    public var action: (()->())? {
        didSet {
            
            guard let _ = action else {
                
                if let recognizer = tapRecognizer {
                    contentView.removeGestureRecognizer(recognizer)
                    tapRecognizer = nil
                }
                
                return
                
            }
            
            tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
            contentView.addGestureRecognizer(tapRecognizer!)
            
        }
    }
    
    internal var soundEffectPlayer: AVAudioPlayer?
    public var soundEffectUrl: URL? {
        didSet {
            
            guard let url = soundEffectUrl else {
                soundEffectPlayer = nil
                return
            }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                soundEffectPlayer = try? AVAudioPlayer(contentsOf: url)
                soundEffectPlayer?.prepareToPlay()
            }
            catch let error {
                print("Error preloading sound (\(url.lastPathComponent): \(error.localizedDescription)")
            }
            
        }
    }
    
    public private(set) var presentationAnimation = AnimationSettings()
    // public private(set) var dismissalAnimation = AnimationSettings()
    public private(set) var style = StyleSettings()
    public private(set) var taptics = TapticSettings()
    
    public weak var interactionDelegate: BulletinViewInteractionDelegate?
    internal weak var delegate: BulletinViewDelegate?
    
    private var shadowLayer: CAShapeLayer!
    private var shadowMask: CAShapeLayer!
    public private(set) var contentView: UIView!
    
    private var tapRecognizer: UITapGestureRecognizer?
    
    public convenience init() {
        
        // Should use CGRect.zero, but for some reason not
        // setting an initial width/height results in a bad frame
        
        self.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
    }
    
    public convenience init(view: UIView) {
        
        // Should use CGRect.zero, but for some reason not
        // setting an initial width/height results in a bad frame
        
        self.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
    
        backgroundColor = UIColor.clear
        
        shadowLayer = CAShapeLayer()
        shadowLayer.masksToBounds = false
        shadowLayer.fillColor = UIColor.clear.cgColor
        shadowLayer.shadowColor = style.shadowColor.cgColor
        shadowLayer.shadowOffset = style.shadowOffset
        shadowLayer.shadowRadius = style.shadowRadius
        shadowLayer.shadowOpacity = style.shadowAlpha
        style.shadowLayer = shadowLayer
        layer.addSublayer(shadowLayer)
        
        shadowMask = CAShapeLayer()
        shadowMask.fillRule = kCAFillRuleEvenOdd
        
        contentView = UIView()
        contentView.backgroundColor = UIColor.clear
        contentView.layer.masksToBounds = true
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(didPress(_:)))
        press.delegate = self
        press.minimumPressDuration = 0.01
        press.cancelsTouchesInView = false
        contentView.addGestureRecognizer(press)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        pan.delegate = self
        contentView.addGestureRecognizer(pan)
        
    }
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let radii = CGSize(width: style.roundedCornerRadius, height: style.roundedCornerRadius)
        let roundedPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: style.roundedCorners, cornerRadii: radii)
        
        shadowLayer.frame = bounds
        shadowLayer.shadowPath = roundedPath.cgPath
        
        let contentMask = CAShapeLayer()
        contentMask.path = roundedPath.cgPath
        contentView.layer.mask = contentMask
        
        // Inner shadow mask
        
        let insets: CGFloat = (style.shadowRadius * 2) + max(style.shadowOffset.width, style.shadowOffset.height)
        let shadowMaskPath = roundedPath
        shadowMaskPath.append(UIBezierPath(rect: bounds.insetBy(dx: -insets, dy: -insets)))

        shadowMask.path = shadowMaskPath.cgPath
        shadowLayer.mask = shadowMask
        
    }
    
    // MARK: Public
    
    public func present(after delay: TimeInterval = 0) {
        
        BulletinManager.shared.present(self, after: delay)
        
    }
    
    public func dismiss() {
        
        BulletinManager.shared.dismiss(self)
        
    }
    
    // MARK: Private / Internal
    
    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        
        delegate?.bulletinViewDidTap(self)
        
    }
    
    @objc private func didPress(_ recognizer: UILongPressGestureRecognizer) {
        
        guard position != .center else { return }
        
        let scale: CGFloat = style.isAnimatedTouchEnabled ? 0.98 : 1

        if scale < 1 {
            
            if recognizer.state == .began {
            
                UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
                    self.transform = self.transform.scaledBy(x: scale, y: scale)
                }, completion: nil)
                
            }
            else if recognizer.state == .ended {
                
                UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
                    // Need an identity transform, translated by my current dx & dy
                    self.transform = CGAffineTransform.identity.translatedBy(x: self.transform.tx, y: self.transform.ty)
                }, completion: nil)
                
            }
            
        }
        
    }
    
    @objc private func didPan(_ recognizer: UIPanGestureRecognizer) {
        
        guard let superView = self.superview else { return }
        guard position != .center else { return }
        
        let velocity = recognizer.velocity(in: superView)
        let translation = recognizer.translation(in: superView)
        let ty = translation.y
        
        let touchScale: CGFloat = style.isAnimatedTouchEnabled ? 0.98 : 1
        
        switch recognizer.state {
        case .began: delegate?.bulletinViewDidBeginPanning(self)
        case .changed:
            
            var yTransform: CGFloat
            
            if position == .top {
                yTransform = (ty <= 0) ? ty : (style.isStretchingEnabled ? (ty - (ty * 0.8)) : 0)
            }
            else {
                yTransform = (ty >= 0) ? ty : (style.isStretchingEnabled ? (ty - (ty * 0.8)) : 0)
            }
            
            self.transform = CGAffineTransform(translationX: 0, y: yTransform).scaledBy(x: touchScale, y: touchScale)
            
        case .ended: delegate?.bulletinViewDidEndPanning(self, withTranslation: translation, velocity: velocity)
        default: break
        }
        
    }
    
    internal func tapticFeedback(for style: TapticSettings.Style) {
        
        if #available(iOS 10, *) {
            
            UIFeedbackGenerator().prepare()
            
            switch style {
            case .none: break
            case .notification(let type): UINotificationFeedbackGenerator().notificationOccurred(type)
            case .impact(let style): UIImpactFeedbackGenerator(style: style).impactOccurred()
            case .selectionChanged: UISelectionFeedbackGenerator().selectionChanged()
            }
            
        }
        
    }
    
}

extension BulletinView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
