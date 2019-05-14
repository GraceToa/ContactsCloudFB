//
//  UserTableViewCell.swift
//  CrudCloudFirestore
//
//  Created by GraceToa on 07/05/2019.
//  Copyright © 2019 GraceToa. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var nameCell: UILabel!
    @IBOutlet weak var emailCell: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
