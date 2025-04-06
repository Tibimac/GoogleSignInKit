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

        // Basics scopes
        public static let email = Scope(rawValue: "email")
        public static let openID = Scope(rawValue: "OpenID")
        public static let profile = Scope(rawValue: "profile")
    }

    internal enum ScopeURL: String {
        case email = "https://www.googleapis.com/auth/userinfo.email"
        case openID = "openid"
        case profile = "https://www.googleapis.com/auth/userinfo.profile"
        
        internal var scope: Scope {
            switch self {
            case ScopeURL.email: return Scope.email
            case ScopeURL.openID: return Scope.openID
            case ScopeURL.profile: return Scope.profile
            }
        }
    }
}
