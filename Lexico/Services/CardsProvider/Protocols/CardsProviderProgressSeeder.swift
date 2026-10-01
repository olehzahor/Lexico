import Foundation

@MainActor
protocol CardsProviderProgressSeeder: AnyObject {
    func preignoreCards(_ cardIDs: Set<Int>)
}

extension CardsProgressTracker: CardsProviderProgressSeeder {}
