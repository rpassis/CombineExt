//
//  NSObject+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//
//  This is a direct port of RxSwift's implementation of `methodInvoked`
//  to be used with the Combine framework.
//  See https://github.com/ReactiveX/RxSwift/blob/master/RxCocoa/Foundation/NSObject%2BRx.swift
//  for the original source and additional documentation.

import Combine
import UIKit

public enum CombineCocoaError: Swift.Error {
    case unknown
}

private let deallocSelector = NSSelectorFromString("dealloc")
private var deallocatedSubjectContext: UInt8 = 0

private protocol MessageInterceptorSubject: class {
    init()
    
    var isActive: Bool {
        get
    }
    
    var targetImplementation: IMP { get set }
}

private protocol RXMessageSentObserver {}

extension NSObject {
    
    public func methodInvoked(_ selector: Selector) -> AnyPublisher<[Any], Error> {
        return self.synchronized {
            // in case of dealloc selector replay subject behavior needs to be used
             if selector == deallocSelector {
                return self.deallocated.map { _ in [] }.eraseToAnyPublisher()
             }
            
            do {
                let proxy: MessageSentProxy = try self.registerMessageInterceptor(selector)
                return proxy.methodInvoked.eraseToAnyPublisher()
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
    }
    
    private final class DeallocatingProxy: MessageInterceptorSubject, RXDeallocatingObserver {
    
        // swiftlint:disable nesting
        typealias Element = ()
        
        let messageSent = CurrentValueSubject<Void, Error>(())
        
        @objc var targetImplementation: IMP = RX_default_target_implementation()
        
        var isActive: Bool {
            return self.targetImplementation != RX_default_target_implementation()
        }
        
        init() {
        }
        
        @objc func deallocating() {
            self.messageSent.send(())
        }
        
        deinit {
            self.messageSent.send(completion: .finished)
        }
    }
    
    private final class MessageSentProxy: MessageInterceptorSubject, RXMessageSentObserver {
        
        // swiftlint:disable nesting
        typealias Element = [AnyObject]
        
        let messageSent = PassthroughSubject<[Any], Error>()
        let methodInvoked = PassthroughSubject<[Any], Error>()
        
        @objc var targetImplementation: IMP = RX_default_target_implementation()
        
        var isActive: Bool {
            return self.targetImplementation != RX_default_target_implementation()
        }
        
        init() {}
        
        @objc func messageSent(withArguments arguments: [Any]) {
            self.messageSent.send(arguments)
        }
        
        @objc func methodInvoked(withArguments arguments: [Any]) {
            self.methodInvoked.send(arguments)
        }
        
        deinit {
            self.messageSent.send(completion: .finished)
            self.methodInvoked.send(completion: .finished)
        }
    }
    
    private func registerMessageInterceptor<T: MessageInterceptorSubject>(_ selector: Selector) throws -> T {
        
        let rxSelector = RX_selector(selector)
        let selectorReference = RX_reference_from_selector(rxSelector)
        
        let subject: T
        if let existingSubject = objc_getAssociatedObject(self, selectorReference) as? T {
            subject = existingSubject
        } else {
            subject = T()
            objc_setAssociatedObject(
                self,
                selectorReference,
                subject,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        if subject.isActive {
            return subject
        }
        
        var error: NSError?
        guard let targetImplementation = RX_ensure_observing(self, selector, &error) else {
            throw CombineCocoaError.unknown
        }
        
        subject.targetImplementation = targetImplementation
        
        return subject
    }
    
    private var deallocating: AnyPublisher<(), Error> {
        return self.synchronized {
            do {
                let proxy: DeallocatingProxy = try self.registerMessageInterceptor(deallocSelector)
                return proxy.messageSent.eraseToAnyPublisher()
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
    }

    private var deallocated: AnyPublisher<Void, Error> {
        return self.synchronized {
            if let deallocObservable =
                objc_getAssociatedObject(self, &deallocatedSubjectContext) as? DeallocObservable {
                return deallocObservable.publisher
            }
            
            let deallocObservable = DeallocObservable()
            
            objc_setAssociatedObject(
                self,
                &deallocatedSubjectContext,
                deallocObservable,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            return deallocObservable.publisher
        }
    }

    private func synchronized<T>( _ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
}

private final class DeallocObservable {
    
    let subject = CurrentValueSubject<Void, Error>(())
    lazy var publisher: AnyPublisher<Void, Error> = subject.dropFirst().eraseToAnyPublisher()
    
    init() {}
    
    deinit {
        self.subject.send(())
        self.subject.send(completion: .finished)
    }
}

private func combineSelector(_ selector: Selector) -> Selector {
    let selectorString = NSStringFromSelector(selector)
    return NSSelectorFromString("combine_\(selectorString)")
}
