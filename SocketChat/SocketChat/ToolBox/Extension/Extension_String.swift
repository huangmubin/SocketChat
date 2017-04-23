//
//  Extension_String.swift
//  NetworkTestProject
//
//  Created by 黄穆斌 on 2017/3/17.
//  Copyright © 2017年 MuBinHuang. All rights reserved.
//

import Foundation

extension String {
    
    // MARK: - localisation
    
    /** Return the localisation string. */
    public var localisation: String {
        return NSLocalizedString(self, comment: self)
    }
    
    /**
     Return the localisation string.
     - parameter comment: the predicate to which data.
     - parameter bundls: default Bundle.main
     - returns: a localized string
     */
    public func localisation(_ comment: String, bundls: Bundle = Bundle.main) -> String {
        return NSLocalizedString(self, bundle: bundls, comment: comment)
    }
    
    // MARK: - Range
    
    /**
     Return sub string with range
     - parameter range: s ..< e
     - returns: a sub string
     */
    subscript(range: Range<Int>) -> String {
        return self[self.index(self.startIndex, offsetBy: range.lowerBound) ..< self.index(self.startIndex, offsetBy: range.upperBound)]
    }

    // MARK: - Regular Expression
    
    /**
     Return if is match
     // ip 地址: "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$"
     - parameter pattern: regular expression pattern
     - returns: is or not
     */
    func match(pattern: String) -> Bool {
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.characters.count))
            return matches.count == 1
        }
        return false
    }
    
}
