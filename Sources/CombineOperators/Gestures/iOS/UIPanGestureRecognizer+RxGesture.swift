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

#if canImport(UIKit) && os(iOS)

import UIKit
import Combine

@available(iOS 13.0, macOS 10.15, *)
public typealias PanConfiguration = Configuration<UIPanGestureRecognizer>
@available(iOS 13.0, macOS 10.15, *)
public typealias PanControlEvent = ControlEvent<UIPanGestureRecognizer>
@available(iOS 13.0, macOS 10.15, *)
public typealias PanPublisher = AnyPublisher<UIPanGestureRecognizer, Never>

@available(iOS 13.0, macOS 10.15, *)
extension Factory where Gesture == CombineGestureRecognizer {

    /**
     Returns an `AnyFactory` for `UIPanGestureRecognizer`
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public static func pan(configuration: PanConfiguration? = nil) -> AnyFactory {
        make(configuration: configuration).abstracted()
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension Reactive where Base: CombineGestureView {

    /**
     Returns an observable `UIPanGestureRecognizer` events sequence
     - parameter configuration: A closure that allows to fully configure the gesture recognizer
     */
    public func panGesture(configuration: PanConfiguration? = nil) -> PanControlEvent {
        gesture(make(configuration: configuration))
    }
}

@available(iOS 13.0, macOS 10.15, *)
extension Publisher where Output: UIPanGestureRecognizer {

    /**
     Maps the observable `GestureRecognizer` events sequence to an observable sequence of translation values of the pan gesture in the coordinate system of the specified `view` alongside the gesture velocity.

     - parameter view: A `TargetView` value on which the gesture took place.
     */
    public func asTranslation(in view: TargetView = .view) -> AnyPublisher<(translation: CGPoint, velocity: CGPoint), Failure> {
        self.map { gesture in
            let view = view.targetView(for: gesture)
            return (
                gesture.translation(in: view),
                gesture.velocity(in: view)
            )
        }
				.eraseToAnyPublisher()
    }
}

#endif
