//
//  Bulletin+SnapKit.swift
//  Bulletin
//
//  Created by Mitch Treece on 7/18/17.
//  Copyright © 2017 Mitch Treece. All rights reserved.
//

import Foundation
import SnapKit

public extension BulletinView {
    
    /**
     Embeds a content view into the bulletin.
     - parameter content: The content view to embed.
     - parameter constraint: The height constraint to use.
     */
    func snp_embed(content: UIView, usingStrictHeightConstraint constraint: ConstraintItem) {
        
        contentView.addSubview(content)
        content.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.height.equalTo(constraint)
        }
        
    }
    
}
