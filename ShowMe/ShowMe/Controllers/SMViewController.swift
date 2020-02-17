//
//  SMViewController.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 11/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit

class SMViewController: UIViewController {

    
    // MARK: - View lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(networkConnectedViaLANorWIFI), name: NSNotification.Name(rawValue: kNetworkConnectedViaLANorWIFI), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNetworkConnectedViaLANorWIFI), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        super.viewWillDisappear(animated)
    }
    
    
    // MARK: - Custom methods
    
    @objc func networkConnectedViaLANorWIFI() {
        // Dummy implementation. Override this method in viewcontrollers to procees things when app connects to online from offline
    }

    @objc func appWillEnterForeground() {
        // Dummy implementation. Override this method in viewcontrollers to procees things when app enters foreground
    }
    
}
