//: [Previous](@previous)

import Foundation
import Combine
import CombineExt

class VirtualTimeScheduler<Converter: VirtualTimeConverterType>: Scheduler {
    
    private let initialClock: SchedulerTimeType
    private let converter: Converter
    
    public var now: SchedulerTimeType {
        return self.converter.
    }
    public var minimumTolerance: SchedulerTimeType = 1
    
    public typealias SchedulerTimeType = Int
    public typealias SchedulerOptions = CustomSchedulerOptions
    
    public init(
        initialClock: SchedulerTimeType = 0,
        converter: Converter
    ) {
        self.initialClock = initialClock
        self.converter = converter
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType,
        tolerance: SchedulerTimeType,
        options: CustomSchedulerOptions?,
        _ action: @escaping () -> Void
        ) -> Cancellable {
        print("schedule after, tolerance, interval")
        fatalError()
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType,
        options: CustomSchedulerOptions?,
        _ action: @escaping () -> Void
        ) {
        print("schedule after, tolerance")
    }
    
    public func schedule(
        options: CustomSchedulerOptions?,
        _ action: @escaping () -> Void
        ) {
        action()
    }

}

let scheduler = VirtualTimeScheduler()
let subject = PassthroughSubject<Int, Error>()
let publisher = subject.eraseToAnyPublisher()
publisher
    .receive(on: scheduler)
    .sink { i in print(i) }

subject.send(1)


