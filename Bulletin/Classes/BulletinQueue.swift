//
//  BulletinQueue.swift
//  Bulletin
//
//  Created by Mitch Treece on 1/9/18.
//

import Foundation

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
        
        func debugLog(for bulletin: BulletinView, index: Int) {
            // print("BulletinQueue - Added bulletin at index: \(index), queue: \(self)")
        }
        
        guard bulletin.priority != .required else {
            
            let _bulletin = pop()
            bulletins.append(bulletin)
            debugLog(for: bulletin, index: (bulletins.count - 1))
            return _bulletin
            
        }
        
        guard !bulletins.isEmpty else {
            
            bulletins.append(bulletin)
            debugLog(for: bulletin, index: 0)
            return nil
            
        }
        
        var index: Int = 0
        var poppedBulletin: BulletinView?
        
        if let _bulletin = bulletins.first(where: { $0.priority == bulletin.priority }),
            let idx = bulletins.index(of: _bulletin) {
            
            // Find the first item in the queue with an equal priority.
            // We want our new item to be inserted as the first
            // item at a given priority level.
            //
            // --------------------- ↓ ------
            // [L, H, R] + (H) = [L, H, H, R]
            
            index = idx
            bulletins.insert(bulletin, at: idx)
            
        }
        else if let _bulletin = bulletins.first(where: { $0.priority.rawValue > bulletin.priority.rawValue }),
            let idx = bulletins.index(of: _bulletin) {
            
            // Find the first item in the queue with a greater priority.
            // We want our new item to be inserted before this higher-priority item.
            //
            // ------------------ ↓ ---------
            // [H, H, R] + (L) = [L, H, H, R]
            
            index = idx
            bulletins.insert(bulletin, at: idx)
            
        }
        else {
            
            // There are no equal or greater priority items in the queue.
            // We can just append the new item to the end.
            //
            // NOTE: This will pop the top (showing) item off the queue.
            //
            // ------------ ↓
            // [L] + (H) = [H]
            
            poppedBulletin = pop()
            index = bulletins.count
            bulletins.append(bulletin)
            
        }
        
        debugLog(for: bulletin, index: index)
        return poppedBulletin
        
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
            case .high: string += "H, "
            case .required: string += "R, "
            }
            
        }
        
        let index = string.index(string.endIndex, offsetBy: -2)
        string = String(string[..<index])
        
        return "<BulletinQueue: \(bulletins.count) element(s), [\(string)]>"
        
    }
    
    var debugDescription: String {
        return description
    }
    
}
