//
//  PresentationContextProvider.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import AuthenticationServices

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, *)
internal final class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    private let appAnchor: ASPresentationAnchor
    
    init(appAnchor: ASPresentationAnchor) {
        self.appAnchor = appAnchor
        super.init()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return appAnchor
    }
}
