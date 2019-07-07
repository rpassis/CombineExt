//
//  Publisher+Materialize.swift
//  
//
//  Created by Rogerio de Paula Assis on 7/6/19.
//

import Combine
import Foundation

public enum MaterialEvent<T, E: Error>: Error {
    case error(E)
    case next(T)
    case completed
}

extension Publishers {
    
    public struct Materialized<Upstream>: Publisher where Upstream: Publisher {
        
        //swiftlint:disable nesting
        public typealias Output = MaterialEvent<Upstream.Output, Upstream.Failure>
        public typealias Failure = MaterialEvent<Upstream.Output, Upstream.Failure>
        
        /// The publisher from which this publisher receives elements.
        public let upstream: AnyPublisher<Upstream.Output, Upstream.Failure>
        
        public init(upstream: Upstream) {
            self.upstream = upstream.eraseToAnyPublisher()
        }
        
        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let sink = AnySubscriber<Upstream.Output, Upstream.Failure>(receiveSubscription: { subscription in
                subscriber.receive(subscription: subscription)
            }, receiveValue: { materialEvent -> Subscribers.Demand in
                Swift.print("next event received")
                return subscriber.receive(MaterialEvent.next(materialEvent))
            }, receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    _ = subscriber.receive(MaterialEvent.error(error))
                    subscriber.receive(completion: .finished)
                case .finished:
                    subscriber.receive(completion: .finished)
                }
            })
            self.upstream.subscribe(sink)
        }
        
    }
}

extension Publisher {
    
    /**
     Convert any Publisher into a Publisher of its materialized events.
     - returns: A sequence that wraps events in MaterializedEvent<T, E>. The returned Publisher never errors, but it does complete after receiving all of the events of the underlying Publisher.
     */    
    public func materialize() -> Publishers.Materialized<Self> {
        return Publishers.Materialized(upstream: self)
    }
}
