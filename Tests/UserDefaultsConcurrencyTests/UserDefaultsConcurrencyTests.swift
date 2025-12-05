import XCTest
@testable import UserDefaultsConcurrency

final class UserDefaultsConcurrencyTests: XCTestCase {
    
    let testKey = "visitor_id"
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: testKey)
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: testKey)
        super.tearDown()
    }
    
    func testSetVisitorID() throws {
        let uuid = UUID()
        
        UserDefaultsConcurrency.setVisitorID(uuid)
        
        let storedValue = UserDefaults.standard.string(forKey: testKey)
        XCTAssertEqual(storedValue, uuid.uuidString)
    }
    
    func testVisitorIDReturnsStoredValue() throws {
        let expectedUUID = UUID()
        UserDefaults.standard.set(expectedUUID.uuidString, forKey: testKey)
        
        let visitorID = UserDefaultsConcurrency.visitorID()
        
        XCTAssertEqual(visitorID, expectedUUID)
    }
    
    func testVisitorIDCreatesNewWhenNoStoredValue() throws {
        let visitorID = UserDefaultsConcurrency.visitorID()
        
        XCTAssertNotNil(visitorID)
        let storedValue = UserDefaults.standard.string(forKey: testKey)
        XCTAssertEqual(storedValue, visitorID.uuidString)
    }
    
    func testVisitorIDReturnsSameValueOnMultipleCalls() throws {
        let firstCall = UserDefaultsConcurrency.visitorID()
        let secondCall = UserDefaultsConcurrency.visitorID()
        
        XCTAssertEqual(firstCall, secondCall)
    }
    
    func testConcurrentAccessToVisitorIDIsConsistent() async throws {
        let numberOfTasks = 10000
        
        // Use actor to safely collect results
        actor ResultCollector {
            var ids: [UUID] = []
            
            func add(_ id: UUID) {
                ids.append(id)
            }
            
            func getResults() -> [UUID] {
                return ids
            }
        }
        
        let collector = ResultCollector()
        
        // Create many unstructured detached tasks that can truly run in parallel
        let tasks = (1...numberOfTasks).map { _ in
            Task.detached {
                let id = UserDefaultsConcurrency.visitorID()
                await collector.add(id)
            }
        }
        
        // Wait for all to complete
        for task in tasks {
            await task.value
        }
        
        let collectedIDs = await collector.getResults()
        
        // All tasks should have received the same UUID
        let uniqueIDs = Set(collectedIDs)
        print("Collected \(collectedIDs.count) IDs, found \(uniqueIDs.count) unique values")
        
        if uniqueIDs.count > 1 {
            print("⚠️ Race condition detected! Different UUIDs generated:")
            for (index, id) in uniqueIDs.enumerated() {
                let count = collectedIDs.filter { $0 == id }.count
                print("  ID \(index + 1): \(id) (appeared \(count) times)")
            }
        }
        
        XCTAssertEqual(uniqueIDs.count, 1, "Expected all tasks to receive the same visitor ID, but got \(uniqueIDs.count) different IDs")
        
        // Verify the stored value matches
        if let firstID = collectedIDs.first {
            let storedValue = UserDefaults.standard.string(forKey: testKey)
            XCTAssertEqual(storedValue, firstID.uuidString)
        }
    }
}
