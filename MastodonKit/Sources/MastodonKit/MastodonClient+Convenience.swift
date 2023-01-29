//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import OAuthSwift
import AuthenticationServices

public extension MastodonClient {
    
    /// Creates OAuth application in Pixelfed.
    func createApp(named name: String,
                          redirectUri: String,
                          scopes: Scopes,
                          website: URL) async throws -> Application {
        
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Apps.register(
                clientName: name,
                redirectUris: redirectUri,
                scopes: scopes.reduce("") { $0 == "" ? $1 : $0 + " " + $1},
                website: website.absoluteString
            )
        )
        
        return try await downloadJson(Application.self, request: request)
    }
    
    /// Refresh access token..
    func refreshToken(clientId: String, clientSecret: String, refreshToken: String) async throws -> OAuthSwiftCredential {
        oauthClient = OAuth2Swift(
            consumerKey: clientId,
            consumerSecret: clientSecret,
            authorizeUrl: baseURL.appendingPathComponent("oauth/authorize"),
            accessTokenUrl: baseURL.appendingPathComponent("oauth/token"),
            responseType: "code"
        )
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.oAuthContinuation = continuation
            
            oauthClient?.renewAccessToken(
                withRefreshToken: "refrestoken",
                completionHandler: { result in
                    switch result {
                    case let .success((credentials, _, _)):
                        continuation.resume(with: .success(credentials))
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    self?.oAuthContinuation = nil
            })
        }
    }
    
    /// User authentication.
    func authenticate(app: Application,
                      scope: Scopes,
                      callbackUrlScheme: String,
                      presentationContextProvider: ASWebAuthenticationPresentationContextProviding
    ) async throws -> OAuthSwiftCredential {
        
        oauthClient = OAuth2Swift(
            consumerKey: app.clientId,
            consumerSecret: app.clientSecret,
            authorizeUrl: baseURL.appendingPathComponent("oauth/authorize"),
            accessTokenUrl: baseURL.appendingPathComponent("oauth/token"),
            responseType: "code"
        )
        
        oauthClient?.authorizeURLHandler = ASWebAuthenticationURLHandler(callbackUrlScheme: callbackUrlScheme,
                                                                         presentationContextProvider: presentationContextProvider)
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.oAuthContinuation = continuation
            oAuthHandle = oauthClient?.authorize(
                withCallbackURL: app.redirectUri,
                scope: scope.joined(separator: " "),
                state: "MASToDON_AUTH",
                completionHandler: { result in
                    switch result {
                    case let .success((credentials, _, _)):
                        continuation.resume(with: .success(credentials))
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    self?.oAuthContinuation = nil
                }
            )
        }
    }
    
    static func handleOAuthResponse(url: URL) {
        OAuthSwift.handle(url: url)
    }
}
