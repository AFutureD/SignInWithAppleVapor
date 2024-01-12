//
//  AppleApi+Application.swift
//  
//
//  Created by AFuture on 2024/1/12.
//

import Foundation
import Vapor

public extension Application {
    
    struct AppleApiStorageKey: StorageKey {
        public typealias Value = AppleApi
    }
    
    var appleApi: AppleApi {
        get {
            if let client = self.storage[AppleApiStorageKey.self] {
                return client
            }
            let client = AppleApi(signers: self.jwt.signers, client: self.client, properties: self.appleSignInProperties, log: self.logger)
            self.storage.set(AppleApiStorageKey.self, to: client)
            return client
        }
        set {
            self.storage.set(AppleApiStorageKey.self, to: newValue)
        }
    }
}
