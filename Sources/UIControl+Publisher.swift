//
//  UIControl+Publisher.swift
//  CombineExt
//
//  Created by Rogerio de Paula Assis on 7/22/19.
//  Copyright © 2019 CombineExt. All rights reserved.
//

import Foundation
import Combine
import UIKit

extension UIControl {
    
    public func publisher(for controlEvents: UIControl.Event) -> Publishers.ControlEvent {
        return Publishers.ControlEvent(control: self, events: controlEvents)
    }
    
}

extension Publishers {
    
    public struct ControlEvent: Publisher {
        
        public typealias Output = UIControl
        public typealias Failure = Never
        
        private let control: UIControl
        private let events: UIControl.Event
        
        public init(control: UIControl, events: UIControl.Event) {
            self.control = control
            self.events = events
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = ControlSubscription(subscriber: subscriber, control: control, events: events)
            subscriber.receive(subscription: subscription)
        }
        
        private class ControlSubscription<S: Subscriber>: Subscription where S.Input == UIControl, S.Failure == Never {
            
            private var subscriber: S?
            
            init(subscriber: S, control: UIControl, events: UIControl.Event) {
                self.subscriber = subscriber
                control.addTarget(self, action: #selector(ControlSubscription.eventHandler), for: events)
            }
            
            func request(_ demand: Subscribers.Demand) {
                // No-op
            }
            
            func cancel() {
                subscriber = nil
            }
            
            @objc private func eventHandler(_ control: UIControl) {
                _ = subscriber?.receive(control)
            }
      
        }

        
    }
        
}
