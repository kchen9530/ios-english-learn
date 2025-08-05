import SwiftUI
import CoreData

struct SpellingQuiz: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var spacedRepetitionManager: SpacedRepetitionManager
    
    @State private var words: [Word] = []
    @State private var currentQuestionIndex = 0
    @State private var userAnswer = ""
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var score = 0
    @State private var quizCompleted = false
    
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
                        
                        Text("拼写测验完成！")
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
                            Text("根据中文释义拼写英文单词:")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            
                            Text(words[currentQuestionIndex].chinese ?? "")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            
                            if let example = words[currentQuestionIndex].example {
                                Text("例句提示:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(example)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(spacing: 15) {
                            TextField("输入英文单词", text: $userAnswer)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title2)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .disabled(showingResult)
                            
                            if showingResult {
                                VStack(spacing: 10) {
                                    HStack {
                                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(isCorrect ? .green : .red)
                                        
                                        Text(isCorrect ? "正确！" : "错误")
                                            .font(.headline)
                                            .foregroundColor(isCorrect ? .green : .red)
                                        
                                        Spacer()
                                    }
                                    
                                    if !isCorrect {
                                        HStack {
                                            Text("正确答案: ")
                                                .font(.body)
                                                .foregroundColor(.secondary)
                                            
                                            Text(words[currentQuestionIndex].english ?? "")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                if showingResult {
                                    nextQuestion()
                                } else {
                                    checkAnswer()
                                }
                            }) {
                                Text(showingResult ? "下一题" : "提交答案")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                            .disabled(userAnswer.isEmpty && !showingResult)
                        }
                        
                        Spacer()
                    }
                } else {
                    ProgressView("加载中...")
                }
            }
            .padding()
            .navigationTitle("拼写测验")
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
        } catch {
            print("Error loading quiz words: \(error)")
        }
    }
    
    private func checkAnswer() {
        guard currentQuestionIndex < words.count else { return }
        
        let correctAnswer = words[currentQuestionIndex].english?.lowercased() ?? ""
        let userAnswerTrimmed = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        isCorrect = userAnswerTrimmed == correctAnswer
        if isCorrect {
            score += 1
        }
        
        spacedRepetitionManager.recordStudyResult(for: words[currentQuestionIndex], correct: isCorrect)
        showingResult = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !isCorrect {
                return
            }
        }
    }
    
    private func nextQuestion() {
        userAnswer = ""
        showingResult = false
        currentQuestionIndex += 1
        
        if currentQuestionIndex >= questionsCount || currentQuestionIndex >= words.count {
            quizCompleted = true
        }
    }
    
    private func getScoreMessage() -> String {
        let percentage = Double(score) / Double(questionsCount) * 100
        
        if percentage >= 90 {
            return "优秀！你的拼写能力很强！"
        } else if percentage >= 70 {
            return "不错！继续练习拼写！"
        } else if percentage >= 50 {
            return "还需要多练习拼写，加油！"
        } else {
            return "需要更多的拼写练习。"
        }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        userAnswer = ""
        showingResult = false
        score = 0
        quizCompleted = false
        loadQuizWords()
    }
}

struct SpellingQuiz_Previews: PreviewProvider {
    static var previews: some View {
        SpellingQuiz()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
