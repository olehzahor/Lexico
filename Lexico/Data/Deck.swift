import Foundation

struct Deck: Decodable, Identifiable, Hashable {
    let id: String
    let language: String
    let leveled: Bool
    let names: [String: String]

    private enum CodingKeys: String, CodingKey {
        case id
        case language
        case leveled
        case names
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        language = try values.decode(String.self, forKey: .language)
        leveled = try values.decodeIfPresent(Bool.self, forKey: .leveled) ?? false
        names = try values.decode([String: String].self, forKey: .names)
    }

    var localizedName: String {
        let code = String((Bundle.main.preferredLocalizations.first ?? "en").split(separator: "-").first ?? "en")
        return names[code] ?? names["en"] ?? id
    }
}
