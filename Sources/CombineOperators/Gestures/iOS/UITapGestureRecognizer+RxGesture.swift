// Copyright (c) CombineSwiftCommunity

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
#if os(OSX) || os(iOS)

#if canImport(UIKit)

import UIKit
import Combine

@available(iOS 13.0, macOS 10.15, *)
public typealias TapConfiguration = Configuration<UITapGestureRecognizer>
@available(iOS 13.0, macOS 10.15, *)
public typealias TapControlEvent = ControlEvent<UITapGestureRecognizer>
@available(iOS 13.0, macOS 10.15, *)
public typealias TapPublisher = AnyPublisher<UITapGestureRecognizer, Never>

@available(iOS 13.0, macOS 10.15, *)
extension Factory where Gesture == CombineGestureRecognizer {

    /**
     Returns an `AnyFactory` for `UITapGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func tap(configuration: TapConfiguration? = nil) -> AnyFactory {
        make(configuration: configuration).abstracted()
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension Reactive where Base: CombineGestureView {

    /**
     Returns an observable `UITapGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func tapGesture(configuration: TapConfiguration? = nil) -> TapControlEvent {
        gesture(make(configuration: configuration))
    }
}

#endif
#endif
