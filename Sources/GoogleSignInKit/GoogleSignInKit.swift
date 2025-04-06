//
//  GoogleSignInManager.swift
//  GoogleSignInKit
//
//  Created by Thibault Le Cornec on 25/05/2021.
//

import UIKit
import SafariServices
import AuthenticationServices

public enum GoogleSignInKit {
    
    // MARK: - Types
    
    public typealias CompletionResult = (Result<GoogleSignInKit.Credentials, GoogleSignInKit.Error>) -> Void
    
    public enum Manager {
        /* Main configuration of manager with default values */
        public struct Configuration {
            let clientID: String
            let defaultScheme: String
            let defaultCallbackURL: String
            let defaultScopes: [GoogleSignInKit.Scope]
            
            public init(clientID: String, defaultScheme: String, defaultCallbackURL: String, defaultScopes: [GoogleSignInKit.Scope]) {
                self.clientID = clientID
                self.defaultScheme = defaultScheme
                self.defaultCallbackURL = defaultCallbackURL
                self.defaultScopes = defaultScopes
            }
        }
    }
    
    /** Configuration which can be used to temporary override default values */
    public struct Configuration {
        let scheme: String?
        let callbackURL: String?
        let scopes: [GoogleSignInKit.Scope]?
        
        public init(scheme: String?, callbackURL: String?, scopes: [GoogleSignInKit.Scope]?) {
            self.scheme = scheme
            self.callbackURL = callbackURL
            self.scopes = scopes
        }
    }
    
    /** Credentials received after a fully successful authentication request. */
    public struct Credentials: Codable {
        /** `idToken` is the JWT received from Google */
        public let idToken: String?
        public let tokenType: String?
        public let accessToken: String?
        public let refreshToken: String?
        public let expiresIn: TimeInterval?
        public let scopes: [GoogleSignInKit.Scope]?
    }
    
    // MARK: - Properties
    
    private static var state: String!
    private static var configuration: Manager.Configuration!
    private static var overrideConfiguration: Configuration?
    private static var completionResult: CompletionResult!
    
    private static let jsonDecoder: JSONDecoder = {
        $0.keyDecodingStrategy = .convertFromSnakeCase
        return $0
    }(JSONDecoder())
    
    private static var appWindow: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    private static var topPresentedViewController: UIViewController? {
        var topPresented: UIViewController? = appWindow?.rootViewController
        while let presented = topPresented?.presentedViewController { topPresented = presented }
        return topPresented
    }
    
    /* According to documentation we need to keep a strong reference on ASWebAuthenticationSession
       * instance as our deployment target is below iOS 13.0.
       * https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/2990953-start */
    @available(iOS 12.0, macOS 10.15, macCatalyst 13.0, watchOS 6.2, *)
    private static var authenticationSession: ASWebAuthenticationSession!
    
