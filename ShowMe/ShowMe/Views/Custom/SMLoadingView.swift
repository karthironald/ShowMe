//
//  SMLoadingView.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 12/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit

class SMLoadingView: SMView {
    
    @IBOutlet weak private var searchLabel: SMLabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var titleLabel: SMLabel!
    
    
    // MARK: Custom methods
    
    /**Show searching label and activity indicator view.*/
    func showLoading() {
        searchLabel.isHidden = false
        activityIndicator.isHidden = false
        titleLabel.isHidden = true
    }
    
    /**Hide searching label and activity indicator view and shows title*/
    func hideLoading() {
        searchLabel.isHidden = true
        activityIndicator.isHidden = true
        titleLabel.isHidden = false
    }
    
}
