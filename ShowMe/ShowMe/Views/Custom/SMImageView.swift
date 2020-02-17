//
//  SMImageView.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 11/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class SMImageView: UIImageView {
    
    
    // MARK: - Initializer methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customize()
    }
    
    
    // MARK: - Custom methods
    
    @objc func customize() {
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    /**Download and set image in imageview*/
    func setImage(withURL url: URL, placeholderText: String? = nil, placeHolderImage: UIImage?, imageFilter: ImageFilter?, circular: Bool? = false, successBlock: ((DataResponse<UIImage>) -> Void)?, failureBlock: ((DataResponse<UIImage>) -> Void)?) {
        
        self.af_setImage(withURL: url, placeholderImage: placeHolderImage, filter: imageFilter, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .noTransition, runImageTransitionIfCached: true) { (response) in
           
            if response.result.isSuccess {
                successBlock!(response)
            } else if response.result.isFailure {
                failureBlock!(response)
            }
            
        }
        
    }
    
}
