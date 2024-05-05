//
//  File.swift
//  
//
//  Created by Данил Войдилов on 03.03.2021.
//

import Foundation
import Combine
import FoundationExtensions



@dynamicMemberLookup
@propertyWrapper
public struct ValueSubject<Output> {
	public typealias Failure = Never
	public var wrappedValue: Output {
		get { wrappedSubject.value }
		nonmutating set { wrappedSubject.value = newValue }
	}
    public var val: Output {
        get { wrappedSubject.value }
        nonmutating set { wrappedSubject.value = newValue }
    }
    public let wrappedSubject: CurrentValueSubject<Output, Never>

	public var projectedValue: ValueSubject<Output> { self }

    var cancelables = Set<AnyCancellable>()

	public init(wrappedValue: Output) {
        wrappedSubject = CurrentValueSubject(wrappedValue)
	}

    public init(_ wrappedValue: Output) {
        wrappedSubject = CurrentValueSubject(wrappedValue)
    }

    public init(_ another: ValueSubject<Output>) {
        self.wrappedSubject = another.wrappedSubject
    }

    public init<P: SyncroniusPublisher>(publisher: P, setter: ((Output) -> ())? = nil ) where Output: Equatable, P.Output == Output, P.Failure == Never {

		self.retained.append(publisher)

        wrappedSubject = CurrentValueSubject(publisher.wrappedValue)

        wrappedSubject
            .removeDuplicates()
            .sink {
                if publisher.wrappedValue != $0 {
                    setter?($0)
                }
            }
            .store(in: &cancelables)

        publisher
            .removeDuplicates()
            .sink(wrappedSubject)
            .store(in: &cancelables)

    }

	public var retained: [Any] = []

    public init<P: SyncroniusPublisher>(publisher: P,  setter: ((Output) -> ())? = nil ) where  P.Output == Output, P.Failure == Never {

		self.retained.append(publisher)

        wrappedSubject = CurrentValueSubject(publisher.wrappedValue)

        wrappedSubject
            .sink {
//                if publisher.wrappedValue != $0 {
                    setter?($0)
//                }
            }
            .store(in: &cancelables)

        publisher
            .sink(wrappedSubject)
            .store(in: &cancelables)


    }

//    init(another: ValueSubject) where Output == any Equatable {
//        self.ini
//        self.init(publusher: another, subscriber: another)
//    }

    public subscript<R>(dynamicMember keyPath: ReferenceWritableKeyPath<Output, R>) -> ValueSubject<R> where R: Equatable {
        var mapped = ValueSubject<R>(wrappedValue: wrappedValue[keyPath: keyPath])
        
        mapped
            .removeDuplicates()
            .sink {
                self.wrappedValue[keyPath: keyPath] = $0
            }
            .store(in: &mapped.cancelables)

        self
//            .removeDuplicates()
            .sink { 
                if mapped.wrappedValue != $0[keyPath: keyPath] {
                    mapped.wrappedValue = $0[keyPath: keyPath]
                }
            }
            .store(in: &mapped.cancelables)

        return mapped
//        let mapped = ValueSubject( )
//            publisher: self.map(keyPath),
//                                  setter: { mapped[keyPath: keyPath] = $0 })

//        ObservableChain<R, Failure>(observable: wrappedSubject.map { $0[keyPath: keyPath] }.any(), wrappedValue: wrappedValue[keyPath: keyPath])
    }

    public subscript<R>(dynamicMember keyPath: WritableKeyPath<Output, R>) -> ValueSubject<R> where R: Equatable {
        var mapped = ValueSubject<R>(wrappedValue: wrappedValue[keyPath: keyPath])

        mapped
            .removeDuplicates()
            .sink {
                self.wrappedValue[keyPath: keyPath] = $0
            }
            .store(in: &mapped.cancelables)

        self
        //            .removeDuplicates()
            .sink {
                if mapped.wrappedValue != $0[keyPath: keyPath] {
                    mapped.wrappedValue = $0[keyPath: keyPath]
                }
            }
            .store(in: &mapped.cancelables)

        return mapped
        //        let mapped = ValueSubject( )
        //            publisher: self.map(keyPath),
        //                                  setter: { mapped[keyPath: keyPath] = $0 })

        //        ObservableChain<R, Failure>(observable: wrappedSubject.map { $0[keyPath: keyPath] }.any(), wrappedValue: wrappedValue[keyPath: keyPath])
    }




