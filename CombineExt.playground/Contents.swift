import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import UIKit
import CombineExt
import Combine

let vc = UIViewController()
let publisher = vc.methodInvoked(#selector(UIViewController.viewDidLoad))
publisher
    .print()
    .sink { any in
        print(any)
    }

vc.view
vc.viewDidLoad()
vc.isViewLoaded

