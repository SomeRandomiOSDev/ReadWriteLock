//
//  ReadWriteLockTests.swift
//  ReadWriteLockTests
//
//  Created by Joseph Newton on 6/6/19.
//  Copyright © 2019 SomeRandomiOSDev. All rights reserved.
//

import ReadWriteLock
import XCTest

// MARK: - ReadWriteLockTests Definition

class ReadWriteLockTests: XCTestCase {

    // MARK: Test Methods

    func testNestedReadLocks() {
        var array: [Int] = []
        let lock = ReadWriteLock()

        lock.acquireReadLock {
            lock.acquireReadLock {
                lock.acquireReadLock {
                    lock.acquireReadLock {
                        lock.acquireReadLock {
                            array.append(1)
                        }
                        array.append(2)
                    }
                    array.append(3)
                }
                array.append(4)
            }
            array.append(5)
        }

        XCTAssertEqual(array, [1, 2, 3, 4, 5])
    }

    func testMultipleWriteLocks() {
        var array: [Int] = [1]
        let lock = ReadWriteLock()
        let wait = DispatchSemaphore(value: 0)

        lock.acquireWriteLock {
            DispatchQueue.global(qos: .default).async {
                lock.acquireWriteLock {
                    XCTAssertEqual(array, [1, 2])
                    wait.signal()
                }
            }

            _ = DispatchSemaphore(value: 0).wait(timeout: .now() + 0.2)
            array.append(2)
        }

        wait.wait()
    }

    func testWriteLockThenReadLock() {
        var array: [Int] = [1]
        let lock = ReadWriteLock()
        let wait = DispatchSemaphore(value: 0)

        lock.acquireWriteLock {
            DispatchQueue.global(qos: .default).async {
                lock.acquireReadLock {
                    XCTAssertEqual(array, [1, 2])
                    wait.signal()
                }
            }

            _ = DispatchSemaphore(value: 0).wait(timeout: .now() + 0.15)
            array.append(2)
        }

        wait.wait()
    }

    func testReadLockThenWriteLock() {
        var array: [Int] = [1]
        let lock = ReadWriteLock()
        let wait = DispatchSemaphore(value: 0)

        lock.acquireReadLock {
            DispatchQueue.global(qos: .default).async {
                lock.acquireWriteLock {
                    XCTAssertEqual(array, [1, 2])
                    wait.signal()
                }
            }

            _ = DispatchSemaphore(value: 0).wait(timeout: .now() + 0.15)
            array.append(2)
        }

        wait.wait()
    }

    //

    func testTryReadLock() {
        let lock = ReadWriteLock()
        lock.attemptAcquireReadLock {
            XCTAssertTrue($0)
        }
    }

    func testTryWriteLock() {
        let lock = ReadWriteLock()
        lock.attemptAcquireWriteLock {
            XCTAssertTrue($0)
        }
    }

    func testNestedTryReadLocks() {
        var array: [Int] = []
        let lock = ReadWriteLock()

        lock.attemptAcquireReadLock { success1 in
            XCTAssertTrue(success1)

            lock.attemptAcquireReadLock { success2 in
                XCTAssertTrue(success2)

                lock.attemptAcquireReadLock { success3 in
                    XCTAssertTrue(success3)

                    lock.attemptAcquireReadLock { success4 in
                        XCTAssertTrue(success4)

                        lock.attemptAcquireReadLock { success5 in
                            XCTAssertTrue(success5)
                            array.append(1)
                        }
                        array.append(2)
                    }
                    array.append(3)
                }
                array.append(4)
            }
            array.append(5)
        }

        XCTAssertEqual(array, [1, 2, 3, 4, 5])
    }

    func testTryWriteLocksAfterWriteLock() {
        let lock = ReadWriteLock()

        lock.acquireWriteLock {
            let wait = DispatchSemaphore(value: 0)

            DispatchQueue.global(qos: .default).async {
                lock.attemptAcquireWriteLock { success in
                    XCTAssertFalse(success)
                    wait.signal()
                }
            }

            wait.wait()
        }
    }

    func testTryReadLockAfterWriteLock() {
        let lock = ReadWriteLock()

        lock.acquireWriteLock {
            let wait = DispatchSemaphore(value: 0)

            DispatchQueue.global(qos: .default).async {
                lock.attemptAcquireReadLock { success in
                    XCTAssertFalse(success)
                    wait.signal()
                }
            }

            wait.wait()
        }
    }

    func testTryWriteLockAfterReadLock() {
        let lock = ReadWriteLock()

        lock.acquireReadLock {
            let wait = DispatchSemaphore(value: 0)

            DispatchQueue.global(qos: .default).async {
                lock.attemptAcquireWriteLock { success in
                    XCTAssertFalse(success)
                    wait.signal()
                }
            }

            wait.wait()
        }
    }

    #if swift(>=5.1)
    func testSynchronizedPropertyWrapper() {
        //swiftlint:disable nesting let_var_whitespace
        class Dummy {
            @ReadWriteAtomic(initialValue: "String!")
            var syncedString: String
        }
        //swiftlint:enable nesting let_var_whitespace

        let dummy = Dummy()
        XCTAssertEqual(dummy.syncedString, "String!")

        dummy.syncedString = "String?"
        XCTAssertEqual(dummy.syncedString, "String?")
    }
    #endif // #if swift(>=5.1)
}
