//
//  AppleApi.swift
//  
//
//  Created by AFuture on 2024/1/9.
//

import Vapor
import JWT

public struct AppleApi {
    public let signers: JWTSigners
    public let client: Client
    public let properties: AppleSignInProperties
    public let log: Logger
    
    public init(signers: JWTSigners, client: Client, properties: AppleSignInProperties, log: Logger) {
        self.signers = signers
        self.client = client
        self.properties = properties
        self.log = log
    }
    
    // https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/verifying_a_user
    public func verify(_ identityToken: String) throws -> AppleIdentityToken {
        try self.signers.verify(identityToken, as: AppleIdentityToken.self)
    }
    
    // https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
    public func validateToken(request: ValidationTokenRequest) async throws -> ValidationTokenRequest.Response {
        
        let clientSecret = try buildClientSecret(kid: properties.kid, clientId: properties.clientID, teamId: properties.teamID)
        log.debug("clientSecret: \(clientSecret)")
        
        let formData = buildClientSecretForm(.authorizationCode(request.authorizationCode), clientId: properties.clientID, clientSecret: clientSecret)
        log.debug("form: \(formData)")
        
        let response = try await self.client.post(.init(string: ValidationTokenRequest.method)) { req in
            try req.content.encode(formData, as: .urlEncodedForm)
        }
        log.debug("response: \(response)")
        
        guard response.status == .ok else {
            let failure = try response.content.decode(ValidationTokenRequest.Failure.self)
            return .failure(failure)
        }
        
        let tokenResponse = try response.content.decode(ValidationTokenRequest.Success.self)
        
        
        // let token = tokenResponse.idToken
        // _ = try self.signers.verify(token, as: AppleIdentityToken.self)
        
        return .success(tokenResponse)
        
    }
    
    public func buildClientSecretForm(_ value: GrantValue, clientId: String, clientSecret: String) -> Dictionary<String, String> {
        switch value {
        case .refreshToken(let token):
            return [
                "client_id": clientId,
                "client_secret": clientSecret,
                "grant_type": "refresh_token",
                "refresh_token": token
            ]
        case .authorizationCode(let code):
            return [
                "client_id": clientId,
                "client_secret": clientSecret,
                "grant_type": "authorization_code",
                "code": code
            ]
        }
    }
    
    // https://developer.apple.com/documentation/accountorganizationaldatasharing/creating-a-client-secret
    public func buildClientSecret(
        kid keyIdentify: String, clientId: String, teamId: String,
        since: Date = .init(timeIntervalSinceNow: 0),
        within:TimeInterval = 3600 * 24 * 180
    ) throws -> String {
        // can cache
        let myJWK = AppleIdJWT(
            issuer: .init(value: teamId),
            issuedAt: .init(value: since),
            expires: .init(
                value: since.addingTimeInterval(within)
            ),
            audience: "https://appleid.apple.com",
            subject: .init(value: clientId)
        )
        log.info("client jwk info: \(myJWK)")
        return try self.signers.sign(myJWK, kid: .init(string: keyIdentify))
    }
}

extension AppleApi {
    public enum GrantValue {
        case refreshToken(String)
        case authorizationCode(String)
    }
}
