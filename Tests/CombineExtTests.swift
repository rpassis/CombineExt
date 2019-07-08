//
//  CombineExtTests.swift
//  CombineExtTests
//
//  Created by Rogerio de Paula Assis on Jun 30, 2019.
//  Copyright © 2019 CombineExt. All rights reserved.
//

@testable import CombineExt
import XCTest

class CombineExtTests: XCTestCase {
    
    static var allTests = [
        ("testExample", testExample),
    ]
    
    func testExample() {
        
        // Given
        let vc = UIViewController()
        let publisher = vc.methodInvoked(#selector(UIViewController.viewDidLoad))
        let expectation = self.expectation(description: "View did load expectation")
        _ = publisher.sink { values in
            
            // Then
            XCTAssertEqual(values.count, 0)
            expectation.fulfill()
        }
        // When
        vc.viewDidLoad()
        self.wait(for: [expectation], timeout: 1.0)
    }
    
}
