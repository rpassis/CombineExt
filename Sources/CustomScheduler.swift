//
//  CustomScheduler.swift
//  
//
//  Created by Rogerio de Paula Assis on 6/30/19.
//

import Combine
import Foundation

// TODO: Implement this based on RxSwift test scheduler
public struct CustomSchedulerOptions {}

extension Int: SchedulerTimeIntervalConvertible {
    
    public static func seconds(_ seconds: Int) -> Int {
        return seconds
    }
    
    public static func seconds(_ seconds: Double) -> Int {
        return Int(seconds)
    }
    
    public static func milliseconds(_ milliseconds: Int) -> Int {
        return Int(milliseconds)
    }
    
    public static func microseconds(_ microseconds: Int) -> Int {
        return Int(microseconds)
    }
    
    public static func nanoseconds(_ nanoseconds: Int) -> Int {
        return Int(nanoseconds)
    }
}

public struct CustomScheduler: Scheduler {
    
    public var now: SchedulerTimeType = 0
    public var minimumTolerance: SchedulerTimeType = 1
    
    public typealias SchedulerTimeType = Int
    public typealias SchedulerOptions = CustomSchedulerOptions

    public init() {}
    
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
