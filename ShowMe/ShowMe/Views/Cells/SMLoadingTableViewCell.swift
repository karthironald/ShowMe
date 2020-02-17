//
//  SMLoadingTableViewCell.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 12/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit

class SMLoadingTableViewCell: SMTableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    // MARK: - Initializer method
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
