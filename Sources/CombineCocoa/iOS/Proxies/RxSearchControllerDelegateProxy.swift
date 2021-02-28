//
//  CombineSearchControllerDelegateProxy.swift
//  CombineCocoa
//
//  Created by Segii Shulga on 3/17/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import Combine
import UIKit

@available(iOS 13.0, macOS 10.15, *)
extension UISearchController: HasDelegate {
    public typealias Delegate = UISearchControllerDelegate
}

/// For more information take a look at `DelegateProxyType`.
@available(iOS 13.0, macOS 10.15, *)
open class CombineSearchControllerDelegateProxy
    : DelegateProxy<UISearchController, UISearchControllerDelegate>
    , DelegateProxyType 
    , UISearchControllerDelegate {

    /// Typed parent object.
    public weak private(set) var searchController: UISearchController?

    /// - parameter searchController: Parent object for delegate proxy.
    public init(searchController: UISearchController) {
        self.searchController = searchController
        super.init(parentObject: searchController, delegateProxy: CombineSearchControllerDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { CombineSearchControllerDelegateProxy(searchController: $0) }
    }
}
   
#endif
