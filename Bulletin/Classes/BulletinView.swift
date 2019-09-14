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

/**
 Protocol that provides `BulletinView` appearance information.
 */
@objc public protocol BulletinViewAppearanceDelegate: class {
    
    /**
     Called when a bulletin is about to be presented.
     */
    @objc optional func bulletinViewWillAppear(_ bulletin: BulletinView)
    
    /**
     Called when a bulletin is about to be dismissed.
     */
    @objc optional func bulletinViewWillDisappear(_ bulletin: BulletinView)
    
    /**
     Called when a bulletin was dismissed automatically.
     */
    @objc optional func bulletinViewWasAutomaticallyDismissed(_ bulletin: BulletinView)
    
    /**
     Called when a bulletin was dismissed interactively (i.e. swiping away, tapping background effect view).
     */
    @objc optional func bulletinViewWasInteractivelyDismissed(_ bulletin: BulletinView)
    
}

/**
 Wrapper class for various `BulletinView` animation settings.
 */
public class AnimationSettings {
    
    /**
     The duration of the animation.
     */
    public var duration: TimeInterval = 0.4
    
    /**
     The physics-based spring damping of the animation.
     */
    public var springDamping: CGFloat = 0.7
    
    /**
     The physics-based spring velocity of the animation.
     */
    public var springVelocity: CGFloat = 0.4
    
}

/**
 Wrapper class for various `BulletinView` style settings.
 */
public class StyleSettings {
    
    /**
     Enum representing the various `BulletinView` background effects.
     */
    public enum BackgroundEffect {
        
        /// No effect.
        case none
        
        /// Adds a black overlay to the view's background with a given alpha.
        case darken(alpha: CGFloat)
        
        /// Adds a blur overlay to the view's background with a given style.
        case blur(style: UIBlurEffect.Style)
        
    }
    
    internal weak var shadowLayer: CAShapeLayer?
    
    /**
     The status bar style to use when presenting the bulletin.
     
     If no style is provided, the bulletin will use the current status bar style.
     */
    public var statusBar: UIStatusBarStyle?
    
    /**
     The bulletin's background effect style.
     
     Defaults to `none`.
     */
    public var backgroundEffect: BackgroundEffect = .none

    /**
     The bulletin's insets from the screen edges. By default, this takes into account display features (top notch, home grabber) if applicable.
     */
    public var edgeInsets: UIEdgeInsets = UIEdgeInsets(
        top: UIScreen.main.displayFeatureInsets.top + 4,
        left: UIScreen.main.displayFeatureInsets.left + 8,
        bottom: UIScreen.main.displayFeatureInsets.bottom + (UIDevice.current.isModern ? 4 : 8),
        right: UIScreen.main.displayFeatureInsets.right + 8
    )
    
    /**
     The set of corners to apply a rounded corner radius to.
     
     Defaults to `allCorners`.
     */
    public var roundedCorners: UIRectCorner = .allCorners
    
    /**
     The bulletin's offset from it's left & right container edges.
     
     Defaults to `4`.
     */
    public var roundedCornerRadius: CGFloat = 4
    
    /**
     Boolean indicating whether the bulletin can be panned past it's resting frame.
     
     Defaults to `true`.
     */
    public var isStretchingEnabled: Bool = true
    
    /**
     Boolean indicating whether the bulletin should perform animations on various touch events.
     
     Defaults to `true`.
     */
    public var isAnimatedTouchEnabled: Bool = true
    
    /**
     Boolean indicating whether tapping the background effect view should dismiss the bulletin.
     
     Defaults to `true`.
     */
    public var isBackgroundDismissEnabled: Bool = true
    
    /**
     The bulletin's shadow color.
     
     Defaults to `black`.
     */
    public var shadowColor: UIColor = .black {
        didSet {
            shadowLayer?.shadowColor = shadowColor.cgColor
        }
    }
    
    /**
     The bulletin's shadow offset.
     
     Defaults to `(0, 2)`.
     */
    public var shadowOffset: CGSize = CGSize(width: 0, height: 2) {
        didSet {
            shadowLayer?.shadowOffset = shadowOffset
        }
    }
    
    /**
     The bulletin's shadow radius.
     
     Defaults to `3`.
     */
    public var shadowRadius: CGFloat = 3 {
        didSet {
            shadowLayer?.shadowRadius = shadowRadius
        }
    }
    
    /**
     The bulletin's shadow alpha.
     
     Defaults to `0.15`.
     */
    public var shadowAlpha: Float = 0.15 {
        didSet {
            shadowLayer?.shadowOpacity = shadowAlpha
        }
    }
    
}

/**
 Wrapper class for various `BulletinView` taptic settings.
 */
public class TapticSettings {
    
    /**
     Enum representing a various `BulletinView` taptic styles.
     */
    public enum Style {
        
        /// No taptic
        case none
        
        /// A notification taptic with a given feedback type.
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        
        /// An impact taptic with a given feedback style.
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        
        /// A selection changed taptic.
        case selectionChanged
        
    }
    
    /**
     The bulletin's presentation taptic.
     
     Defaults to `notification(success)`.
     */
    public var presentation: Style = .notification(.success)
    
    /**
     The bulletin's action taptic.
     
     Defaults to `impact(light)`.
     */
    public var action: Style  = .impact(.light)
    
    /**
     The bulletin's snapping taptic.
     
     Defaults to `impact(light)`.
     */
    public var snapping: Style = .impact(.light)
    
}

/**
 `BulletinView` is a `UIView` container subclass that contains various bulletin properties.
 */
@objcMembers
public class BulletinView: UIView {
    
    /**
     Enum representing a bulletin's z-position in the window hierarchy.
     */
    public enum Level: CGFloat {
        
