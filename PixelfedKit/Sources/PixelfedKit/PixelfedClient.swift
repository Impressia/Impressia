//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import OAuthSwift

public enum PixelfedClientError: Swift.Error {
    case oAuthCancelled
}

public protocol PixelfedClientProtocol {
    static func request(for baseURL: URL, target: TargetType, withBearerToken token: String?, timeoutInterval: Double?) throws -> URLRequest
}

public extension PixelfedClientProtocol {
    static func request(for baseURL: URL, target: TargetType, withBearerToken token: String? = nil, timeoutInterval: Double? = nil) throws -> URLRequest {
        
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(target.path), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = target.queryItems?.map { URLQueryItem(name: $0.0, value: $0.1) }
        
        guard let url = urlComponents?.url else { throw NetworkingError.cannotCreateUrlRequest }
        
        var request = URLRequest(url: url)
        
        if let timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        
        target.headers?.forEach { header in
            request.setValue(header.1, forHTTPHeaderField: header.0)
        }
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpMethod = target.method.rawValue
        request.httpBody = target.httpBody
                
        return request
    }
}

public class PixelfedClient: PixelfedClientProtocol {
    
    let urlSession: URLSession
    let baseURL: URL
    
    /// oAuth
    var oauthClient: OAuth2Swift?
    var oAuthHandle: OAuthSwiftRequestHandle?
    var oAuthContinuation: CheckedContinuation<OAuthSwiftCredential, Swift.Error>?
    
    public init(baseURL: URL, urlSession: URLSession = .shared) {
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    public func getAuthenticated(token: Token) -> PixelfedClientAuthenticated {
        PixelfedClientAuthenticated(baseURL: baseURL, urlSession: urlSession, token: token)
    }
    
    deinit {
        oAuthContinuation?.resume(throwing: PixelfedClientError.oAuthCancelled)
        oAuthHandle?.cancel()
    }
    
    public func downloadJson<T>(_ type: T.Type, request: URLRequest) async throws -> T where T: Decodable {
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
        
        #if DEBUG
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                let json = String(data: data, encoding: .utf8)!
                print(json)

                throw error
            }
        #else
            return try JSONDecoder().decode(type, from: data)
        #endif
    }
}

public class PixelfedClientAuthenticated: PixelfedClientProtocol {
    
    public let token: Token
    public let baseURL: URL
    public let urlSession: URLSession

    init(baseURL: URL, urlSession: URLSession, token: Token) {
        self.token = token
        self.baseURL = baseURL
        self.urlSession = urlSession
    }
    
    public func send(request: URLRequest) async throws {
        let (data, response) = try await urlSession.data(for: request)
        
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            #if DEBUG
                let json = String(data: data, encoding: .utf8)!
                print(json)
            #endif
            
            throw NetworkError.notSuccessResponse(response)
        }
    }
    
    public func downloadJson<T>(_ type: T.Type, request: URLRequest) async throws -> T where T: Decodable {
        let (data, response) = try await urlSession.data(for: request)
        
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            #if DEBUG
                let json = String(data: data, encoding: .utf8)!
                print(json)
            #endif
            
            throw NetworkError.notSuccessResponse(response)
        }

        #if DEBUG
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                let json = String(data: data, encoding: .utf8)!
                print(json)

                throw error
            }
        #else
            return try JSONDecoder().decode(type, from: data)
        #endif
    }
    
    public func downloadJsonWithLink<T>(_ type: T.Type, request: URLRequest) async throws -> Linkable<T> where T: Decodable {
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }

        #if DEBUG
            do {
                let decoded = try JSONDecoder().decode(type, from: data)
                
                var link: Link?
                if let response = response as? HTTPURLResponse, let linkHeader = response.allHeaderFields["Link"] as? String {
                    link = Link(rawLink: linkHeader)
                }
                
                return Linkable(data: decoded, link: link)
            } catch {
                let json = String(data: data, encoding: .utf8)!
                print(json)

                throw error
            }
        #else
            let decoded =  try JSONDecoder().decode(type, from: data)
        
            var link: Link?
            if let response = response as? HTTPURLResponse, let linkHeader = response.allHeaderFields["Link"] as? String {
                link = Link(rawLink: linkHeader)
            }
            
            return Linkable(data: decoded, link: link)
        #endif
    }
}
