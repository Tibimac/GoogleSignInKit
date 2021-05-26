//
//  URL+Extensions.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import Foundation

extension URL {
    
    var queryDictionary: [String: String]? {
        guard let query = self.query else { return nil }
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            queryStrings[key] = value
        }
        return queryStrings
    }
}
