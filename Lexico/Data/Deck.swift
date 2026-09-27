import Foundation

struct Deck: Decodable, Identifiable, Hashable {
    let id: String
    let language: String
    let names: [String: String]

    var localizedName: String {
        let code = String((Bundle.main.preferredLocalizations.first ?? "en").split(separator: "-").first ?? "en")
        return names[code] ?? names["en"] ?? id
    }
}
