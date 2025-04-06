//
//  GoogleSignInError.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import Foundation

extension GoogleSignInKit {

    public enum Error: CustomNSError {
        case unknown
        case canceled
        case noConfiguration
        case failedToSetupAuthenticationRequest
        case cannotStartAuthentication
        case authenticationRequestFailed
        case failedToSetupCredentialsRequest
        case credentialsRequestFailed

        public static var errorDomain: String {
            return "GoogleSignInKit.GoogleSignInKit"
        }
    }
}
