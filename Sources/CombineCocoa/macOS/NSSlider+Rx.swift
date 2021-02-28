//
//  NSSlider+Combine.swift
//  CombineCocoa
//
//  Created by Junior B. on 24/05/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import Combine
import Cocoa
@available(iOS 13.0, macOS 10.15, *)
extension Reactive where Base: NSSlider {
    
    /// Reactive wrapper for `value` property.
    public var value: ControlProperty<Double> {
        return self.base.cb.controlProperty(
            getter: { control -> Double in
                return control.doubleValue
            },
            setter: { control, value in
                control.doubleValue = value
            }
        )
    }
    
}

#endif
