//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import OAuthSwift
import AuthenticationServices

public extension PixelfedClient {

    /// Creates OAuth application in Pixelfed.
    func createApp(named name: String,
                   redirectUri: String,
                   scopes: Scopes,
                   website: URL) async throws -> Application {

        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Apps.register(
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
            self?.oauthClient?.renewAccessToken(
                withRefreshToken: refreshToken,
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
                                                                         presentationContextProvider: presentationContextProvider,
                                                                         prefersEphemeralWebBrowserSession: true)

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.oAuthContinuation = continuation
            self?.oAuthHandle = self?.oauthClient?.authorize(
                withCallbackURL: app.redirectUri,
                scope: scope.joined(separator: " "),
                state: "PixELfed_AUTH",
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
