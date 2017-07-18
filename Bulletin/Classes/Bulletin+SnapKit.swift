//
//  Bulletin+SnapKit.swift
//  Bulletin
//
//  Created by Mitch Treece on 7/18/17.
//

import Foundation
import SnapKit

public extension BulletinView {
    
    /**
     Embeds a content view into the bulletin using a `ConstraintItem` for it's height.
     */
    public func snp_embed(content: UIView, usingStrictHeightConstraint constraint: ConstraintItem) {
        
        contentView.addSubview(content)
        content.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.height.equalTo(constraint)
        }
        
    }
    
}
