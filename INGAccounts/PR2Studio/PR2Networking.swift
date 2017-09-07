//
//  PR2Networking.swift
//
//  Created by Pablo Roca Rozas on 22/01/2016.
//  Copyright © 2016 PR2Studio. All rights reserved.
//

import Foundation
import Alamofire

/// Networking log levels
public enum PR2NetworkingLogLevel {
    /// PR2Networking log disabled
    case pr2NetworkingLogLevelOff
    /// PR2Networking log in debug mode
    case pr2NetworkingLogLevelDebug
    /// PR2Networking log with short info
    case pr2NetworkingLogLevelInfo
    /// PR2Networking log when errors
    case pr2NetworkingLogLevelError
}

/// HTTP error codes
struct PR2HTTPCode {
    // Success
    /// HTTP 200 OK
    static let c200OK = 200
    
    /// HTTP Error 304 Redirection
    static let c304NotModified = 304
    
    // Client error
    /// HTTP Error 400 Bad request
    static let c400BadRequest = 400
    /// HTTP Error 401 Unauthorised
    static let c401Unauthorised = 401
    /// HTTP Error 404 Not found
    static let c404NotFound = 404
    /// HTTP Error 405 Method not allowed
    static let c405MethodNotAllowed = 405
    
    // Server error
    /// HTTP Error 500 Internsal server error
    static let c500InternalServerError = 500
}

/// Slow Internet Notification
public struct PR2NetworkingNotifications {
    /// slow internet
    public static let slowInternet = "com.pr2studio.notifications.SlowInternet"
}

/// Main network request class (wrapper of Alamofire request)
open class PR2Networking {
    /// it converts itself as a singleton
    open static let sharedInstance = PR2Networking()
    
    /// Networking log levels
    open var logLevel: PR2NetworkingLogLevel = .pr2NetworkingLogLevelOff
    
    
    var tasks: [PR2NetworkTask] = []
    
