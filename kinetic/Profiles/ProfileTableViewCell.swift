//
//  ProfileTableViewCell.swift
//  dataconnect
//
//  Created by hienng on 10/15/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class ProfileTableViewCell: MGSwipeTableCell {

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var serverName: UILabel!
    
    var cellData: Profile?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
