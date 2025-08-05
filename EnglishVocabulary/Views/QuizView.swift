import SwiftUI
import CoreData

struct QuizView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedQuizType: QuizType = .multipleChoice
    @State private var showingQuiz = false
    
    enum QuizType: String, CaseIterable {
        case multipleChoice = "选择题"
        case spelling = "拼写题"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("选择测验类型")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("通过测验来检验你的学习成果")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 15) {
                    ForEach(QuizType.allCases, id: \.self) { quizType in
                        Button(action: {
                            selectedQuizType = quizType
                            showingQuiz = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(quizType.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(quizType == .multipleChoice ? "从四个选项中选择正确答案" : "根据中文释义拼写英文单词")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("测验")
            .sheet(isPresented: $showingQuiz) {
                if selectedQuizType == .multipleChoice {
                    MultipleChoiceQuiz()
                } else {
                    SpellingQuiz()
                }
            }
        }
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
