//
//  ReadWriteLock.swift
//  ReadWriteLock
//
//  Created by Joseph Newton on 6/6/19.
//  Copyright © 2019 SomeRandomiOSDev. All rights reserved.
//

import Darwin

// MARK: - ReadWriteLock Definition

public class ReadWriteLock {

    // MARK: Private Properties

    private var lock = pthread_rwlock_t()

    // MARK: Initialization

    public init() {
        pthread_rwlock_init(&lock, nil)
    }

    deinit {
        pthread_rwlock_destroy(&lock)
    }

    // MARK: Public Methods

    public func acquireReadLock<R>(_ action: () throws -> R) rethrows -> R {
        pthread_rwlock_rdlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }

        return try action()
    }

    public func acquireWriteLock<R>(_ action: () throws -> R) rethrows -> R {
        pthread_rwlock_wrlock(&lock)
        defer { pthread_rwlock_unlock(&lock) }

        return try action()
    }

    //

    public func attemptAcquireReadLock<R>(_ action: (Bool) throws -> R) rethrows -> R {
        let result: R

        if pthread_rwlock_tryrdlock(&lock) == 0 {
            defer { pthread_rwlock_unlock(&lock) }
            result = try action(true)
        } else {
            result = try action(false)
        }

        return result
    }

    public func attemptAcquireWriteLock<R>(_ action: (Bool) throws -> R) rethrows -> R {
        let result: R

        if pthread_rwlock_trywrlock(&lock) == 0 {
            defer { pthread_rwlock_unlock(&lock) }
            result = try action(true)
        } else {
            result = try action(false)
        }

        return result
    }
}
