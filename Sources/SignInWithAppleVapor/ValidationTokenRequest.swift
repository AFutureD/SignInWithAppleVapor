//
//  ValidationTokenRequest.swift
//  
//
//  Created by AFuture on 2024/1/9.
//

public protocol ClientApiRequest {
    associatedtype Success
    associatedtype Failure: Error
    typealias Response = Result<Success, Failure>
    
}

extension AppleApi {
    public struct ValidationTokenRequest: ClientApiRequest {
        public static let method = "https://appleid.apple.com/auth/token"
        
        public let authorizationCode:String
        
        public init(_ authorizationCode: String) {
            self.authorizationCode = authorizationCode
        }
    }
}

extension AppleApi.ValidationTokenRequest {
    
    // https://developer.apple.com/documentation/sign_in_with_apple/errorresponse
    public struct Failure: Codable, Error {
        public enum Errors:String, Codable {
            case invalidRequest = "invalid_request"
            case invalidClient = "invalid_client"
            case invalidGrant = "invalid_grant"
            case unauthorizedClient = "unauthorized_client"
            case unsupportedGrantType = "unsupported_grant_type"
            case invalidScope = "invalid_scope"
        }
        
        public let error: Errors
        public let error_description: String?
    }
    
    // https://developer.apple.com/documentation/sign_in_with_apple/tokenresponse
    public struct Success: Codable {
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case expiresIn = "expires_in"
            case refreshToken = "refresh_token"
            case idToken = "id_token"
        }
        public let accessToken: String
        public let tokenType: String
        public let expiresIn: Int
        public let refreshToken: String?
        public let idToken: String
    }
}

