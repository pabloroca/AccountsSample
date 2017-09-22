//
//  Styles.swift
//  INGAccounts
//
//  Created by Pablo Roca Rozas on 21/9/17.
//  Copyright © 2017 PR2Studio. All rights reserved.
//

import UIKit

// Sample color palette

extension UIColor {
    @nonobjc class var ingColorOrange: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 101.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var ingHeaderTextColor: UIColor {
        return UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
    }

}

// Sample text styles

extension UIFont {
    class func ingFontHeader() -> UIFont {
        return UIFont(name: "INGMe-Bold", size: 18)!
    }
    
    class func ingFontNormal() -> UIFont {
        return UIFont(name: "INGMe", size: 16)!
    }

    class func ingFontSmall() -> UIFont {
        return UIFont(name: "INGMe", size: 10)!
    }

    class func ingFontBalance() -> UIFont {
        #if os(iOS)
        return UIFont(name: "INGMe-Bold", size: 16)!
        #else
        return UIFont(name: "INGMe-Bold", size: 9)!
        #endif
    }
    
    class func ingFontBalanceCurrency() -> UIFont {
        #if os(iOS)
        return UIFont(name: "INGMe", size: 8)!
        #else
        return UIFont(name: "INGMe", size: 5)!
        #endif
    }

}
