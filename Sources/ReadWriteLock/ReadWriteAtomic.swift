//
//  ReadWriteAtomic.swift
//  ReadWriteLock
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif // #if canImport(SwiftUI)

#if swift(>=5.1)
// MARK: - ReadWriteAtomic Definition

@propertyWrapper
public struct ReadWriteAtomic<Value> {

    // MARK: Private Properties

    private let lock: ReadWriteLock
    private var value: Value

    // MARK: Initialization

    public init(wrappedValue: Value, lock: ReadWriteLock = ReadWriteLock()) {
        self.value = wrappedValue
        self.lock = lock
    }

    // MARK: PropertyWrapper Requirements

    public var wrappedValue: Value {
        get { return lock.acquireReadLock { value } }
        set { lock.acquireWriteLock { value = newValue } }
    }

    public var projectedValue: Binding {
        mutating get { Binding(root: &self) }
    }

    // MARK: ReadWriteAtomic.Binding Definition

    @propertyWrapper @dynamicMemberLookup public struct Binding {

        // MARK: Private Properties

        fileprivate let getter: () -> Value
        fileprivate let setter: (Value) -> Void

        // MARK: Public Properties

        #if canImport(SwiftUI) && !(arch(arm) || arch(i386)) // It appears that SwiftUI.Binding isn't available on 32-bit architectures
        @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
        public var binding: SwiftUI.Binding<Value> {
            return SwiftUI.Binding<Value>(get: getter, set: setter)
        }
        #endif // #if canImport(SwiftUI) && (!os(iOS) || !arch(arm))

        // MARK: Initialization

        fileprivate init(root: UnsafeMutablePointer<ReadWriteAtomic<Value>>) {
            self.init(get: { root.pointee.wrappedValue },
                      set: { root.pointee.wrappedValue = $0 })
        }

        fileprivate init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
            self.getter = get
            self.setter = set
        }

        // MARK: PropertyWrapper Requirements

        public var wrappedValue: Value {
            get { getter() }
            nonmutating set { setter(newValue) }
        }

        public var projectedValue: Binding { self }

        // MARK: DynamicMemberLookup Requirements

        public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, Subject>) -> ReadWriteAtomic<Subject>.Binding {
            let get = { self.getter()[keyPath: keyPath] }
            let set = { self.getter()[keyPath: keyPath] = $0 }

            return .init(get: get, set: set)
        }

        public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> ReadWriteAtomic<Subject>.Binding {
            let get = { self.getter()[keyPath: keyPath] }
            let set = { (newValue: Subject) in
                var value = self.getter()
                value[keyPath: keyPath] = newValue
                self.setter(value)
            }

            return .init(get: get, set: set)
        }

        public subscript<Subject>(dynamicMember keyPath: KeyPath<Value, Subject>) -> ReadWriteAtomic<Subject>.Binding {
            let get = { self.getter()[keyPath: keyPath] }
            let set = { (_: Subject) in /* Nothing to do */ }

            return .init(get: get, set: set)
        }
    }
}

// MARK: - ReadWriteAtomic Extension

extension ReadWriteAtomic where Value: ExpressibleByNilLiteral {

    // MARK: Initialization

    @inlinable public init(lock: ReadWriteLock) {
        self.init(wrappedValue: nil, lock: lock)
    }
}
#endif // #if swift(>=5.1)
