# ReadWriteLock

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d30d31c29f17449481b97a04610ff5b9)](https://app.codacy.com/app/SomeRandomiOSDev/ReadWriteLock?utm_source=github.com&utm_medium=referral&utm_content=SomeRandomiOSDev/ReadWriteLock&utm_campaign=Badge_Grade_Dashboard)
[![License MIT](https://img.shields.io/cocoapods/l/ReadWriteLock.svg)](https://cocoapods.org/pods/ReadWriteLock)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ReadWriteLock.svg)](https://cocoapods.org/pods/ReadWriteLock) 
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![Platform](https://img.shields.io/cocoapods/p/ReadWriteLock.svg)](https://cocoapods.org/pods/ReadWriteLock)
[![Code Coverage](https://codecov.io/gh/SomeRandomiOSDev/ReadWriteLock/branch/master/graph/badge.svg)](https://codecov.io/gh/SomeRandomiOSDev/ReadWriteLock)

![Swift Package](https://github.com/SomeRandomiOSDev/ReadWriteLock/workflows/Swift%20Package/badge.svg)
![Xcode Project](https://github.com/SomeRandomiOSDev/ReadWriteLock/workflows/Xcode%20Project/badge.svg)
![Cocoapods](https://github.com/SomeRandomiOSDev/ReadWriteLock/workflows/Cocoapods/badge.svg)
![Carthage](https://github.com/SomeRandomiOSDev/ReadWriteLock/workflows/Carthage/badge.svg)

**ReadWriteLock** is a lightweight framework of a safe an easy implementation of a read-write lock for iOS, macOS, tvOS, and watchOS.

## Installation

**ReadWriteLock** is available through [CocoaPods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage) and the [Swift Package Manager](https://swift.org/package-manager/). 

To install via CocoaPods, simply add the following line to your Podfile:

```ruby
pod 'ReadWriteLock'
```

To install via Carthage, simply add the following line to your Cartfile:

```ruby
github "SomeRandomiOSDev/ReadWriteLock"
```

To install via the Swift Package Manager add the following line to your `Package.swift` file's `dependencies`:

```swift
.package(url: "https://github.com/SomeRandomiOSDev/ReadWriteLock.git", from: "1.0.0")
```

## Usage

First import **ReadWriteLock** at the top of your Swift file:

```swift
import ReadWriteLock
```

After importing simply instantiate a `ReadWriteLock` instance and start acquiring locks:

```swift
let lock = ReadWriteLock()
var protectedResource = ...

DispatchQueue.global(qos: .background).async {
    ...

    lock.acquireWriteLock {
        protectedResource = ...
    }
}

...

DispatchQueue.global(qos: .background).async {
    ...
    
    lock.acquireReadLock {
        process(protectedResource)
    }
}
```

Or you can conditionally attempt to acquire a lock. Acquiring a lock in this way will not block if the lock has already been claimed:

```swift
...

lock.attemptAcquireReadLock { isLockAcquired in
    if isLockAcquired {
        process(protectedResource)
    } else {
        // `lock` is currently locked for writing. 
    }
}
```

Acquiring locks uses Swift closures to scope the lifetime of the read/write lock. This prevents lingering locks when the `ReadWriteLock` object is deallocated and helps prevent deadlocks. Note that if you attempt to acquire a write lock from inside of the scope of an already acquired read or write lock, or acquiring a read lock from inside of the scope of an already acquired write lock, the thread will deadlock:

```swift 
// All of these code blocks will deadlock

lock.acquireWriteLock {
    ...
    
    lock.acquireWriteLock {
        // deadlock
    }
}

lock.acquireReadLock {
    ...

    lock.acquireWriteLock {
        // deadlock
    }
}

lock.attemptAcquireWriteLock { isLockAcquired in
    ...

    if isLockAcquired {
        lock.acquireWriteLock {
            // deadlock
        }
    }
}

...
```

The benefit of read/write locks over traditional locks is that you may have (virtually) unlimited read locks, even nested read locks, without deadlocking:

```swift
lock.acquireReadLock {
    ...
    
    lock.acquireReadLock {
        // won't deadlock
    }
    
    lock.attemptAcquireReadLock { isLockAcquired in 
        // isLockAcquired is `true`
    }
}
```

Read/write locks are ideal for synchronizing access to properties:

```swift
struct SynchronizedValue<T> {
    private var lock = ReadWriteLock()
    private var _value: T
    
    var value: T {
        get {
            return lock.acquireReadLock { _value }
        }
        set {
            lock.acquireWriteLock { _value = newValue }
        }
    }
}
```

## Contributing

If you have need for a specific feature or you encounter a bug, please open an issue. If you extend the functionality of **ReadWriteLock** yourself or you feel like fixing a bug yourself, please submit a pull request.

## Author

Joe Newton, somerandomiosdev@gmail.com

## License

**ReadWriteLock** is available under the MIT license. See the `LICENSE` file for more info.
