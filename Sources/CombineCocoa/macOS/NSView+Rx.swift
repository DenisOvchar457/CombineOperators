//
//  NSView+Combine.swift
//  CombineCocoa
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)
    import Cocoa
    import Combine

@available(iOS 13.0, macOS 10.15, *)
extension Reactive where Base: NSView {
        /// Bindable sink for `alphaValue` property.
        public var alpha: Binder<CGFloat> {
            return Binder(self.base) { view, value in
                view.alphaValue = value
            }
        }
    }
#endif
