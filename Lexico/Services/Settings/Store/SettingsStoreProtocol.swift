protocol SettingsStoreProtocol {
    func get(_ key: SettingKey, default defaultValue: SettingValue) -> SettingValue
    func set(_ key: SettingKey, value: SettingValue)
}
