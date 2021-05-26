//
//  TokenRequest.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import Foundation

extension GoogleSignInKit {
    
    internal enum TokenRequest {
        internal static let baseURLString: String = "https://oauth2.googleapis.com/token"
        
        /* This struct is for internal module usage only. Used to decode JSON
         received from Google API as show in the exeample below.
         Example :
         {
               "access_token": "ya29.A0AfH6SMDd8Z1wTGSgn...c8lW5-gajr8ttHD-7_STs",
               "expires_in": 3599,
               "refresh_token": "1//036SIVoAOSejJCgYIARAAGAMS...0LCD9CHkCUpU0YEZT0o8HJg",
               "scope": "https:www.googleapis.com/auth/userinfo.profile openid https://www.googleapis.com/auth/userinfo.email",
               "token_type": "Bearer",
               "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6I...68NA2FgHNYHfZoCEFN3j4w"
         }
         */
        internal struct Result: Decodable {
            let scope: String?
            let idToken: String?
            let tokenType: String?
            let accessToken: String?
            let refreshToken: String?
            let expiresIn: TimeInterval?
        }
    }
}
