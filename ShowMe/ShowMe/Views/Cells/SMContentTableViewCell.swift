//
//  SMContentTableViewCell.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 11/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit

class SMContentTableViewCell: SMTableViewCell {

    @IBOutlet weak private var titleLabel: SMLabel!
    @IBOutlet weak private var yearLabel: SMLabel!
    @IBOutlet weak private var posterImageView: SMImageView!
    
    
    // MARK: - Initializer method
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // MARK: Custom methods
    
    /**Updates the cell with content details*/
    func updateCell(with content: SMContent?) {
        if let content = content {
            titleLabel.text = content.title ?? kDefaultValue
            yearLabel.text = content.year ?? kDefaultValue
            
            if let posterUrlString = content.poster, let posterUrl = URL(string: posterUrlString) {
                posterImageView.setImage(withURL: posterUrl, placeholderText: nil, placeHolderImage: UIImage(named: "default-poster"), imageFilter: nil, circular: true, successBlock: { (_) in
                    // Do nothing
                }) { (_) in
                    // Do nothing
                }
            }
        }
    }
    
}
