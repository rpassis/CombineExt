import UIKit
import Combine
import CombineExt
import PlaygroundSupport

/*:

 # Wrapping asynchronous operations using Publishers.Future
 Publishers.Future are single event publishers that will either emit one event and
 immediately complete, or fail with no events emitted.
 
*/

enum MyAsyncWorkerError: Error {
    case unknown
}

class MyAsyncWorker<T> {
    
    private let work: () -> T
    private let queue = DispatchQueue(label: "com.rdpa.queue")
    
    init(work: @escaping () -> T) {
        self.work = work
    }
    
    func performWork(then callback: @escaping (Result<T, MyAsyncWorkerError>) -> Void) {
        let random = Int.random(in: 1...5)
        queue.async { [work] in
            if random % 2 != 0 {
                callback(.success(work()))
            } else {
                callback(.failure(.unknown))
            }
        }
    }
}

extension MyAsyncWorker {
    
    func performWorkPublisher() -> AnyPublisher<T, MyAsyncWorkerError> {
        return Publishers.Future<T, MyAsyncWorkerError> { [work] promise in
            self.performWork { result in
                print("Work in on main thread? \(Thread.isMainThread)")
                switch result {
                case .success:
                    promise(.success(work()))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

let worker = MyAsyncWorker<Int>(work: { return 99 })
let publisher = worker.performWorkPublisher()
let cancellable = publisher
    .eraseToAnyPublisher()
    .debug(prefix: "[MyAsyncWorker]")
    //.receive(on: ImmediateScheduler.shared)
    .sink { _ in
        print("Sink is on main thread? \(Thread.isMainThread)")
    }

PlaygroundPage.current.needsIndefiniteExecution = true
