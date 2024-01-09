//
//  AppleIdJWT.swift
//  
//
//  Created by AFuture on 2024/1/9.
//

import Foundation
import JWT

public struct AppleIdJWT: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case subject = "sub"
        case audience = "aud"
        case issuedAt = "iat"
        case expires = "exp"
    }
    
    public let issuer: IssuerClaim
    public let issuedAt: IssuedAtClaim
    public let expires: ExpirationClaim
    public let audience: AudienceClaim
    public let subject: SubjectClaim
    
    public func verify(using signer: JWTSigner) throws {
        guard self.audience.value.contains("https://appleid.apple.com") else {
            throw JWTError.claimVerificationFailure(name: "iss", reason: "Token not provided by Apple")
        }
        
        try self.expires.verifyNotExpired()
    }
}

extension AppleIdJWT {
    init(issuer: IssuerClaim, expires: ExpirationClaim, subject: SubjectClaim) {
        self.init(
            issuer: issuer,
            issuedAt: .init(
                value: .init(timeIntervalSinceNow: 0)
            ),
            expires: expires,
            audience: "https://appleid.apple.com",
            subject: subject
        )
    }
}
