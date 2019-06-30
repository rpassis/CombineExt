//
//  AnyPublisher+Debug.swift
//  CombineExt
//
//  Created by Rogerio de Paula Assis on 6/30/19.
//  Copyright © 2019 CombineExt. All rights reserved.
//

import Combine
import Foundation

extension AnyPublisher {
    
    public func debug(prefix: String = String()) -> AnyPublisher {
        return self.handleEvents(receiveSubscription: { subscription in
            Swift.print("\(prefix) [SUBSCRIBED]: \(subscription)")
        }, receiveOutput: { output in
            Swift.print("\(prefix) [RECEIVED]: \(output)")
        }, receiveCompletion: { completion in
            Swift.print("\(prefix) [COMPLETED]: \(completion)")
        }, receiveCancel: {
            Swift.print("\(prefix) [CANCELLED]")
        }).eraseToAnyPublisher()
    }
    
}
