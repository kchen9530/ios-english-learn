import SwiftUI
import CoreData

struct StudyView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var spacedRepetitionManager: SpacedRepetitionManager
    @State private var wordsToReview: [Word] = []
    @State private var currentWordIndex = 0
    @State private var showingFlashcard = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        self._spacedRepetitionManager = StateObject(wrappedValue: SpacedRepetitionManager(context: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if wordsToReview.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("太棒了！")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("今天没有需要复习的单词")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button("开始学习新单词") {
                            loadNewWords()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack(spacing: 15) {
                        HStack {
                            Text("进度")
                                .font(.headline)
                            Spacer()
                            Text("\(currentWordIndex + 1) / \(wordsToReview.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: Double(currentWordIndex + 1), total: Double(wordsToReview.count))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        if currentWordIndex < wordsToReview.count {
                            FlashcardView(
                                word: wordsToReview[currentWordIndex],
                                onResult: handleStudyResult
                            )
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("学习")
            .onAppear {
                loadWordsForReview()
            }
        }
    }
    
    private func loadWordsForReview() {
        wordsToReview = spacedRepetitionManager.getWordsForReview()
        currentWordIndex = 0
    }
    
    private func loadNewWords() {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.fetchLimit = 10
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Word.dateAdded, ascending: true)]
        
        do {
            let newWords = try viewContext.fetch(request)
            wordsToReview = newWords
            currentWordIndex = 0
        } catch {
            print("Error loading new words: \(error)")
        }
    }
    
    private func handleStudyResult(correct: Bool) {
        if currentWordIndex < wordsToReview.count {
            spacedRepetitionManager.recordStudyResult(for: wordsToReview[currentWordIndex], correct: correct)
            
            if currentWordIndex < wordsToReview.count - 1 {
                currentWordIndex += 1
            } else {
                wordsToReview.removeAll()
                currentWordIndex = 0
            }
        }
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
