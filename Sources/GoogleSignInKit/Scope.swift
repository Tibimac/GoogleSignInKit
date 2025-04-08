//
//  GoogleSignInScope.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import Foundation

extension GoogleSignInKit {

    public struct Scope: RawRepresentable, Equatable, Hashable, Codable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let email   = Scope(rawValue: "https://www.googleapis.com/auth/userinfo.email")
        public static let profile = Scope(rawValue: "https://www.googleapis.com/auth/userinfo.profile")
        public static let openID  = Scope(rawValue: "openid")
    }

}

