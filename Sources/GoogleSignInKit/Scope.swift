//
//  GoogleSignInScope.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import Foundation

extension GoogleSignInKit {
    
    public enum Scope {
        case email
        case openID
        case profile
        
        internal var rawValue: String {
            switch self {
            case .email: return "email"
            case .openID: return "openid"
            case .profile: return "profile"
            }
        }
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