    @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, *)
    private static var presentationContextProvider: PresentationContextProvider!
    private static var safariViewControllerDelegate: SafariViewControllerDelegate!
    
    // MARK: - Usage
    
    public static func configure(configuration: GoogleSignInKit.Manager.Configuration) {
        self.configuration = configuration
    }
    
    /** Method to call to let user consent to the authentication. As a result of the consent you will
     receive a `Credentials` struct which contains all you need to authenticate user from your side.
     - Note : You can use this one or `signIn(overrideConfig:completion:)` but you you **must** not
     use both! If you call this so the call to `configure(configuration:)` is not mandatory.
     */
    public static func signIn(configuration: GoogleSignInKit.Manager.Configuration, completion: @escaping GoogleSignInKit.CompletionResult) throws {
        self.configuration = configuration
        try signIn(completion: completion)
    }
    
    /** Method to call to let user consent to the authentication. As a result of the consent you will
     receive a `Credentials` struct which contains all you need to authenticate user from your side.
     - Note : You can use this one or `signIn(configuration:completion:)` but you you **must** not
     use both! If you call this one you **must** call `configure(configuration:)` before!
     */
    public static func signIn(overrideConfig: GoogleSignInKit.Configuration? = nil, completion: @escaping GoogleSignInKit.CompletionResult) throws {
        /* Sign-In Prerequisites Checks */
        
        guard let managerConfiguration = configuration else { throw GoogleSignInKit.Error.noConfiguration }
        
        /* Sign-In Prerequisites Setup */
        
        overrideConfiguration = overrideConfig
        state = UUID().uuidString
        
        /* Authentication Request Setup */
        
        let scheme = (overrideConfig?.scheme ?? managerConfiguration.defaultScheme)
        let uri = (overrideConfig?.callbackURL ?? managerConfiguration.defaultCallbackURL)
        let scopes = (overrideConfig?.scopes ?? managerConfiguration.defaultScopes).map({ $0.rawValue }).joined(separator: " ")
        
        var urlComponents = URLComponents(string: AuthenticationRequest.baseURLString)
        let queryItems = [
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "scope", value: scopes),
            URLQueryItem(name: "redirect_uri", value: uri),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: managerConfiguration.clientID)
        ]
        urlComponents?.queryItems = queryItems
        
        guard let authenticationURL = urlComponents?.url else {
            resetManager()
            throw GoogleSignInKit.Error.failedToSetupAuthenticationRequest
        }
        
        if #available(iOS 12.0, macOS 10.15, macCatalyst 13.0, watchOS 6.2, *) {
            /* On iOS 12 and later we can use ASWebAuthenticationSession which handles callback URL. */
            /* Authentication Session Setup */
            
            authenticationSession = ASWebAuthenticationSession(url: authenticationURL, callbackURLScheme: scheme) { (callbackURL, error) in
                /* Callback URL Checks and Parsing */
                
                guard error == nil else {
                    guard let error = error as? ASWebAuthenticationSessionError else {
                        completion(.failure(.unknown))
                        resetManager()
                        return
                    }
                    
                    switch error.code {
                    case .canceledLogin:
                        completion(.failure(.canceled))
                        
                    case .presentationContextNotProvided, .presentationContextInvalid:
                        completion(.failure(.cannotStartAuthentication))
                        
                    @unknown default:
                        completion(.failure(.unknown))
                    }
                    resetManager()
                    return
                }
                
                guard let urlDictionary = callbackURL?.queryDictionary else {
                    completion(.failure(.authenticationRequestFailed))
                    resetManager()
                    return
                }
                
                /* Token Request */
                
                let result = AuthenticationRequest.Result(from: urlDictionary)
                tokenRequest(wihtOverrideConfig: overrideConfiguration, authenticationResult: result, completion: completion)
            }
            
            if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, *) {
                guard let window = appWindow else {
                    resetManager()
                    throw GoogleSignInKit.Error.cannotStartAuthentication
                }
                presentationContextProvider = PresentationContextProvider(appAnchor: window)
                authenticationSession.presentationContextProvider = presentationContextProvider
            }
            
            if #available(iOS 13.4, macOS 10.15.4, macCatalyst 13.4, watchOS 6.2, *) {
                guard authenticationSession.canStart else {
                    resetManager()
                    throw GoogleSignInKit.Error.cannotStartAuthentication
                }
            }
            
            /* Authentication Session Execution */
            
            authenticationSession.start()
        } else {
            /* On iOS versions ealier than iOS 12, we have to display an SFSafariViewController which
               * doesn't handles callback URL itself. Callback is handle by the whole application delegate,
               * and URL is redirected to this module through `handleCallback(url:)` function. That's why
               * we have to keep a reference on completion handler to give it to `tokenRequest()` function
               * from `handleCallback(url:)` function.*/
            completionResult = completion
            
            /* Safari View Controller Setup */
            
            let safariViewController = SFSafariViewController(url: authenticationURL)
            if #available(iOS 11.0, macCatalyst 13.0, *) { safariViewController.dismissButtonStyle = .cancel }
            safariViewControllerDelegate = SafariViewControllerDelegate(completion: { result in
                completion(result)
                resetManager()
            })
            safariViewController.delegate = safariViewControllerDelegate
            
            /* Safari View Controller Display */
            
            guard let topPresentedViewController = topPresentedViewController else {
                resetManager()
                throw GoogleSignInKit.Error.cannotStartAuthentication
            }
            topPresentedViewController.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    /** Method to call for compatibility with iOS 10/11 from your UIApplication delegate in method
     `func application(_, open:options:)`. This methode take as paramter the callback url to be able
     to retrieve the user token (JWT) from Google fo user. */
    public static func handleCallback(url: URL) {
        let completion = completionResult! /* Not really optional, so cannot be nil */
        
        guard let topPresentingViewController = topPresentedViewController?.presentingViewController else {
            completion(.failure(.authenticationRequestFailed))
            resetManager()
            return
        }
        topPresentingViewController.dismiss(animated: true, completion: nil)
        
        guard let urlDictionary = url.queryDictionary else {
            completion(.failure(.authenticationRequestFailed))
            resetManager()
            return
        }
        let result = AuthenticationRequest.Result(from: urlDictionary)
        tokenRequest(wihtOverrideConfig: overrideConfiguration, authenticationResult: result, completion: completion)
    }
    
    private static func tokenRequest(wihtOverrideConfig overrideConfig: Configuration?,
                                     authenticationResult: AuthenticationRequest.Result,
                                     completion: @escaping CompletionResult)
    {
        /* Token Request Prerequisites Checks */
        
        guard let managerConfiguration = configuration else {
            completion(.failure(.noConfiguration))
            resetManager()
            return
        }
        
        guard let code = authenticationResult.code, authenticationResult.state == state else {
            completion(.failure(.authenticationRequestFailed))
            resetManager()
            return
        }
        
        /* Token Request Setup */
        
        guard let tokenURL = URL(string: TokenRequest.baseURLString) else {
            completion(.failure(.failedToSetupCredentialsRequest))
            resetManager()
            return
        }
        var tokenURLRequest = URLRequest(url: tokenURL)
        tokenURLRequest.httpMethod = "POST"
        tokenURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestBodyComponents = URLComponents()
        let bodyQueryItems = [
            URLQueryItem(name: "client_id", value: managerConfiguration.clientID),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "redirect_uri", value: overrideConfig?.callbackURL ?? managerConfiguration.defaultCallbackURL)
        ]
        requestBodyComponents.queryItems = bodyQueryItems
        guard let bodyData = requestBodyComponents.query?.data(using: .utf8) else {
            completion(.failure(.failedToSetupCredentialsRequest))
            resetManager()
            return
        }
        tokenURLRequest.httpBody = bodyData
        
        /* Token Task Setup */
        
        let tokenTask = URLSession.shared.dataTask(with: tokenURLRequest, completionHandler: { data, response, error in
            defer { resetManager() }
            
            /* Token Task Result Checks */
            
            guard error == nil, let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(.credentialsRequestFailed))
                return
            }
            
            guard (200...299) ~= response.statusCode else {
                completion(.failure(.credentialsRequestFailed))
                return
            }
            
            /* Token Task Result Parsing */
            
            do {
                let result = try jsonDecoder.decode(TokenRequest.Result.self, from: data)
                let scopes = result.scope?.components(separatedBy: " ").compactMap({ ScopeURL(rawValue: $0)?.scope })
                let credentials = Credentials(idToken: result.idToken,
                                              tokenType: result.tokenType,
                                              accessToken: result.accessToken,
                                              refreshToken: result.refreshToken,
                                              expiresIn: result.expiresIn,
                                              scopes: scopes)
                completion(.success(credentials))
            } catch {
                completion(.failure(.credentialsRequestFailed))
            }
        })
        
        /* Token Task Execution */
        
        tokenTask.resume()
    }
    
    // MARK: - Utilities
    
    private static func resetManager() {
        state = nil
        completionResult = nil
        safariViewControllerDelegate = nil
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, *) { presentationContextProvider = nil }
        if #available(iOS 12.0, macOS 10.15, macCatalyst 13.0, watchOS 6.2, *) { authenticationSession = nil }
    }
}
