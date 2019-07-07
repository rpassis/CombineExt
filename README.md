<p align="left">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
   <a href="http://cocoapods.org/pods/CombineExt">
      <img src="https://img.shields.io/cocoapods/v/CombineExt.svg?style=flat" alt="Version">
   </a>
   <a href="http://cocoapods.org/pods/CombineExt">
      <img src="https://img.shields.io/cocoapods/p/CombineExt.svg?style=flat" alt="Platform">
   </a>
   <a href="https://github.com/Carthage/Carthage">
      <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible">
   </a>
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
   </a>
</p>

# CombineExt

<p align="left">
Useful extensions, tools, recipes and Playground experiments to help adopting Apple's Combine framework
</p>

Operators
===========

* [unwrap](#unwrap)
* [materialize](#materialize)

Operator details
===========

#### unwrap

Unwrap optionals and filter out nil values.

```swift
  Publishers.of(1,2,nil,Int?(4))
    .unwrap()
    .subscribe { print($0) }
```

```
next(1)
next(2)
next(4)
```

#### materialize

Turns type <T, E: Error> events into MaterilEvent<T E: Error>.
The returned Publisher never errors, and does complete after observing all of the events of the underlying Publisher.


```swift
  URLSession.shared
    .dataTaskPublisher(for: url)
    .map { $0.data }
    .decode(type: [MyModel].self, decoder: JSONDecoder())
    .materialize()
```

## Contributing
Contributions are very welcome 🙌

## License

```
CombineExt
Copyright (c) 2019 CombineExt rogerio@vimeo.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
