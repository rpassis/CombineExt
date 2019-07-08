//
//  MethodInvokedTests.swift
//  CombineExt
//
//  Created by Rogerio de Paula Assis on 7/8/19.
//  Copyright © 2019 CombineExt. All rights reserved.
//

import XCTest
@testable import CombineExt

class MethodInvokedTests: XCTestCase {

    private let object = UIViewController()
    
    func testMethodInvokedNoArgs() {
        
        // Given
        let publisher = object.methodInvoked(#selector(UIViewController.viewDidLoad))
        let expectation = self.expectation(description: "UIViewController.viewDidLoad expectation")
        _ = publisher.sink { values in
            
            // Then
            XCTAssertEqual(values.count, 0)
            expectation.fulfill()
        }
        
        // When
        object.viewDidLoad()
        self.wait(for: [expectation], timeout: 1.0)
    }
    
    func testMethodInvokedSingleArg() {
        
        // Given
        let publisher = object.methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
        let expectation = self.expectation(description: "UIViewController.viewDidAppear(_:) expectation")
        _ = publisher.sink { values in
            
            // Then
            XCTAssertEqual(values.count, 1)
            XCTAssertEqual(values.first as? Bool, true)
            expectation.fulfill()
        }
        
        // When
        object.viewDidAppear(true)
        self.wait(for: [expectation], timeout: 1.0)
    }
    
    func testMethodInvokedMultipleArgs() {
        
        // Given
        let publisher = object.methodInvoked(#selector(UIViewController.canPerformAction(_:withSender:)))
        let expectation = self.expectation(description: "UIViewController.canPerformAction(_:withSender:)")
        _ = publisher.sink { values in
            
            // Then
            XCTAssertEqual(values.count, 2)
            XCTAssertEqual(values.last as? XCTestCase, self)
            expectation.fulfill()
        }
        
        // When
        object.canPerformAction(#selector(UIViewController.viewDidLoad), withSender: self)
        self.wait(for: [expectation], timeout: 1.0)
        
    }

}
