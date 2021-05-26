//
//  SafariViewControllerDelegate.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import UIKit
import SafariServices

@available(iOS 9.0, macCatalyst 13.0, *)
internal final class SafariViewControllerDelegate: NSObject, SFSafariViewControllerDelegate {
    private let completion: GoogleSignInKit.CompletionResult
    
    init(completion: @escaping GoogleSignInKit.CompletionResult) {
        self.completion = completion
        super.init()
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        completion(.failure(.canceled))
    }
}