        /// Bulletins with this level appear under the status bar, alerts, & keyboards.
        case `default` = 0
        
        /// Bulletins with this level appear over the status bar, but under alerts & keyboards.
        case statusBar = 1000
        
        /// Bulletins with this level appear over the status bar & alerts, but under keyboards.
        case alert = 2000
        
        /// Bulletins with this level appear over the status bar, alerts, & any visible keyboards.
        case keyboard = 20000000
        
    }
    
    /**
     Enum representing a bulletin's on-screen duration.
     */
    public enum Duration {
        
        /// Bulletins with this duration will never be dismissed automatically.
        case forever
        
        /// Bulletins with this duration will automatically be dismissed after a given delay.
        case limit(TimeInterval)
        
    }
    
    /**
     Enum representing a bulletin's on-screen position.
     */
    public enum Position {
        
        /// Bulletins with this position will be presented from the top of the screen.
        case top
        
        /// Bulletins with this position will be presented from the center of the screen.
        case center
        
        /// Bulletins with this position will be presented from the bottom of the screen.
        case bottom
        
    }
    
    /**
     The bulletin's identifier. This can be used to identify bulletins when many are being presented.
     */
    public var identifier: String?
    
    /**
     The bulletin's on-screen position.
     
     Defaults to `top`.
     */
    public var position: Position = .top
    
    /**
     The bulletin's on-screen duration.
     
     Defaults to `limit(5)`.
     */
    public var duration: Duration = .limit(5)
    
    /**
     The bulletin's window level.
     
     Defaults to `default`.
     */
    public var level: Level = .default
    
    /**
     The bulletin's info dictionary. This can be used to pass relevant information along with bulletins.
     */
    public var info: [String: Any]?
    
    /**
     The bulletin's action. If this is provided, tapping the bulletin will dismiss & call this action.
     */
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
    
    /**
     A sound file to be played when the bulletin is presented.
     */
    public var soundEffectUrl: URL? {
        didSet {
            
            guard let url = soundEffectUrl else {
                soundEffectPlayer = nil
                return
            }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
                soundEffectPlayer = try? AVAudioPlayer(contentsOf: url)
                soundEffectPlayer?.prepareToPlay()
            }
            catch let error {
                print("Error preloading sound (\(url.lastPathComponent): \(error.localizedDescription)")
            }
            
        }
    }
    
    /**
     The bulletin's presentation animation settings.
     */
    public private(set) var presentationAnimation = AnimationSettings()
    
    // TODO: Customizable dismissal animation
    // public private(set) var dismissalAnimation = AnimationSettings()
    
    /**
     The bulletin's style settings.
     */
    public private(set) var style = StyleSettings()
    
    /**
     The bulletin's taptic settings.
     */
    public private(set) var taptics = TapticSettings()
    
    /**
     The bulletin's appearance delegate. Provides various appearance information (i.e. `bulletinWillAppear()`, `bulletinWillDisappear()`, etc).
     */
    public weak var appearanceDelegate: BulletinViewAppearanceDelegate?
    internal weak var _delegate: BulletinViewDelegate?
    
    /**
     The bulletin's embedded content view.
     */
    public private(set) weak var view: UIView?
    internal var contentView: UIView!
    
    private var shadowLayer: CAShapeLayer!
    private var shadowMask: CAShapeLayer!
    
    private var tapRecognizer: UITapGestureRecognizer?
    
    public convenience init() {
        
        // Should use CGRect.zero, but for some reason not
        // setting an initial width/height results in a bad frame
        
        self.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
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
        shadowMask.fillRule = CAShapeLayerFillRule.evenOdd
        
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
    
    /**
     Embeds a content view into the bulletin.
     - parameter content: The content view to embed.
     - parameter height: An optional height for the content view. If no height is provided, the content view's intrinsic size will be used.
     */
    public func embed(content: UIView, usingStrictHeight height: CGFloat? = nil) {
        
        contentView.addSubview(content)
        content.snp.makeConstraints { (make) in
            
            make.edges.equalTo(0)
            
            if let height = height {
                make.height.equalTo(height)
            }
            
        }
        
        view = content
        
    }
    
    /**
     Presents the bulletin.
     - parameter delay: The ammount of time (in seconds) to delay the bulletin's presentation. Defaults to `0`.
     */
    public func present(after delay: TimeInterval = 0) {
        
        BulletinManager.shared.present(self, after: delay)
        
    }
    
    /**
     Dismisses the bulletin immediately.
     */
    public func dismiss() {
        
        BulletinManager.shared.dismiss(self)
        
    }
    
    // MARK: Private / Internal
    
    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        
        _delegate?.bulletinViewDidTap(self)
        
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
                    // Need an identity transform, translated by the current dx & dy
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
        
        // print("Pan translation: \(ty), velocity: \(velocity.y)")
        
        let touchScale: CGFloat = style.isAnimatedTouchEnabled ? 0.98 : 1
        
        switch recognizer.state {
        case .began: _delegate?.bulletinViewDidBeginPanning(self)
        case .changed:
            
            var yTransform: CGFloat
            
            if position == .top {
                yTransform = (ty <= 0) ? ty : (style.isStretchingEnabled ? (ty - (ty * 0.8)) : 0)
            }
            else {
                yTransform = (ty >= 0) ? ty : (style.isStretchingEnabled ? (ty - (ty * 0.8)) : 0)
            }
            
            self.transform = CGAffineTransform(translationX: 0, y: yTransform).scaledBy(x: touchScale, y: touchScale)
            
        case .ended: _delegate?.bulletinViewDidEndPanning(self, withTranslation: translation, velocity: velocity)
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
