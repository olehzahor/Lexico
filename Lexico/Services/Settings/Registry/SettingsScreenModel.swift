import SwiftUI

struct SettingsSectionModel: Identifiable {
    let id: String
    let title: String?
    let footer: String?
    let items: [SettingsItemModel]
}

struct SettingsOption: Identifiable {
    let value: String
    let title: String
    var id: String { value }
}

enum SettingsItemModel: Identifiable {
    case toggle(title: String, subtitle: String?, key: SettingKey, defaultValue: Bool)
    case stepper(title: String, subtitle: String?, key: SettingKey, defaultValue: Int, range: ClosedRange<Int>, step: Int)
    case picker(title: String, subtitle: String?, key: SettingKey, defaultValue: String, options: [SettingsOption])
    case group(id: String, title: String, subtitle: String?, sections: [SettingsSectionModel])
    case action(id: String, title: String, role: ButtonRole?, action: () -> Void)

    var id: String {
        switch self {
        case let .toggle(_, _, key, _), let .stepper(_, _, key, _, _, _), let .picker(_, _, key, _, _): key.rawValue
        case let .group(id, _, _, _), let .action(id, _, _, _): id
        }
    }
}
