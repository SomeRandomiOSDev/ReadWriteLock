//
//  ReadWriteAtomicTests.swift
//  ReadWriteLockTests
//
//  Copyright © 2021 SomeRandomiOSDev. All rights reserved.
//

#if swift(>=5.1)
import ReadWriteLock
import XCTest

#if canImport(SwiftUI)
import SwiftUI
#endif // #if canImport(SwiftUI)

// MARK: - ReadWriteAtomicTests Definition

class ReadWriteAtomicTests: XCTestCase {

    // MARK: Test Methods

    func testGetAndSetValue() {
        @ReadWriteAtomic var syncedString: String = "String!"
        XCTAssertEqual(syncedString, "String!")

        syncedString = "String?"
        XCTAssertEqual(syncedString, "String?")
    }

    func testGetAndSetValueWithBinding() {
        struct Dummy {
            @ReadWriteAtomic.Binding var binding: String
        }

        @ReadWriteAtomic var syncedString: String = "String!"
        var dummy = Dummy(binding: $syncedString)

        //

        do {
            XCTAssertEqual(dummy.binding, "String!")

            dummy.binding = "String?"
            XCTAssertEqual(dummy.binding, "String?")
        }
        do {
            dummy = Dummy(binding: dummy.$binding)
            XCTAssertEqual(dummy.binding, "String?")

            dummy.binding = "String!"
            XCTAssertEqual(dummy.binding, "String!")
        }
    }

    func testGetAndSetValueViaDynamicMemberLookup() {
        do {
            class Dummy {
                var string: String = "String!"
            }

            @ReadWriteAtomic var dummy = Dummy()
            let syncedString = $dummy.string

            //

            XCTAssertEqual(syncedString.wrappedValue, "String!")

            syncedString.wrappedValue = "String?"
            XCTAssertEqual(syncedString.wrappedValue, "String?")
        }
        do {
            struct Dummy {
                var string: String = "String!"
            }

            @ReadWriteAtomic var dummy = Dummy()
            let syncedString = $dummy.string

            //

            XCTAssertEqual(syncedString.wrappedValue, "String!")

            syncedString.wrappedValue = "String?"
            XCTAssertEqual(syncedString.wrappedValue, "String?")
        }
        do {
            struct Dummy {
                let string: String = "String!"
            }

            @ReadWriteAtomic var dummy = Dummy()
            let syncedString = $dummy.string

            //

            XCTAssertEqual(syncedString.wrappedValue, "String!")

            syncedString.wrappedValue = "String?"
            XCTAssertEqual(syncedString.wrappedValue, "String!")
        }
    }

    func testInitializeWithNullableValue() {
        let lock = ReadWriteLock()
        @ReadWriteAtomic(lock: lock) var value: String?
        XCTAssertNil(value)

        value = "String!"
        XCTAssertNotNil(value)
        XCTAssertEqual(value, "String!")
    }

    #if canImport(SwiftUI) && !(arch(arm) || arch(i386))
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testGetAndSetValueWithSwiftUIBinding() {
        struct Dummy {
            @Binding var binding: String
        }

        @ReadWriteAtomic var syncedString: String = "String!"
        let dummy = Dummy(binding: $syncedString.binding)

        XCTAssertEqual(dummy.binding, "String!")

        dummy.binding = "String?"
        XCTAssertEqual(dummy.binding, "String?")
    }
    #endif // #if canImport(SwiftUI) && !(arch(arm) || arch(i386))
}
#endif // #if swift(>=5.1)