	public subscript <R>(dynamicMember keyPath: KeyPath<Output, R>) -> ObservableChain<R, Failure> {
        ObservableChain<R, Failure>(observable: wrappedSubject.map { $0[keyPath: keyPath] }.any(), wrappedValue: wrappedValue[keyPath: keyPath])
	}

    public subscript <R>(dynamicMember keyPath: KeyPath<Output, R?>) -> ObservableChain<R?, Failure> {
        ObservableChain<R?, Failure>(observable: wrappedSubject.map { $0[keyPath: keyPath] }.any(), wrappedValue: wrappedValue[keyPath: keyPath])
    }
}
@dynamicMemberLookup
public struct ObservableChain<Output, Failure: Error> {
    let observable: AnyPublisher<Output, Failure>
    var cancelables: [AnyCancellable] = []
    public let wrappedValue: Output

    public subscript <R>(dynamicMember keyPath: KeyPath<Output, R>) -> ObservableChain<R, Failure> {
        ObservableChain<R, Failure>(observable: self.map { $0[keyPath: keyPath] }.any(), wrappedValue: wrappedValue[keyPath: keyPath] )
    }


    public subscript <R>(dynamicMember keyPath: KeyPath<Output, R?>) -> ObservableChain<R?, Failure> {
        ObservableChain<R?, Failure>(observable: self.map { $0[keyPath: keyPath] }.any(), wrappedValue: wrappedValue[keyPath: keyPath] )
    }
}

extension ObservableChain where Output: OptionalProtocol {
    public subscript <W, R>(dynamicMember keyPath: KeyPath<W, R>) -> ObservableChain<R?, Failure> where W == Output.Wrapped {
        ObservableChain<R?, Failure>(observable: self.map { $0.asOptional()?[keyPath: keyPath] }.any(), wrappedValue: wrappedValue.asOptional()?[keyPath: keyPath] )
    }
}



public protocol SyncroniusPublisher: Publisher where Failure == Never {
    var wrappedValue: Output { get }
}

extension SyncroniusPublisher {
    public func mapGet<R>(_ transform: @escaping (Output) -> R) -> ValueSubject<R> {
        var mappedPublisher = ValueSubject<R>(transform(wrappedValue))
        self.map(transform).sink(mappedPublisher).store(in: &mappedPublisher.cancelables)
		mappedPublisher.retained.append(self)
        return mappedPublisher

    }


    public func mapSubject<R>( get: @escaping (Output) -> R, set: @escaping (R) -> ()) -> ValueSubject<R> {
        var mappedPublisher = ValueSubject<R>(get(wrappedValue))
        self.map(get).sink(mappedPublisher).store(in: bag(mappedPublisher))

        mappedPublisher.sink { set($0) }.store(in: &mappedPublisher.cancelables)
		mappedPublisher.retained.append(self)

        return mappedPublisher
    }
}

extension CurrentValueSubject: SyncroniusPublisher where Failure == Never {
    public var wrappedValue: Output {
        value
    }


   


}

extension ValueSubject: SyncroniusPublisher {

}

extension ObservableChain: SyncroniusPublisher where Failure == Never  {

}

extension ObservableChain: Publisher {
	
	public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
		observable.receive(subscriber: subscriber)
	}
	
	public typealias Output = Output
	
	public typealias Failure = Failure
	
}


extension CurrentValueSubject: Subscriber {
	public func receive(completion: Subscribers.Completion<Failure>) {
		
	}
	
	public func receive(_ input: Output) -> Subscribers.Demand {
		value = input
		return .unlimited
	}
	
	public func receive(subscription: Subscription) {
		subscription.request(.unlimited)
	}
	
	public typealias Input = Output
}



extension ValueSubject: Subscriber {
	public var combineIdentifier: CombineIdentifier {
        wrappedSubject.combineIdentifier
	}
	
	public func receive(completion: Subscribers.Completion<Failure>) {
        wrappedSubject.receive(completion: completion)
	}
	
	public func receive(_ input: Output) -> Subscribers.Demand {
        return wrappedSubject.receive(input)
	}
	
	public func receive(subscription: Subscription) {
		subscription.request(.unlimited)
	}
	
	public typealias Input = Output
}

extension ValueSubject: Publisher {
	public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        wrappedSubject.receive(subscriber: subscriber)
	}
	
	
}


public typealias Rx = ValueSubject
