enum SettingValue {
    case bool(Bool)
    case int(Int)
    case string(String)

    var bool: Bool? { if case let .bool(value) = self { value } else { nil } }
    var int: Int? { if case let .int(value) = self { value } else { nil } }
    var string: String? { if case let .string(value) = self { value } else { nil } }
}
