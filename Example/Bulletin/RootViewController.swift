//
//  RootViewController.swift
//  Bulletin_Example
//
//  Created by Mitch Treece on 7/17/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import Bulletin

class RootViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var bulletin: BulletinView?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    fileprivate func bulletin(for row: BulletinRow) -> BulletinView {
        
        var bulletin: BulletinView!
                
        switch row {
        case .notification:
            
            let view = NotificationView()
            view.iconImageView.image = #imageLiteral(resourceName: "app_icon")
            view.iconTitleLabel.text = "BULLETIN"
            view.timeLabel.text = "now"
            view.titleLabel.text = "Trending News"
            view.messageLabel.text = "Elon Musk and his revolutionary quantum-teleporting Tesla Model 12"
            
            bulletin = BulletinView.notification()
            bulletin.style.roundedCornerRadius = UIDevice.current.isPhoneX ? 18 : 8
            bulletin.style.shadowRadius = 10
            bulletin.style.shadowAlpha = 0.3
            bulletin.embed(content: view)
                        
        case .banner:
            
            let view = BannerView()
            view.iconImageView.image = #imageLiteral(resourceName: "app_icon")
            view.titleLabel.text = "The Dude"
            view.timeLabel.text = "now"
            view.messageLabel.text = "I’m the Dude, so that’s what you call me. That or, uh His Dudeness, or uh Duder, or El Duderino, if you’re not into the whole brevity thing. 😎"
            
            bulletin = BulletinView.banner()
            bulletin.style.statusBar = .lightContent
            bulletin.embed(content: view)
            
        case .statusBar:
            
            var view: UIView!
            
            if !UIDevice.current.isPhoneX {
                
                view = UILabel()
                view.backgroundColor = UIColor.groupTableViewBackground
                (view as! UILabel).text = "Mmmmmm toasty."
                (view as! UILabel).textAlignment = .center
                (view as! UILabel).textColor = UIColor.black
                (view as! UILabel).font = UIFont.boldSystemFont(ofSize: 10)
                
            }
            else {
                
                view = UIView()
                view.backgroundColor = UIColor.groupTableViewBackground
                
                let labelWidth = ((UIScreen.main.bounds.width - (UIScreen.main.topNotch?.size.width ?? 0)) / 2)
                
                let leftLabel = UILabel()
                leftLabel.backgroundColor = UIColor.clear
                leftLabel.text = "😍"
                leftLabel.textAlignment = .center
                leftLabel.textColor = UIColor.black
                leftLabel.font = UIFont.boldSystemFont(ofSize: 24)
                view.addSubview(leftLabel)
                leftLabel.snp.makeConstraints { (make) in
                    make.left.top.bottom.equalTo(0)
                    make.width.equalTo(labelWidth)
                }
                
                let rightLabel = UILabel()
                rightLabel.backgroundColor = UIColor.clear
                rightLabel.text = "😘"
                rightLabel.textAlignment = .center
                rightLabel.textColor = UIColor.black
                rightLabel.font = UIFont.boldSystemFont(ofSize: 24)
                view.addSubview(rightLabel)
                rightLabel.snp.makeConstraints { (make) in
                    make.right.top.bottom.equalTo(0)
                    make.width.equalTo(labelWidth)
                }
                
            }

            bulletin = BulletinView.statusBar()
            bulletin.embed(content: view, usingStrictHeight: UIApplication.shared.statusBarFrame.height)
            
        case .alert:
            
            let view = AlertView()
            view.titleLabel.text = "Alert"
            view.messageLabel.text = "This is an alert. It's a little boring, but it gets the job done. 😴"
            view.button.setTitle("Okay", for: .normal)
            view.delegate = self
            
            bulletin = BulletinView.alert()
            bulletin.style.isBackgroundDismissEnabled = false
            bulletin.embed(content: view)
            
        case .hud:
            
            let view = HudView()
            bulletin = BulletinView.hud()
            bulletin.duration = .limit(2)
            bulletin.snp_embed(content: view, usingStrictHeightConstraint: view.snp.width)
            
        case .sheet:
            
            let view = SheetView()
            view.delegate = self
            
            let bottomInset = (UIScreen.main.bottomGrabber != nil) ? (UIScreen.main.bottomGrabber!.height + 4) : 8
            
            bulletin = BulletinView.sheet()
            bulletin.style.edgeInsets = UIEdgeInsets(horizontal: 8, vertical: bottomInset)
            bulletin.style.shadowAlpha = 0
            bulletin.embed(content: view)
            
        }
        
        return bulletin
        
    }
    
}

extension RootViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum BulletinRow: Int {
        case notification
        case banner
        case statusBar
        case alert
        case hud
        case sheet
    }
    
    enum BackgroundEffectRow: Int {
        case none
        case darken
        case blur
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0: return "Bulletins"
        case 1: return "Background Effects"
        case 2: return "Other"
        default: return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return 6
        case 1: return 3
        case 2: return 1
        default: return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            guard let row = BulletinRow(rawValue: indexPath.row) else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            cell?.accessoryType = .disclosureIndicator
            
            switch row {
            case .notification: cell?.textLabel?.text = "Notification"
            case .banner: cell?.textLabel?.text = "Banner"
            case .statusBar: cell?.textLabel?.text = "Toast"
            case .alert: cell?.textLabel?.text = "Alert"
            case .hud: cell?.textLabel?.text = "HUD"
            case .sheet: cell?.textLabel?.text = "Sheet"
            }
            
            return cell ?? UITableViewCell()
            
        }
        else if indexPath.section == 1 {
            
            guard let row = BackgroundEffectRow(rawValue: indexPath.row) else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            cell?.accessoryType = .disclosureIndicator
            
            switch row {
            case .none: cell?.textLabel?.text = "None"
            case .darken: cell?.textLabel?.text = "Darken"
            case .blur: cell?.textLabel?.text = "Blur"
            }
            
            return cell ?? UITableViewCell()
            
        }
        else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            cell?.textLabel?.text = "Objective-C"
            cell?.accessoryType = .disclosureIndicator
            return cell ?? UITableViewCell()
            
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
        
            guard let row = BulletinRow(rawValue: indexPath.row) else { return }
            
            let bulletin = self.bulletin(for: row)
            self.bulletin = bulletin
            bulletin.present()
            
        }
        else if indexPath.section == 1 {
            
            guard let row = BackgroundEffectRow(rawValue: indexPath.row) else { return }
            
            switch row {
            case .none:
                
                let bulletin = self.bulletin(for: .notification)
                self.bulletin = bulletin
                bulletin.present()
            
            case .darken:
                
                let bulletin = self.bulletin(for: .alert)
                bulletin.style.backgroundEffect = .darken(alpha: 0.7)
                self.bulletin = bulletin
                bulletin.present()
                
            case .blur:
                
                let bulletin = self.bulletin(for: .sheet)
                bulletin.style.backgroundEffect = .blur(style: .dark)
                self.bulletin = bulletin
                bulletin.present()
                
            }
            
        }
        else if indexPath.section == 2 {
            
            let vc = ObjcViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
}

extension RootViewController: AlertViewDelegate {
    
    func alertViewDidTapButton(_ alert: AlertView) {
        
        bulletin?.dismiss()
        bulletin = nil
        
    }
    
}

extension RootViewController: SheetViewDelegate {
    
    func sheetViewDidTapButton(_ sheet: SheetView) {
        
        bulletin?.dismiss()
        bulletin = nil
        
    }
    
}
