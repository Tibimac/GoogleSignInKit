//
//  AuthenticationRequest.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import Foundation

extension GoogleSignInKit {

    internal enum AuthenticationRequest {
        internal static let baseURLString: String = "https://accounts.google.com/o/oauth2/auth"

        /* This struct is for internal use only. Used to store info from callback URL
         after the authentication consent on Google accounts webpage.
         Example :
         "SCHEME://?state=STRING&code=4/0AY0e-g7lmiIocD...4CMbiOA&authuser=0&prompt=consent&scope=email%20profile%20https://www.googleapis.com/auth/userinfo.email%20https://www.googleapis.com/auth/userinfo.profile%20openid
         */
        internal struct Result {
            let code: String?
            let state: String?
            let scopes: String?
            let prompt: String?
            let authUser: String?

            init(from dictionary: [String: String]) {
                code = dictionary["code"]
                state = dictionary["state"]
                scopes = dictionary["scope"]
                prompt = dictionary["prompt"]
                authUser = dictionary["authuser"]
            }
        }
    }
}
