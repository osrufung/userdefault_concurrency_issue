import Foundation

public struct UserDefaultsConcurrency {
    public init() {}
    
    private enum UserDefaultKeys {
        static let visitorIDKey = "visitor_id"
    }
    
    public static func setVisitorID(_ uuid: UUID) {
        UserDefaults.standard.set(
            uuid.uuidString,
            forKey: UserDefaultKeys.visitorIDKey
        )
    }
    
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
}
