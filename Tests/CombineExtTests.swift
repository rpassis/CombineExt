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
        let vc = UIViewController()
        let publisher = vc.methodInvoked(#selector(UIViewController.viewDidLoad))
        let expectation = self.expectation(description: "View did load expectation")
        _ = publisher.print().sink { values in
            print(values)
            expectation.fulfill()
        }
        vc.viewDidLoad()
        self.wait(for: [expectation], timeout: 5.0)
        
    }
    
}
