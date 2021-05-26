//
//  CharacterSet+Extensions.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import Foundation

extension CharacterSet {
    
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // Does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
