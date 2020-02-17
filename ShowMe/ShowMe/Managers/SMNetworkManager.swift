//
//  SMNetworkManager.swift
//  ShowMe
//
//  Created by Karthick Selvaraj on 11/01/20.
//  Copyright © 2020 Demo. All rights reserved.
//

import UIKit
import Alamofire

class SMNetworkManager: NSObject {
    
    private class func requestWithSuccessBlock(url: URL, httpMethod: HTTPMethod, parameter: [String: Any]?, encoding: ParameterEncoding?, headers: HTTPHeaders?, successblock: @escaping (_ withResponse: DataResponse<Any>?, _ successStatus: Bool?) -> Void, failureBlock: @escaping (_ withError: DataResponse<Any>?, _ cancelStatus: Bool) -> Void) -> Request? {
        return Alamofire.request(url, method: httpMethod, parameters: parameter, encoding: encoding!, headers: headers).validate().responseJSON { (response) in
            
            if response.result.isSuccess { // Success case
                successblock(response, true)
            } else { // Failure case
                if let error = response.result.error {
                    let nsError = error as NSError
                    if nsError.code == kRequestCancelStatusCode { // Request cancellation status code check.
                        failureBlock(response, true)
                        return
                    }
                }
                failureBlock(response, false)
            }
        }
    }
    
    // GET Method
    class func getRequestWithSucceccBlock(url: URL, parameter: [String: Any]?, successblock: @escaping (_ withResponse: DataResponse<Any>?, _ successStatus: Bool?) -> Void, failureBlock: @escaping (_ withError: DataResponse<Any>?, _ cancelStatus: Bool) -> Void) -> Request? {
        let request = requestWithSuccessBlock(url: url, httpMethod: .get, parameter: nil, encoding: JSONEncoding.default, headers: nil, successblock: successblock, failureBlock: failureBlock)
        return request
    }
    
}
