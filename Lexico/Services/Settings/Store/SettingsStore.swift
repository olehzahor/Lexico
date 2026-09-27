import Foundation

struct SettingsStore: SettingsStoreProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func get(_ key: SettingKey, default defaultValue: SettingValue) -> SettingValue {
        guard let value = defaults.object(forKey: key.rawValue) else { return defaultValue }
        switch defaultValue {
        case .bool: return (value as? Bool).map(SettingValue.bool) ?? defaultValue
        case .int: return (value as? Int).map(SettingValue.int) ?? defaultValue
        case .string: return (value as? String).map(SettingValue.string) ?? defaultValue
        }
    }

    func set(_ key: SettingKey, value: SettingValue) {
        switch value {
        case let .bool(value): defaults.set(value, forKey: key.rawValue)
        case let .int(value): defaults.set(value, forKey: key.rawValue)
        case let .string(value): defaults.set(value, forKey: key.rawValue)
        }
    }
}
