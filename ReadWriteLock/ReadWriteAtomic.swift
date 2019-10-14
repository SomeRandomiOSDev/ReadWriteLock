//
//  ReadWriteAtomic.swift
//  ReadWriteLock
//
//  Created by Joseph Newton on 10/14/19.
//  Copyright © 2019 SomeRandomiOSDev. All rights reserved.
//

import Foundation

// MARK: - ReadWriteAtomic Definition

#if swift(>=5.1)
@propertyWrapper
public struct ReadWriteAtomic<Value> {

    // MARK: Private Properties

    private let lock: ReadWriteLock
    private var value: Value

    // MARK: Initialization

    public init(initialValue: Value, _ lock: ReadWriteLock = ReadWriteLock()) {
        self.value = initialValue
        self.lock = lock
    }

    // MARK: Property Wrapper Requirements

    public var wrappedValue: Value {
        get { return lock.acquireReadLock { value } }
        set { lock.acquireWriteLock { value = newValue } }
    }
}
#endif // #if swift(>=5.1)
