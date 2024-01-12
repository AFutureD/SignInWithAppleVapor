//
//  AppleSignInProperties.swift
//  
//
//  Created by AFuture on 2024/1/9.
//

import Foundation
import JWTKit
import Vapor

public extension Application {
    
    struct AppleSignInPropertiesStorageKey: StorageKey {
        public typealias Value = AppleSignInProperties
    }
    
    var appleSignInProperties: AppleSignInProperties {
        get {
            guard let client = self.storage[AppleSignInPropertiesStorageKey.self] else {
                fatalError("AppleApi not setup.")
            }
            return client
        }
        set {
            self.storage.set(AppleSignInPropertiesStorageKey.self, to: newValue)
        }
    }
}

public struct AppleSignInProperties {
    public let teamID: String
    public let clientID: String
    public let kid: String
    public let pem: String
    
    public init(teamID: String, clientID: String, kid: String, pem: String) {
        self.teamID = teamID
        self.clientID = clientID
        self.kid = kid
        self.pem = pem
    }
}

public extension AppleSignInProperties {
    var signer: JWTSigner {
        get throws {
            JWTSigner.es256(key: try .private(pem: pem))
        }
    }
}
