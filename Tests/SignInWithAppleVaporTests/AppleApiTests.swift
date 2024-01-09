//
//  AppleApiTests.swift
//
//
//  Created by AFuture on 2024/1/9AppleApiTests
//

import XCTVapor
import JWTKit

@testable import SignInWithAppleVapor


final class AppleApiTests: XCTestCase {
    
    var signers = JWTSigners()
    var clientBuilder = MockClient.Builder()
    let log = Logger(label: "AppleApiTests")
    let prop = AppleSignInProperties(teamID: "97QJCYC5T5", clientID: "me.afuture.Travel", kid: "V6VJH8QSM5", pem: """
    -----BEGIN PRIVATE KEY-----
    MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgA+QlAWoa+dy+el6/
    QdzNviXCW8LqoqhjkJ4Re05qeF2gCgYIKoZIzj0DAQehRANCAAROh4rx2IlR83r3
    ANNOgiJM0vZ51KUuq5TTttQXCjsBlI3djiM1D1MfeQolUe8EbJiViSqaETBkzPkX
    07K9HNDs
    -----END PRIVATE KEY-----
    """)
    
    override func setUp() async throws {
        try signers.use(.es256(key: .private(pem: prop.pem)), kid: .init(string: prop.kid))
        
        try signers.use(jwk: .init(json:"""
        {
            "kty": "RSA",
            "kid": "W6WcOKB",
            "use": "sig",
            "alg": "RS256",
            "n": "2Zc5d0-zkZ5AKmtYTvxHc3vRc41YfbklflxG9SWsg5qXUxvfgpktGAcxXLFAd9Uglzow9ezvmTGce5d3DhAYKwHAEPT9hbaMDj7DfmEwuNO8UahfnBkBXsCoUaL3QITF5_DAPsZroTqs7tkQQZ7qPkQXCSu2aosgOJmaoKQgwcOdjD0D49ne2B_dkxBcNCcJT9pTSWJ8NfGycjWAQsvC8CGstH8oKwhC5raDcc2IGXMOQC7Qr75d6J5Q24CePHj_JD7zjbwYy9KNH8wyr829eO_G4OEUW50FAN6HKtvjhJIguMl_1BLZ93z2KJyxExiNTZBUBQbbgCNBfzTv7JrxMw",
            "e": "AQAB"
        }
        """))
    }
    
    func testBuildClientSecret() async throws {
        
        let appleApi = AppleApi(signers: signers, client: clientBuilder.build(), properties: prop, log: log)
        let now = Date.init(timeIntervalSinceNow: 0)
        
        let myJWK = AppleIdJWT(
            issuer: .init(value: prop.teamID),
            issuedAt: .init(value: now),
            expires: .init(
                value: now.addingTimeInterval(3600)
            ),
            audience: "https://appleid.apple.com",
            subject: .init(value: prop.clientID)
        )
        let secret = try appleApi.buildClientSecret(kid: prop.kid, clientId: prop.clientID, teamId: prop.teamID, since: now, within: 3600)
        let signed = try signers.verify(secret, as: AppleIdJWT.self)
        
        XCTAssertEqual(signed.issuer.value, myJWK.issuer.value)
        XCTAssertEqual(signed.issuedAt.value.timeIntervalSince1970, myJWK.issuedAt.value.timeIntervalSince1970)
        XCTAssertEqual(signed.expires.value.timeIntervalSince1970, myJWK.expires.value.timeIntervalSince1970)
        XCTAssertEqual(signed.audience.value, myJWK.audience.value)
        XCTAssertEqual(signed.subject.value, myJWK.subject.value)
        
    }
    
    func testValidateToken() async throws {
        
        let req = AppleApi.ValidationTokenRequest.init("c93e87e60a84a4be28ed40a25931bf11c.0.srvqw.He5zbJsIEE653TFaBr22_g")
        let tokenContent = AppleApi.ValidationTokenRequest.Success(
            accessToken: "aa0fb42cf436b4f01bd55575cc0f50087.0.rrvqw.Mhh2EsTJQAZ_24bvZEYzVw",
            tokenType: "Bearer",
            expiresIn: 3600,
            refreshToken: "r8d6bfb1f9563483fb17890bb8623f645.0.rrvqw.jOa_O1Cw5F2qY-UGKDRPAw",
            idToken: "eyJraWQiOiJXNldjT0tCIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoibWUuYWZ1dHVyZS5UcmF2ZWwiLCJleHAiOjE3MDM0OTg0MDIsImlhdCI6MTcwMzQxMjAwMiwic3ViIjoiMDAxNTA2LmZiN2UyNDdjNjNlYjRkMmU4YjAyOTZlZmJmZmU5ODFlLjE0MTAiLCJhdF9oYXNoIjoiRW1DNklzQmcyOHVrbkNvaWxsTlN6QSIsImF1dGhfdGltZSI6MTcwMzQxMTk3OSwibm9uY2Vfc3VwcG9ydGVkIjp0cnVlLCJyZWFsX3VzZXJfc3RhdHVzIjoyfQ.E3HMXQzrwJeu4hWTNYc5m6nr8iyhBTlPvYlxB5F9swMBGNG85inBxeVphHO7ZJ8d_IkBmb033jKHjnVaLjQveAt3Unk8xXcsCtwZ3O1VpAZqVIXgCnWAY-_mIVCcsUBlZCOPVzXrnNpjbNIOOBBGK-Pg3ECCx27ww5LmNJk91UuSl3jRtNkcyzrXijxrTWLZr2zC4qZ0e1T7i6fXvqUuLkMCQsquSjjTkgasvuHY-n5G1fl72y4czVSas-bHK3McNEjQFa38U9Ok6-OwBzQ9PtLfPWCo5SBS779iegB0fB-ZAPn_ZM3kqYm40z1Q89cLg8Gq5jJtFf_2pF6VlmVXWQ"
        )
        
        var resp: ClientResponse = .init(status: .ok)
        try resp.content.encode(tokenContent, as: HTTPMediaType.json)
        
        clientBuilder.mock(
            request: .init(method: .POST, url: .init(string: AppleApi.ValidationTokenRequest.method)),
            response: resp
        )
        
        let appleApi = AppleApi(signers: signers, client: clientBuilder.build(), properties: prop, log: log)
        
        
        let result = try await appleApi.validateToken(request: req)
        
        guard case let .success(received) = result else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(tokenContent.accessToken, received.accessToken)
        XCTAssertEqual(tokenContent.tokenType, received.tokenType)
        XCTAssertEqual(tokenContent.refreshToken, received.refreshToken)
        XCTAssertEqual(tokenContent.idToken, received.idToken)
    }
}
