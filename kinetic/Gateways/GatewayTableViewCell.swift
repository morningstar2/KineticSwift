//
//  GatewayTableViewCell.swift
//  dataconnect
//
//  Created by hienng on 10/16/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit

class GatewayTableViewCell: UITableViewCell {

    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var gatewayHealth: UILabel!
    @IBOutlet weak var gatewayName: UILabel!
    @IBOutlet weak var serialNumber: UILabel!
    @IBOutlet weak var model: UILabel!
    @IBOutlet weak var swVersion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
