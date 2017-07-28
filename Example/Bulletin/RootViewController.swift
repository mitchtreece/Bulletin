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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    fileprivate func bulletin(for row: BulletinRow) -> BulletinView {
        
        var bulletin: BulletinView!
                
        switch row {
        case .notification:
            
            let view = NotificationView()
            view.iconImageView.image = #imageLiteral(resourceName: "app_icon")
            view.iconTitleLabel.text = "REDDIT"
            view.timeLabel.text = "now"
            view.titleLabel.text = "Trending on r/Tech"
            view.messageLabel.text = "Elon Musk and his revolutionary quantum-teleporting Tesla Model 12."
            
            bulletin = BulletinView.notification()
            bulletin.style.roundedCornerRadius = 8
            bulletin.style.shadowRadius = 10
            bulletin.style.shadowAlpha = 0.3
            bulletin.embed(content: view)
                        
        case .banner:
            
            let view = BannerView()
            view.iconImageView.image = #imageLiteral(resourceName: "app_icon")
            view.titleLabel.text = "John Smith"
            view.timeLabel.text = "now"
            view.messageLabel.text = "Hey, do you want to grab lunch later? I have an early afternoon meeting, but after that I'm free! 🍔🌮🍕"
            
            bulletin = BulletinView.banner()
            bulletin.style.statusBar = .lightContent
            bulletin.embed(content: view)
            
        case .statusBar:
            
            let view = UILabel()
            view.backgroundColor = UIColor.white
            view.text = "Mmmmmm toasty."
            view.textAlignment = .center
            view.textColor = UIColor.black
            view.font = UIFont.boldSystemFont(ofSize: 10)
            
            bulletin = BulletinView.statusBar()
            bulletin.embed(content: view, usingStrictHeight: 20)
            
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
            
            bulletin = BulletinView.sheet()
            bulletin.style.verticalEdgeOffset = 14
            bulletin.style.horizontalEdgeOffset = 14
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0: return "Bulletins"
        case 1: return "Background Effects"
        default: return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return 6
        case 1: return 3
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
