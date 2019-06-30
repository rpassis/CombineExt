
import UIKit
import CombineExt
import PlaygroundSupport
import CombineExt
import Combine

class AnySubscription: Subscription {
    
    func request(_ demand: Subscribers.Demand) {
    }
    
    func cancel() {
    }
}

let publisher = AnyPublisher<Int, Error> { subscriber in
    subscriber.receive(subscription: AnySubscription())
    (1...10).map { $0 * 2 }.forEach { index in
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(index)) {
            _ = subscriber.receive(index)
            if index == 20 {
                subscriber.receive(completion: .finished)
            }
        }
    }
}

let subject = PassthroughSubject<Int, Error>()
let cancellable = publisher
    .map { $0 * $0 }
    .eraseToAnyPublisher()
    .debug()
    .subscribe(subject)

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
    cancellable.cancel()
}

PlaygroundPage.current.needsIndefiniteExecution = true
