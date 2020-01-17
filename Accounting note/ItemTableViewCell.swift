//
//  ItemTableViewCell.swift
//  Accounting note
//
//  Created by tautau on 2018/8/22.
//  Copyright © 2018年 tautau. All rights reserved.
//

import UIKit
import SwipeCellKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet var itemType: UILabel!
    @IBOutlet var itemSpend: UILabel!
    @IBOutlet var cellImageView: UIImageView!
    
    override func awakeFromNib() {
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
