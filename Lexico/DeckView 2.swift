struct DeckView: View {
    private let cardsProvider: CardsProvider
    private let progressTracker: CardsProgressTracker
    
    @State var activeCard: Card?
    
    var body: some View {
        if let activeCard {
            CardView(data: activeCard, progressTracker: progressTracker) {
                self.activeCard = cardsProvider.getNextCard(for: "en")
            }
            .padding()
            .background(Color.appBg)
        } else {
            Text("no cards :(")
        }
    }
    
    init(cardsProvider: CardsProvider, progressTracker: CardsProgressTracker) {
        self.cardsProvider = cardsProvider
        self.progressTracker = progressTracker
        self._activeCard = State(initialValue: cardsProvider.getNextCard(for: "en"))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CardProgress.self, configurations: config)
    let progressTracker = CardsProgressTracker(modelContext: container.mainContext)
    let cardsProvider = CardsProvider(progressManager: progressTracker)

    DeckView(cardsProvider: cardsProvider, progressTracker: progressTracker)
        .modelContainer(container)
}
