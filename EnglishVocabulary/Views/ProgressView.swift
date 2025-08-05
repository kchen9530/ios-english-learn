import SwiftUI
import CoreData

struct ProgressView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var userProgress: UserProgress?
    @State private var studiedWordsCount = 0
    @State private var totalWordsCount = 0
    @State private var categoryProgress: [String: Int] = [:]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    streakSection
                    
                    overallStatsSection
                    
                    accuracySection
                    
                    categoryProgressSection
                    
                    achievementsSection
                }
                .padding()
            }
            .navigationTitle("学习进度")
            .onAppear {
                loadProgressData()
            }
        }
    }
    
    private var streakSection: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading) {
                    Text("学习连续天数")
                        .font(.headline)
                    Text("\(userProgress?.streakDays ?? 0) 天")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    private var overallStatsSection: some View {
        VStack(spacing: 15) {
            Text("总体统计")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatCard(
                    title: "已学单词",
                    value: "\(studiedWordsCount)",
                    icon: "book.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "总单词数",
                    value: "\(totalWordsCount)",
                    icon: "books.vertical.fill",
                    color: .green
                )
            }
            
            if totalWordsCount > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("学习进度")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(Double(studiedWordsCount) / Double(totalWordsCount) * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    ProgressView(value: Double(studiedWordsCount), total: Double(totalWordsCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private var accuracySection: some View {
        VStack(spacing: 15) {
            Text("准确率统计")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                StatCard(
                    title: "总准确率",
                    value: String(format: "%.1f%%", (userProgress?.accuracy ?? 0) * 100),
                    icon: "target",
                    color: .purple
                )
                
                StatCard(
                    title: "正确答题",
                    value: "\(userProgress?.totalCorrect ?? 0)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            
            HStack(spacing: 20) {
                StatCard(
                    title: "错误答题",
                    value: "\(userProgress?.totalIncorrect ?? 0)",
                    icon: "xmark.circle.fill",
                    color: .red
                )
                
                StatCard(
                    title: "总答题数",
                    value: "\((userProgress?.totalCorrect ?? 0) + (userProgress?.totalIncorrect ?? 0))",
                    icon: "questionmark.circle.fill",
                    color: .orange
                )
            }
        }
    }
    
    private var categoryProgressSection: some View {
        VStack(spacing: 15) {
            Text("分类进度")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if categoryProgress.isEmpty {
                Text("暂无学习数据")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(categoryProgress.keys.sorted()), id: \.self) { category in
                        HStack {
                            Text(getCategoryDisplayName(category))
                                .font(.body)
                            
                            Spacer()
                            
                            Text("\(categoryProgress[category] ?? 0) 个单词")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var achievementsSection: some View {
        VStack(spacing: 15) {
            Text("成就徽章")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                AchievementBadge(
                    title: "初学者",
                    icon: "star.fill",
                    isUnlocked: studiedWordsCount >= 10,
                    description: "学习10个单词"
                )
                
                AchievementBadge(
                    title: "勤奋学习",
                    icon: "flame.fill",
                    isUnlocked: (userProgress?.streakDays ?? 0) >= 7,
                    description: "连续学习7天"
                )
                
                AchievementBadge(
                    title: "准确射手",
                    icon: "target",
                    isUnlocked: (userProgress?.accuracy ?? 0) >= 0.8,
                    description: "准确率达到80%"
                )
                
                AchievementBadge(
                    title: "词汇大师",
                    icon: "crown.fill",
                    isUnlocked: studiedWordsCount >= 100,
                    description: "学习100个单词"
                )
                
                AchievementBadge(
                    title: "坚持不懈",
                    icon: "calendar",
                    isUnlocked: (userProgress?.streakDays ?? 0) >= 30,
                    description: "连续学习30天"
                )
                
                AchievementBadge(
                    title: "完美主义",
                    icon: "checkmark.seal.fill",
                    isUnlocked: (userProgress?.accuracy ?? 0) >= 0.95,
                    description: "准确率达到95%"
                )
            }
        }
    }
    
    private func loadProgressData() {
        let progressRequest: NSFetchRequest<UserProgress> = UserProgress.fetchRequest()
        let wordsRequest: NSFetchRequest<Word> = Word.fetchRequest()
        let sessionsRequest: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        
        do {
            let progressArray = try viewContext.fetch(progressRequest)
            userProgress = progressArray.first
            
            let allWords = try viewContext.fetch(wordsRequest)
            totalWordsCount = allWords.count
            
            let studySessions = try viewContext.fetch(sessionsRequest)
            studiedWordsCount = Set(studySessions.compactMap { $0.wordId }).count
            
            var categoryCount: [String: Int] = [:]
            for session in studySessions {
                if let wordId = session.wordId,
                   let word = allWords.first(where: { $0.id == wordId }),
                   let category = word.category {
                    categoryCount[category, default: 0] += 1
                }
            }
            categoryProgress = categoryCount
            
        } catch {
            print("Error loading progress data: \(error)")
        }
    }
    
    private func getCategoryDisplayName(_ category: String) -> String {
        switch category {
        case "Business": return "商务"
        case "Academic": return "学术"
        case "Daily Life": return "日常生活"
        case "Technology": return "科技"
        case "Travel": return "旅行"
        default: return category
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let isUnlocked: Bool
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? .yellow : .gray)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .background(isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
