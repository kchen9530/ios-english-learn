import SwiftUI
import CoreData

struct MultipleChoiceQuiz: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var spacedRepetitionManager: SpacedRepetitionManager
    
    @State private var words: [Word] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showingResult = false
    @State private var score = 0
    @State private var quizCompleted = false
    @State private var options: [String] = []
    @State private var correctAnswerIndex = 0
    
    private let questionsCount = 10
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        self._spacedRepetitionManager = StateObject(wrappedValue: SpacedRepetitionManager(context: context))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if quizCompleted {
                    VStack(spacing: 20) {
                        Image(systemName: score >= 7 ? "star.fill" : "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(score >= 7 ? .yellow : .green)
                        
                        Text("测验完成！")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("得分: \(score)/\(questionsCount)")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text(getScoreMessage())
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("重新测验") {
                            restartQuiz()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("返回") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                    }
                } else if !words.isEmpty && currentQuestionIndex < words.count {
                    VStack(spacing: 20) {
                        HStack {
                            Text("问题 \(currentQuestionIndex + 1)/\(questionsCount)")
                                .font(.headline)
                            Spacer()
                            Text("得分: \(score)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questionsCount))
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        
                        VStack(spacing: 15) {
                            Text("选择正确的中文释义:")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text(words[currentQuestionIndex].english ?? "")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(0..<options.count, id: \.self) { index in
                                Button(action: {
                                    selectedAnswer = index
                                    showingResult = true
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        nextQuestion()
                                    }
                                }) {
                                    HStack {
                                        Text(options[index])
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding()
                                    .background(getButtonColor(for: index))
                                    .foregroundColor(getTextColor(for: index))
                                    .cornerRadius(12)
                                }
                                .disabled(showingResult)
                            }
                        }
                        
                        Spacer()
                    }
                } else {
                    ProgressView("加载中...")
                }
            }
            .padding()
            .navigationTitle("选择题测验")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadQuizWords()
            }
        }
    }
    
    private func loadQuizWords() {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.fetchLimit = questionsCount
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Word.dateAdded, ascending: false)]
        
        do {
            words = try viewContext.fetch(request).shuffled()
            if !words.isEmpty {
                generateOptions()
            }
        } catch {
            print("Error loading quiz words: \(error)")
        }
    }
    
    private func generateOptions() {
        guard currentQuestionIndex < words.count else { return }
        
        let currentWord = words[currentQuestionIndex]
        let correctAnswer = currentWord.chinese ?? ""
        
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            let allWords = try viewContext.fetch(request)
            let wrongAnswers = allWords
                .filter { $0.chinese != correctAnswer }
                .shuffled()
                .prefix(3)
                .compactMap { $0.chinese }
            
            var allOptions = Array(wrongAnswers) + [correctAnswer]
            allOptions.shuffle()
            
            options = allOptions
            correctAnswerIndex = options.firstIndex(of: correctAnswer) ?? 0
        } catch {
            print("Error generating options: \(error)")
        }
    }
    
    private func getButtonColor(for index: Int) -> Color {
        if !showingResult {
            return Color.gray.opacity(0.1)
        }
        
        if index == correctAnswerIndex {
            return Color.green.opacity(0.3)
        } else if index == selectedAnswer {
            return Color.red.opacity(0.3)
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private func getTextColor(for index: Int) -> Color {
        if !showingResult {
            return .primary
        }
        
        if index == correctAnswerIndex {
            return .green
        } else if index == selectedAnswer {
            return .red
        } else {
            return .primary
        }
    }
    
    private func nextQuestion() {
        let isCorrect = selectedAnswer == correctAnswerIndex
        if isCorrect {
            score += 1
        }
        
        spacedRepetitionManager.recordStudyResult(for: words[currentQuestionIndex], correct: isCorrect)
        
        selectedAnswer = nil
        showingResult = false
        currentQuestionIndex += 1
        
        if currentQuestionIndex >= questionsCount || currentQuestionIndex >= words.count {
            quizCompleted = true
        } else {
            generateOptions()
        }
    }
    
    private func getScoreMessage() -> String {
        let percentage = Double(score) / Double(questionsCount) * 100
        
        if percentage >= 90 {
            return "优秀！你的词汇掌握得很好！"
        } else if percentage >= 70 {
            return "不错！继续努力学习！"
        } else if percentage >= 50 {
            return "还需要多练习，加油！"
        } else {
            return "需要更多的学习和练习。"
        }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        selectedAnswer = nil
        showingResult = false
        score = 0
        quizCompleted = false
        loadQuizWords()
    }
}

struct MultipleChoiceQuiz_Previews: PreviewProvider {
    static var previews: some View {
        MultipleChoiceQuiz()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
