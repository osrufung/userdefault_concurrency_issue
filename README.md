# UserDefaults Concurrency Issue

This repository demonstrates a race condition in concurrent access to UserDefaults when implementing a singleton-like pattern.

## The Problem

The `visitorID()` function uses a common pattern for lazy initialization:

```swift
public static func visitorID() -> UUID {
    if let storedValue = UserDefaults.standard.string(forKey: UserDefaultKeys.visitorIDKey),
       let visitorID = UUID(uuidString: storedValue) {
        return visitorID
    } else {
        let visitorID = UUID()
        setVisitorID(visitorID)
        return visitorID
    }
}
```

This creates a **check-then-act race condition**. When multiple threads call this function simultaneously:

1. Thread A checks UserDefaults - finds nothing
2. Thread B checks UserDefaults - finds nothing
3. Thread A creates UUID #1 and writes it
4. Thread B creates UUID #2 and writes it

Result: Different threads receive different UUIDs, violating the singleton pattern.

## Reproducing the Issue

The test `testConcurrentAccessToVisitorIDIsConsistent` uses Swift's modern concurrency to expose this race condition:

```bash
swift test
```

The test creates 10,000 detached tasks that simultaneously call `visitorID()`. The race condition is detected in approximately 5-10% of test runs.

When the race occurs, you'll see output like:

```
⚠️ Race condition detected! Different UUIDs generated:
  ID 1: 1202A8C8-A796-44E3-B2C5-40DDEE72C33E (appeared 11 times)
  ID 2: 6105D937-1B77-4AAC-9347-3F6FFC3A4EC3 (appeared 989 times)
```

## Solution Approaches

To fix this race condition, consider:

1. **Using `NSLock` or other synchronization primitives** to protect the check-then-act sequence
2. **Using an `actor`** to serialize access to the visitor ID
3. **Using `OSAllocatedUnfairLock`** (macOS 13+) for lightweight locking
4. **Using dispatch_once equivalent** for true one-time initialization

## CI/CD

The GitHub Actions workflow runs tests automatically on every push and pull request, helping catch when the race condition occurs in CI.

## Requirements

- Swift 6.1+
- macOS 13+
