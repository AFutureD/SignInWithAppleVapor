//
//  MockClient.swift
//
//
//  Created by AFuture on 2024/1/9.
//

import Vapor
import NIOCore

extension ClientResponse: @unchecked Sendable  {
}

extension MockClient {
    class Builder {
        var mockData: [ClientRequest: ClientResponse] = [:]
        
        func mock(request: ClientRequest, response: ClientResponse) {
            self.mockData[request] = response
        }
        
        func build() -> MockClient {
            MockClient(eventLoop: nil, mockData: self.mockData)
        }
    }
    
    static func builder() -> Builder {
        Builder()
    }
}

final class MockClient: Client {
    
    let eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    let eventLoop: EventLoop
    let mockData: [ClientRequest: ClientResponse]
    
    init(eventLoop: EventLoop?, mockData: [ClientRequest: ClientResponse] = [:]) {
        self.eventLoop = eventLoop ?? eventLoopGroup.next()
        self.mockData = mockData
    }
    
    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
        
        var matched = self.mockData.first { key,_ in
            return key == request
        }?.value
        
        if matched == nil {
            matched = ClientResponse(status: .notFound)
        }
        
        return self.eventLoop.future(matched!)
    }
    
    internal func delegating(to eventLoop: EventLoop) -> Client {
        return Self.init(eventLoop: eventLoop)
    }
    
}

extension ClientRequest: Hashable {
    public static func == (lhs: ClientRequest, rhs: ClientRequest) -> Bool {
        return lhs.method == rhs.method
        && lhs.url.string == rhs.url.string
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.method.string)
        hasher.combine(self.url.string)
        hasher.combine(self.headers.description)
    }
}

