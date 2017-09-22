//
//  PR2Common.swift
//
//  Created by Pablo Roca Rozas on 24/1/16.
//  Copyright © 2016 PR2Studio. All rights reserved.
//

// Common functions for any project

import Foundation
import UIKit

#if os(iOS)
import CoreTelephony
#endif

extension String {
    func PR2trimLeadingZeroes() -> String {
        var result = ""
        for character in self.characters {
            if result.isEmpty && character == "0" { continue }
            result.append(character)
        }
        return result
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    // generate DJB hash
    var djb2hash: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) {
            ($0 << 5) &+ $0 &+ Int($1)
        }
    }
    
    func asIban() -> String {
        let paddedString = self.padding(toLength: 32, withPad: " ", startingAt: 0)
        
        let part1 = paddedString.substring(with: 0..<2)
        let part2 = paddedString.substring(with: 2..<4)
        let part3 = paddedString.substring(with: 4..<8)
        let part4 = paddedString.substring(with: 8..<12)
        let part5 = paddedString.substring(with: 12..<16)
        let part6 = paddedString.substring(with: 16..<20)
        let part7 = paddedString.substring(with: 20..<24)
        let part8 = paddedString.substring(with: 24..<28)
        let part9 = paddedString.substring(with: 28..<32)
        
        let formattedString = String(format: "%@%@ %@ %@ %@ %@ %@ %@ %@", part1.uppercased() , part2, part3, part4, part5, part6, part7, part8, part9)
        
        let trimmedString = formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return trimmedString
    }
    
}

extension NSAttributedString {
    
    public static func balanceText(balanceString: String, currency: String, balanceFont: UIFont, currencyFont: UIFont, currencyBaselineOffset: Float, suffix: String? = nil, currencyColor: UIColor? = nil, balanceColor: UIColor? = nil) -> NSAttributedString {
        
        let totalString: NSString = {
            if let suffix = suffix {
                return "\(balanceString) \(currency) \(suffix)" as NSString
            } else {
                return "\(balanceString) \(currency)" as NSString
            }
        }()
        
        let attributedString = NSMutableAttributedString(string: totalString as String, attributes: [NSFontAttributeName: balanceFont, NSBaselineOffsetAttributeName: 0])
        attributedString.addAttributes([NSFontAttributeName: currencyFont, NSBaselineOffsetAttributeName: currencyBaselineOffset], range: totalString.range(of: currency))
        
        if let currencyColor = currencyColor, let balanceColor = balanceColor {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: balanceColor, range: totalString.range(of: balanceString))
            attributedString.addAttribute(NSForegroundColorAttributeName, value: currencyColor, range: totalString.range(of: currency))
        }
        
        return attributedString
    }
}


/// Commom functions for any project
public class PR2Common {
    
    public init() { }
    
    /**
     Displays network activity indicator in status bar
     */
    public func showNetworkActivityinStatusBar() {
        #if UIApplication
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        #endif
    }
    /**
     Hides network activity indicator in status bar
     */
    public func hideNetworkActivityinStatusBar() {
        #if UIApplication
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        #endif
    }
    
    #if os(iOS)
    var topMostVC: UIViewController? {
        #if UIApplication
            var presentedVC = UIApplication.shared.keyWindow?.rootViewController
            while let pVC = presentedVC?.presentedViewController {
                presentedVC = pVC
            }
            
            if presentedVC == nil {
                print("Error: You don't have any views set. You may be calling them in viewDidLoad. Try viewDidAppear instead.")
            }
            return presentedVC
        #else
            return nil
        #endif
    }
    
    /**
     Simple alert view
     
     - parameter title: title of the alert.
     - parameter message: message to show in the alert.
     */
    public func simpleAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if let rootViewController = self.topMostVC {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func minutesToHoursMinutes (minutes: Int) -> (Int, Int) {
        return (minutes / 60, (minutes % 60))
    }
    
    public func canDevicePlaceAPhoneCall() -> Bool {
        #if UIApplication
            if UIApplication.shared.canOpenURL(NSURL(string: "tel://")! as URL) {
                let netInfo = CTTelephonyNetworkInfo()
                let carrier = netInfo.subscriberCellularProvider
                let mnc = carrier?.mobileNetworkCode
                if (mnc?.characters == nil || mnc! == "65535") {
                    // Device cannot place a call at this time.  SIM might be removed.
                    return false
                } else {
                    // Device can place a phone call
                    return true
                }
            } else {
                return false
            }
        #else
            return false
        #endif
    }
    #endif

    public func readJSONFileAsDict(file: String) -> [String: Any] {
        do {
            if let path = Bundle.main.path(forResource: file, ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    return object
                } else {
                    return [:]
                }
            } else {
                return [:]
            }
        } catch {
            return [:]
        }
    }
    
    public func readJSONFileAsArray(file: String) -> [Any] {
        do {
            if let path = Bundle.main.path(forResource: file, ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [Any] {
                    // json is an array
                    return object
                } else {
                    return []
                }
            } else {
                return []
            }
        } catch {
            return []
        }
    }
    
    public func documentsDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return documentsFolderPath
    }
    
    // get next day of week
    // parameters dayofweek - which day we want 1=Sunday, 2=Monday ...
    func nextDayofWeek(dayofweek: Int) -> Date {
        let now = Date()
        let calendar = Calendar.current
        let weekdayToday = calendar.component(.weekday, from: now)
        var daysToDayofWeek = (7 + dayofweek - weekdayToday) % 7
        daysToDayofWeek = (daysToDayofWeek == 0) ? 7 : daysToDayofWeek
        return Calendar.current.date(byAdding: .day, value: daysToDayofWeek, to: now)!
    }
    
    // MARK: - Regex
    
    /// checks if text matches regex pattern
    public func regex(text: String?, regex: String?) -> Bool {
        guard let text = text, let regex = regex else {
            return false
        }
        if let _ = text.range(of:regex, options: .regularExpression) {
            return true
        } else {
            return false
        }
    }
    
    // extracts regex matches in an array
    // from http://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    //
    public func matchesForRegexInText(text: String?, regex: String?) -> [String] {
        guard let text = text else {
            return []
        }
        guard let regex = regex else {
            return []
        }
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch _ as NSError {
            //      print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    
}
