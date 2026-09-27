protocol ReminderSchedulingProtocol {
    func schedule(weekdays: Set<Int>, hour: Int, minute: Int) async throws -> Bool
}
