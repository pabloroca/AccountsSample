//
//  PR2NetworkingExtensions.swift
//  NetworkLayer
//
//  Created by Pablo Roca Rozas on 20/05/2016.
//  Copyright © 2016 Pablo Roca. All rights reserved.
//

import Foundation
import Alamofire

public enum PR2NetworkTaskStatus {
    case statusPendingToStart, statusRunning, statusSuspended, statusCancelled
}

class PR2NetworkTask: ConcurrentOperation {
    var id: String
    var method: HTTPMethod
    var url: String
    var params: [String:AnyObject]?
    var headers: [String:String]?
    var status: PR2NetworkTaskStatus
    var accDelay: Double
    var pollforUTC: Double
    
    weak var request: Alamofire.Request?
    
    let networkOperationCompletionHandler: (_ success: Bool, _ response: DataResponse<Any>) -> ()
    
    init(method: String = "GET", url: String, params: [String:String]? = nil, headers: [String:String]? = nil, priority: Operation.QueuePriority = Operation.QueuePriority.normal, pollforUTC: Double = 0, networkOperationCompletionHandler: @escaping (_ success: Bool, _ response: DataResponse<Any>) -> ()) {
        
        self.id = UUID().uuidString
        self.method = HTTPMethod(rawValue: method)!
        self.url = url
        self.status = PR2NetworkTaskStatus.statusPendingToStart
        self.accDelay = 0.0
        self.pollforUTC = pollforUTC
        self.networkOperationCompletionHandler = networkOperationCompletionHandler
        
        super.init()
        
        self.queuePriority = priority
        
        switch self.queuePriority {
        case .veryHigh:
            self.qualityOfService = .userInteractive
        case .high:
            self.qualityOfService = .userInitiated
        case .low:
            self.qualityOfService = .utility
        case .veryLow:
            self.qualityOfService = .background
        default:
            self.qualityOfService = .utility
        }
    }
    
    override internal func main() {
        if self.isCancelled {
            return
        }
        
        NSLog("start %@",self.url)
        
        PR2Common().showNetworkActivityinStatusBar()
        PR2Networking.sharedInstance.request(self.accDelay, method: self.method, urlString: self.url, parameters: self.params, encoding: URLEncoding.default, headers: self.headers) { (success, response) in
            NSLog("end %@",self.url)
            self.networkOperationCompletionHandler(success, response)
            PR2Common().hideNetworkActivityinStatusBar()
            self.completeOperation()
        }
        
    }
    
    override internal func cancel() {
        self.status = PR2NetworkTaskStatus.statusCancelled
        request?.cancel()
        super.cancel()
    }
    
}


