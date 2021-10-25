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
        struct Dummy {
            @ReadWriteAtomic var syncedString: String = "String!"
        }

        var dummy = Dummy()
        XCTAssertEqual(dummy.syncedString, "String!")

        dummy.syncedString = "String?"
        XCTAssertEqual(dummy.syncedString, "String?")
    }

    func testGetAndSetValueWithBinding() {
        struct StringDummy {
            @ReadWriteAtomic var syncedString: String = "String!"
        }
        struct Dummy {
            @ReadWriteAtomic.Binding var binding: String
        }

        var stringDummy = StringDummy()
        var dummy = Dummy(binding: stringDummy.$syncedString)

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
            class StringDummy {
                var string = "String!"
            }
            class Dummy {
                @ReadWriteAtomic var dummy = StringDummy()
            }

            let dummy = Dummy()
            let syncedString = dummy.$dummy.string

            //

            XCTAssertEqual(syncedString.wrappedValue, "String!")

            syncedString.wrappedValue = "String?"
            XCTAssertEqual(syncedString.wrappedValue, "String?")
        }
        do {
            struct StringDummy {
                var string = "String!"
            }
            struct Dummy {
                @ReadWriteAtomic var dummy = StringDummy()
            }

            var dummy = Dummy()
            let syncedString = dummy.$dummy.string

            //

            XCTAssertEqual(syncedString.wrappedValue, "String!")

            syncedString.wrappedValue = "String?"
            XCTAssertEqual(syncedString.wrappedValue, "String?")
        }
        do {
            struct StringDummy {
                let string: String = "String!"
            }
            struct Dummy {
                @ReadWriteAtomic var dummy = StringDummy()
            }

            var dummy = Dummy()
            let syncedString = dummy.$dummy.string

            //

            XCTAssertEqual(syncedString.wrappedValue, "String!")

            syncedString.wrappedValue = "String?"
            XCTAssertEqual(syncedString.wrappedValue, "String!")
        }
    }

    func testInitializeWithNullableValue() {
        class Dummy {
            @ReadWriteAtomic var value: String?

            init() {
                _value = ReadWriteAtomic(lock: ReadWriteLock())
            }
        }

        let dummy = Dummy()
        XCTAssertNil(dummy.value)

        dummy.value = "String!"
        XCTAssertNotNil(dummy.value)
        XCTAssertEqual(dummy.value, "String!")
    }

    #if canImport(SwiftUI) && !(arch(arm) || arch(i386))
    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    func testGetAndSetValueWithSwiftUIBinding() {
        struct StringDummy {
            @ReadWriteAtomic var syncedString = "String!"
        }
        struct Dummy {
            @Binding var binding: String
        }

        var stringDummy = StringDummy()
        let dummy = Dummy(binding: stringDummy.$syncedString.binding)

        XCTAssertEqual(dummy.binding, "String!")

        dummy.binding = "String?"
        XCTAssertEqual(dummy.binding, "String?")
    }
    #endif // #if canImport(SwiftUI) && !(arch(arm) || arch(i386))
}
#endif // #if swift(>=5.1)