    lazy var downloadsInProgress = [IndexPath:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        //      queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount
        //      queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
    /// initial retry delay
    let retryDelay: Double = 1.0  // in seconds
    
    /// seconds to trigger slow internet notification
    let secondsToShowSlowConnection: Double = 3
    /// timer for slow internet
    var timerRequest = Timer()
    
    /// alamofire manager
    var manager: Alamofire.SessionManager?
    /// alamofire reachability
    #if os(iOS)
    var managerReachability: NetworkReachabilityManager?
    #endif
    
    /// This private prevents others from using the default '()' initializer for this class.
    fileprivate init() {
        var defaultHeaders = Alamofire.SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
        defaultHeaders["User-Agent"] = self.userAgent()
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        //cache disabled completely
        configuration.urlCache = nil
        self.manager = Alamofire.SessionManager(configuration: configuration)
        
    }
    
    //   public struct PR2NetworkTask {
    //      var id: String
    //      var method: String
    //      var url: String
    //      var params: [String:String]
    //      var headers: [String:String]
    //      var priority: Int
    //      var status: Int
    //      var accDelay: Int
    //      var pollforUTC: Double
    //   }
    
    
    func addTask(_ task: PR2NetworkTask) {
        let mytask = task
        mytask.status = PR2NetworkTaskStatus.statusRunning
        self.tasks.append(mytask)
        
        self.downloadQueue.addOperation(mytask)
        
        print("task added %@",mytask.url)
    }
    
    func addTaskAfterLast(_ task: PR2NetworkTask) {
        let mytask = task
        mytask.status = PR2NetworkTaskStatus.statusRunning
        self.tasks.append(mytask)
        
        self.downloadQueue.addOperationAfterLast(mytask)
        
        print("task added %@",mytask.url)
    }
    
    
    // MARK: - request methods
    
    /// request: Recursive Request till delay > 30 seconds
    ///  - parameter delay:      Acumulated delay
    ///  - parameter method:     The HTTP method.
    ///  - parameter urlString:  The URL string.
    ///  - parameter parameters: The parameters. nil by default.
    ///  - parameter encoding:   The parameter encoding. .URL by default.
    ///  - parameter headers:    The HTTP headers. nil by default.
    ///  - parameter completionHandler:    Completion handler.
    open func request(
        _ delay: Double,
        method: HTTPMethod,
        urlString: String,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String]? = nil,
        completionHandler: @escaping (_ success: Bool, _ response: DataResponse<Any>) -> Void) {
        willStartRequest(method, urlString, parameters: parameters, encoding: encoding, headers: headers)
        
        Alamofire.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                var statusCode: Int = 0
                if let httpError = response.result.error {
                    statusCode = httpError._code
                } else { //no errors
                    statusCode = (response.response?.statusCode)!
                }
                //                let cachedURLResponse = NSCachedURLResponse(response: response.response!, data: response.data!, userInfo: nil, storagePolicy: .Allowed)
                //                NSURLCache.sharedURLCache().storeCachedResponse(cachedURLResponse, forRequest: response.request!)
                
                // success
                if (response.result.error == nil && statusCode == PR2HTTPCode.c200OK) {
                    strongSelf.didFinishRequest(true, response)
                    completionHandler(true, response)
                } else {
                    // don't repeat the network call if error not temporary
                    let error = response.result.error as! AFError
                    if (response.result.error != nil && strongSelf.shouldCancelRequestbyError(error)) {
                        strongSelf.didFinishRequest(false, response)
                        completionHandler(false, response)
                    } else {
                        // posibble not having internet, we wait for reachability
                        if (response.result.error != nil &&
                            (response.response?.statusCode == NSURLErrorNotConnectedToInternet ||
                                response.response?.statusCode == NSURLErrorTimedOut ||
                                response.response?.statusCode == NSURLErrorCannotFindHost ||
                                response.response?.statusCode == NSURLErrorCannotConnectToHost)
                            ) {
                            let host = response.request!.url!.host
                            #if os(iOS)
                            strongSelf.managerReachability = NetworkReachabilityManager(host: host!)
                            strongSelf.managerReachability!.listener = { status in
                                // is again reachable? we make the request again
                                if (strongSelf.managerReachability!.isReachable) {
                                    strongSelf.managerReachability!.stopListening()
                                    strongSelf.didFinishRequest(false, response)
                                    strongSelf.request(delay, method: method, urlString: urlString, completionHandler: { (success, response) -> Void in
                                        completionHandler(success, response)
                                    })
                                }
                            }
                            
                            strongSelf.managerReachability!.startListening()
                            #endif
                        } else {
                            strongSelf.didFinishRequest(false, response)
                            // failure then we retry request
                            let newretryDelay = delay + 1
                            if newretryDelay > 30 {
                                completionHandler(false, response)
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(newretryDelay))) {
                                    strongSelf.request(newretryDelay, method: method, urlString: urlString, completionHandler: { (success, response) -> Void in
                                        completionHandler(success, response)
                                    })
                                }
                            }
                        }
                    }
                }
        }
    }
    
    
    // MARK: - start and finish request common functions
    
    /// willStartRequest: Executed before any request (activity indicator & console logger)
    /// - parameter method:     The HTTP method.
    /// - parameter uRLString:  The URL string.
    /// - parameter parameters: The parameters. nil by default.
    /// - parameter encoding:   The parameter encoding. .URL by default.
    /// - parameter headers:    The HTTP headers. nil by default.
    fileprivate func willStartRequest(
        _ method: HTTPMethod,
        _ uRLString: String,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String]? = nil
        ) {
        self.timerRequest = Timer.scheduledTimer(timeInterval: self.secondsToShowSlowConnection, target: self, selector: #selector(self.timerRequestReached), userInfo: nil, repeats: false)
        
        PR2Common().showNetworkActivityinStatusBar()
        
        /// network console logger
        let dateString  = Date().PR2DateFormatterForLog()
        
        switch self.logLevel {
        case .pr2NetworkingLogLevelOff, .pr2NetworkingLogLevelError:
            break
        case .pr2NetworkingLogLevelDebug:
            
            // headers
            var dictDefaultHeaders: Dictionary = self.manager!.session.configuration.httpAdditionalHeaders!
            // adds custom headers to default headers
            if let myHeaders = headers {
                for (key, value) in myHeaders {
                    dictDefaultHeaders.updateValue(value, forKey:key)
                }
            }
            // prepare dictDefaultHeaders for printing
            var stringDefaultHeaders = ""
            for (key, value) in dictDefaultHeaders {
                stringDefaultHeaders += "\(key): \(value)\n"
            }
            let index1 = stringDefaultHeaders.characters.index(stringDefaultHeaders.endIndex, offsetBy: -1)
            stringDefaultHeaders = stringDefaultHeaders.substring(to: index1)
            
            // parameters
            var stringParameters = ""
            if let myParameters = parameters {
                for (key, value) in myParameters {
                    stringParameters += "\(key): \(value)\n"
                }
                let index1 = stringParameters.characters.index(stringParameters.endIndex, offsetBy: -1)
                stringParameters = stringParameters.substring(to: index1)
            }
            
            let logmessage = "\(dateString) \(method) \(uRLString)\n[Headers]\n\(stringDefaultHeaders)\n[Body]\(stringParameters)"
            print(logmessage)
        case .pr2NetworkingLogLevelInfo:
            let logmessage = "\(dateString) \(method) \(uRLString)"
            print(logmessage)
        }
    }
    
    /// didFinishRequest: Executed after any request (activity indicator & console logger)
    ///   - parameter success:    The request was succesfull?
    ///   - parameter response:   The response object
    ///   - parameter statuscode: statuscode of the request
    fileprivate func didFinishRequest(_ success: Bool, _ response: DataResponse<Any>) {
        self.timerRequest.invalidate()
        
        PR2Common().hideNetworkActivityinStatusBar()
        
        // network console logger
        var statusCode: Int = 0
        if let httpError = response.result.error {
            statusCode = httpError._code
        } else { //no errors
            statusCode = (response.response?.statusCode)!
        }
        
        let dateString  = Date().PR2DateFormatterForLog()
        
        switch self.logLevel {
        case .pr2NetworkingLogLevelOff:
            break
        case .pr2NetworkingLogLevelDebug:
            var dictResponseHeaders: NSDictionary? = nil
            if let httpResponse = response.response {
                dictResponseHeaders = httpResponse.allHeaderFields as NSDictionary
                // prepare dictDefaultHeaders for printing
                var stringResponseHeaders = ""
                for (key, value) in dictResponseHeaders! {
                    stringResponseHeaders += "\(key): \(value)\n"
                }
                let index1 = stringResponseHeaders.characters.index(stringResponseHeaders.endIndex, offsetBy: -1)
                stringResponseHeaders = stringResponseHeaders.substring(to: index1)
            }
            
            var logmessage: String = ""
            if response.result.error != nil {
                if let _ = response.result.value {
                    logmessage = "\(dateString) [Error] \(String(describing: response.response?.statusCode)) \(String(describing: response.request!.url))\n[Response Headers]\n\(dictResponseHeaders!)\n[Response Body]\n\(response.result.value!)"
                } else {
                    logmessage = "\(dateString) [Error] \(String(describing: response.response?.statusCode)) \(String(describing: response.request!.url))\n[Response Headers]\n[Response Body]\n"
                }
            } else {
                logmessage = "\(dateString) \(statusCode) \(String(describing: response.request!.url))\n[Response Headers]\n\(dictResponseHeaders!)\n[Response Body]\n\(response.result.value!)"
            }
            
            print(logmessage)
        case .pr2NetworkingLogLevelInfo, .pr2NetworkingLogLevelError:
            var logmessage: String = ""
            if response.result.error != nil {
                logmessage = "\(dateString) [Error] \(String(describing: response.response?.statusCode)) \(String(describing: response.request!.url))"
            } else {
                logmessage = "\(dateString) \(statusCode) \(String(describing: response.request!.url))"
            }
            
            print(logmessage)
        }
    }
    
    // MARK: - Timer (slow internet) method
    
    /**
     Slow internet reached
     */
    dynamic func timerRequestReached() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: PR2NetworkingNotifications.slowInternet), object: nil)
    }
    
    // MARK: - misc functions
    
    /// userAgent: Generates user agent from Info.plist
    /// example: SkyPablo:1.0.1/IOS:9.2/x86_64
    /// - returns: String
    open func userAgent() -> String {
        var userAgent: String = "Unknown"
        if let info = Bundle.main.infoDictionary {
            let executable: AnyObject = info[kCFBundleExecutableKey as String] as AnyObject
            let version: AnyObject = info[kCFBundleVersionKey as String] as AnyObject
            let osmajor: AnyObject = ProcessInfo.processInfo.operatingSystemVersion.majorVersion as AnyObject
            let osminor: AnyObject = ProcessInfo.processInfo.operatingSystemVersion.minorVersion as AnyObject
            let model: AnyObject = hardwareString() as AnyObject
            
            userAgent = NSMutableString(string: "\(executable):\(version)/IOS:\(osmajor).\(osminor)/\(model)") as String
            
        }
        return userAgent
    }
    
    /// hardwareString: Generates phone model (hardware)
    /// - returns: String
    fileprivate func hardwareString() -> String {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, &name, 0)
        var hw_machine = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hw_machine, &size, &name, 0)
        
        let hardware: String = String(cString: hw_machine)
        return hardware
    }
    
    /// shouldCancelRequestbyError: if the request error non temporary then we fail and cancel any further request
    /// - parameter error: Error received by the request
    /// - returns: Bool
    fileprivate func shouldCancelRequestbyError(_ error: Error) -> Bool {
        if ((error._domain == "NSURLErrorDomain" && (
            error._code == NSURLErrorCancelled ||
                error._code == NSURLErrorBadURL ||
                error._code == NSURLErrorUnsupportedURL ||
                error._code == NSURLErrorDataLengthExceedsMaximum ||
                error._code == NSURLErrorHTTPTooManyRedirects ||
                error._code == NSURLErrorUserCancelledAuthentication ||
                error._code == NSURLErrorRequestBodyStreamExhausted ||
                error._code == NSURLErrorAppTransportSecurityRequiresSecureConnection ||
                error._code == NSURLErrorFileDoesNotExist ||
                error._code == NSURLErrorFileIsDirectory ||
                error._code == NSURLErrorNoPermissionsToReadFile ||
                error._code == NSURLErrorSecureConnectionFailed ||
                error._code == NSURLErrorServerCertificateHasBadDate ||
                error._code == NSURLErrorServerCertificateUntrusted ||
                error._code == NSURLErrorServerCertificateHasUnknownRoot ||
                error._code == NSURLErrorServerCertificateNotYetValid ||
                error._code == NSURLErrorClientCertificateRejected ||
                error._code == NSURLErrorClientCertificateRequired ||
                error._code == NSURLErrorCannotCreateFile ||
                error._code == NSURLErrorCannotOpenFile ||
                error._code == NSURLErrorCannotCloseFile ||
                error._code == NSURLErrorCannotWriteToFile ||
                error._code == NSURLErrorCannotRemoveFile ||
                error._code == NSURLErrorCannotMoveFile))
            ||
            (error._domain == "NSCocoaErrorDomain" && (
                error._code == 3840))
            ) {
            return true
        } else {
            return false
        }
    }
}
