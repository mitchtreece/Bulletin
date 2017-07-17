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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    
    fileprivate func bulletin(for row: Row) -> BulletinView {
        
        var bulletin: BulletinView!
        
        switch row {
        case .notification:
            
            bulletin = BulletinView.notification()
            
            let view = UIView()
            view.backgroundColor = UIColor.red
            bulletin.contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
                make.height.equalTo(64)
            }
            
        case .banner:
            
            bulletin = BulletinView.banner()
            bulletin.style.statusBar = .lightContent
            
            let view = UIView()
            view.backgroundColor = UIColor.red
            bulletin.contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
                make.height.equalTo(64)
            }
            
        case .statusBar:
            
            bulletin = BulletinView.statusBar()
            bulletin.context = .overStatusBar
            
            let view = UIView()
            view.backgroundColor = UIColor.red
            bulletin.contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
                make.height.equalTo(20)
            }
            
        case .alert:
            
            bulletin = BulletinView.alert()
            
            let view = UIView()
            view.backgroundColor = UIColor.red
            bulletin.contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
                make.height.equalTo(120)
            }
            
        case .hud:
            
            bulletin = BulletinView.alert()
            
            let view = UIView()
            view.backgroundColor = UIColor.red
            bulletin.contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
                make.height.equalTo(120)
            }
            
        case .sheet:
            
            bulletin = BulletinView.sheet()
            
            let view = UIView()
            view.backgroundColor = UIColor.red
            bulletin.contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalTo(0)
                make.height.equalTo(200)
            }
            
        }
        
        return bulletin
        
    }
    
}

extension RootViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Row: Int {
        case notification
        case banner
        case statusBar
        case alert
        case hud
        case sheet
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let row = Row(rawValue: indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }
        
        let bulletin = self.bulletin(for: row)
        bulletin.present()
        
    }
    
}
