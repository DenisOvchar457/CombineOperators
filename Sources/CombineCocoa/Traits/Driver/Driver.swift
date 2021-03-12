//
//  Driver.swift
//  CombineCocoa
//
//  Created by Krunoslav Zaher on 9/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Combine
import CombineOperators

/**
 Trait that represents observable sequence with following properties:

 - it never fails
 - it delivers events on `MainScheduler.instance`
 - `share(replay: 1, scope: .whileConnected)` sharing strategy
 
 Additional explanation:
 - all observers share sequence computation resources
 - it's stateful, upon subscription (calling subscribe) last element is immediately replayed if it was produced
 - computation of elements is reference counted with respect to the number of observers
 - if there are no subscribers, it will release sequence computation resources

 In case trait that models event bus is required, please check `Signal`.

 `Driver<Element>` can be considered a builder pattern for observable sequences that drive the application.

 If observable sequence has produced at least one element, after new subscription is made last produced element will be
 immediately replayed on the same thread on which the subscription was made.

 When using `drive*`, `subscribe*` and `bind*` family of methods, they should always be called from main thread.

 If `drive*`, `subscribe*` and `bind*` are called from background thread, it is possible that initial replay
 will happen on background thread, and subsequent events will arrive on main thread.

 To find out more about traits and how to use them, please visit `Documentation/Traits.md`.
 */


@available(iOS 13.0, macOS 10.15, *)
extension Publisher {
	
	public func asDriver() -> Driver<Output> {
		Driver(self.skipFailure())
	}

	public func asDriver(replaceError: Output) -> Driver<Output> {
		Driver(self) { _ in Just(replaceError) }
	}
	
	public func asDriver<C: Publisher>(catch handler: @escaping (Error) -> C) -> Driver<Output> where C.Output == Output {
		Driver(self, catch: handler)
	}
	
}

@available(iOS 13.0, macOS 10.15, *)
public struct Driver<Output>: Publisher {
	public typealias Failure = Never
	private let publisher: AnyPublisher<Output, Failure>
	
	public init<P: Publisher, C: Publisher>(_ source: P, catch handler: @escaping (Error) -> C) where C.Output == P.Output, C.Output == Output {
		self = Driver(source.catch(handler).skipFailure())
	}
	
	public init<P: Publisher>(_ source: P) where Never == P.Failure, P.Output == Output {
		publisher = source.share(replay: 1).eraseToAnyPublisher()
	}
	
	public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
		publisher.receive(subscriber: MainQueueSubscriber(subscriber: subscriber))
	}
}

final class MainQueueSubscriber<S: Subscriber>: Subscriber {
	typealias Input = S.Input
	typealias Failure = S.Failure
	let subscriber: S
	var combineIdentifier: CombineIdentifier { subscriber.combineIdentifier }
	private var demand: Subscribers.Demand = .unlimited
	private let lock = NSRecursiveLock()
	
	init(subscriber: S) {
		self.subscriber = subscriber
	}
	
	func receive(subscription: Subscription) {
		onMain {
			self.subscriber.receive(subscription: subscription)
		}
	}
	
	func receive(_ input: S.Input) -> Subscribers.Demand {
		if Thread.isMainThread {
			let _demand = subscriber.receive(input)
			lock.protect {
				demand = _demand
			}
			return _demand
		} else {
			DispatchQueue.main.async {
				self.lock.protect {
					self.demand = self.subscriber.receive(input)
				}
			}
			let _demand = lock.protect {
				demand - 1
			}
			return _demand
		}
	}
	
	func receive(completion: Subscribers.Completion<S.Failure>) {
		onMain {
			self.subscriber.receive(completion: completion)
		}
	}
	
	@inlinable
	func onMain(_ action: @escaping () -> Void) -> Void {
		if Thread.isMainThread {
			action()
		} else {
			DispatchQueue.main.async(execute: action)
		}
	}
}
