//: [Previous](@previous)
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import Foundation
import CombineExt
import Combine

class MyClass {
    var videos: [Video] = []
}

struct Video: Decodable {
    let uri: String
}

let subject = PassthroughSubject<MaterialEvent<[Video], Error>, Never>()

let myClass = MyClass()
let publisher = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://api.vimeo.com")!)
    .map { $0.data }
    .decode(type: [Video].self, decoder: JSONDecoder())
    .materialize()
    .eraseToAnyPublisher()
    
