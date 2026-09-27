import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Deck") {
                    Picker("Active deck", selection: $viewModel.activeDeckID) {
                        ForEach(viewModel.decks) { deck in
                            Text(deck.localizedName).tag(deck.id)
                        }
                    }
                }
                Section("Daily goal") {
                    Stepper(value: $viewModel.dailyGoal, in: 1...100, step: 1) {
                        LabeledContent("New cards per day", value: "\(viewModel.dailyGoal)")
                    }
                }

                Section {
                    DatePicker("Reminder time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                    ForEach(1...7, id: \.self) { weekday in
                        Button {
                            viewModel.toggleWeekday(weekday)
                        } label: {
                            HStack {
                                Text(weekdayName(weekday))
                                Spacer()
                                if viewModel.weekdays.contains(weekday) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                        .accessibilityAddTraits(viewModel.weekdays.contains(weekday) ? .isSelected : [])
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Choose the days when you want a reminder. Leave all days unchecked to turn reminders off.")
                }
            }
            .navigationTitle("Settings")
            .alert("Reminders unavailable", isPresented: Binding(
                get: { viewModel.notificationError != nil },
                set: { if !$0 { viewModel.notificationError = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.notificationError = nil }
            } message: {
                Text(viewModel.notificationError ?? "")
            }
        }
        .onAppear { viewModel.reschedule() }
    }

    init(viewModel: SettingsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private func weekdayName(_ weekday: Int) -> String {
        Calendar.current.weekdaySymbols[weekday - 1]
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(store: SettingsStore(), reminders: ReminderScheduler()))
}
