//
//  WaitPublisher.swift
//  CombineExt
//
//  Created by Rogerio de Paula Assis on 4/6/20.
//  Copyright © 2020 CombineExt. All rights reserved.
//

import Foundation
import Combine

extension Publishers {

    enum WaitPublisherError: Swift.Error {
        case noElements
        case timedOut
    }

    /// A publisher used to synchronously wait for a `complete`, `error` or timeout signals
    public class WaitPublisher<Upstream>: Publisher where Upstream: Publisher {

        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        private let upstream: Upstream
        private let timeout: TimeInterval?

        private var cancellable: Cancellable?

        init(upstream: Upstream, timeout: TimeInterval? = nil) {
            self.upstream = upstream
            self.timeout = timeout
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            self.upstream.receive(subscriber: subscriber)
        }
    }
}

extension Publisher {
    /// Configures a synchronous publisher with an optional `TimeInterval` timeout
    public func wait(timeout: TimeInterval? = nil) -> Publishers.WaitPublisher<Self> {
        return Publishers.WaitPublisher(upstream: self, timeout: timeout)
    }
}

extension Publishers.WaitPublisher {

    /// Synchronously waits for the first value received,
    /// or throws an error if the publisher completes with no
    /// values received.
    public func first() throws -> Result<Output, Failure> {
        let result = try toArray(max: 1).get()
        guard let first = result.first else {
            throw Publishers.WaitPublisherError.noElements
        }
        return .success(first)
    }

    /// Synchronously waits for the publisher to complete
    /// and emit **only** the last value received, throwing
    /// an error if no value has been received.
    public func last() throws -> Result<Output, Failure> {
        let result = try toArray().get()
        guard let last = result.last else {
            throw Publishers.WaitPublisherError.noElements
        }
        return .success(last)
    }

    /// Synchronously returns all values received by the publisher until a
    /// complete or error signal is emitted
    public func toArray(max: Int? = nil) throws -> Result<[Output], Failure> {
        var values: [Output] = []
        var result: Result<[Output], Failure>!
        let semaphore = DispatchSemaphore(value: 0)
        self.cancellable = self.upstream.sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                result = .success(values)
            case .failure(let error):
                result = .failure(error)
            }
            semaphore.signal()
        }) { [weak self] value in
            values.append(value)
            if let max = max, values.count >= max {
                result = .success(values)
                self?.cancellable?.cancel()
                semaphore.signal()
            }
        }
        if let timeout = timeout {
            let dispatchTimeoutResult = semaphore.wait(timeout: .now() + DispatchTimeInterval.seconds(Int(timeout)))
            if case .timedOut = dispatchTimeoutResult {
                throw Publishers.WaitPublisherError.timedOut
            }
        } else {
            semaphore.wait()
        }
        return result
    }
}
