//
//  NetworkOperation.swift
//  NetworkLayer
//
//  Created by Pablo Roca Rozas on 23/05/2016.
//  Copyright © 2016 Pablo Roca. All rights reserved.
//

import Foundation
import Alamofire

class NetworkOperation : ConcurrentOperation {
    
    // define properties to hold everything that you'll supply when you instantiate
    // this object and will be used when the request finally starts
    //
    // in this example, I'll keep track of (a) URL; and (b) closure to call when request is done
    
    let URLString: String
    let networkOperationCompletionHandler: (_ response: DataResponse<Any>) -> ()
    
    // we'll also keep track of the resulting request operation in case we need to cancel it later
    
    weak var request: Alamofire.Request?
    
    // define init method that captures all of the properties to be used when issuing the request
    
    init(URLString: String, networkOperationCompletionHandler: @escaping (_ response: DataResponse<Any>) -> ()) {
        self.URLString = URLString
        self.networkOperationCompletionHandler = networkOperationCompletionHandler
        super.init()
    }
    
    // when the operation actually starts, this is the method that will be called
    
    override func main() {
        
        request = Alamofire.request(URLString, method: .get, parameters: ["foo": "bar"])
            .responseJSON { response in
                // do whatever you want here; personally, I'll just all the completion handler that was passed to me in `init`
                
                self.networkOperationCompletionHandler(response)
                
                // now that I'm done, complete this operation
                
                debugPrint(response)
                self.completeOperation()
        }
        
    }
    // we'll also support canceling the request, in case we need it
    
    override func cancel() {
        request?.cancel()
        super.cancel()
    }
}
