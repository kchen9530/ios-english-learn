import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedCategories: Set<String> = []
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    
    private let categories = ["Business", "Academic", "Daily Life", "Technology", "Travel"]
    
    var body: some View {
        NavigationView {
            List {
                Section("学习设置") {
                    NavigationLink(destination: CategorySelectionView(selectedCategories: $selectedCategories)) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.blue)
                            Text("选择学习分类")
                            Spacer()
                            Text("\(selectedCategories.count) 个分类")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        Text("学习提醒")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
                
                Section("数据管理") {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.red)
                            Text("重置学习进度")
                                .foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .foregroundColor(.blue)
                        Text("备份数据")
                        Spacer()
                        Text("iCloud")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("应用信息") {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("关于应用")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("评价应用")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.green)
                        Text("联系我们")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("统计信息") {
                    StatisticRow(title: "应用版本", value: "1.0.0")
                    StatisticRow(title: "词汇总数", value: "\(VocabularyData.words.count)")
                    StatisticRow(title: "支持语言", value: "中文, English")
                }
            }
            .navigationTitle("设置")
            .alert("重置学习进度", isPresented: $showingResetAlert) {
                Button("取消", role: .cancel) { }
                Button("确认重置", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("这将删除所有学习进度和统计数据，此操作不可撤销。")
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .onAppear {
                loadSelectedCategories()
            }
        }
    }
    
    private func loadSelectedCategories() {
        selectedCategories = Set(categories)
    }
    
    private func resetProgress() {
        let progressRequest: NSFetchRequest<UserProgress> = UserProgress.fetchRequest()
        let sessionRequest: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        
        do {
            let progressArray = try viewContext.fetch(progressRequest)
            let sessions = try viewContext.fetch(sessionRequest)
            
            for progress in progressArray {
                viewContext.delete(progress)
            }
            
            for session in sessions {
                viewContext.delete(session)
            }
            
            try viewContext.save()
        } catch {
            print("Error resetting progress: \(error)")
        }
    }
}

struct CategorySelectionView: View {
    @Binding var selectedCategories: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    private let categories = [
        ("Business", "商务", "briefcase.fill"),
        ("Academic", "学术", "graduationcap.fill"),
        ("Daily Life", "日常生活", "house.fill"),
        ("Technology", "科技", "laptopcomputer"),
        ("Travel", "旅行", "airplane")
    ]
    
    var body: some View {
        List {
            Section("选择要学习的分类") {
                ForEach(categories, id: \.0) { category in
                    HStack {
                        Image(systemName: category.2)
                            .foregroundColor(.blue)
                            .frame(width: 25)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.1)
                                .font(.body)
                            Text(category.0)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedCategories.contains(category.0) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedCategories.contains(category.0) {
                            selectedCategories.remove(category.0)
                        } else {
                            selectedCategories.insert(category.0)
                        }
                    }
                }
            }
            
            Section {
                Text("选择你想要学习的词汇分类。你可以随时在设置中修改选择。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("学习分类")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    dismiss()
                }
            }
        }
    }
}

struct StatisticRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("English Vocabulary")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("版本 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 20) {
                    Text("一款专为中文用户设计的英语词汇学习应用")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        FeatureRow(icon: "brain.head.profile", text: "智能间隔重复算法")
                        FeatureRow(icon: "rectangle.stack.fill", text: "互动式抽认卡学习")
                        FeatureRow(icon: "questionmark.circle.fill", text: "多样化测验模式")
                        FeatureRow(icon: "chart.bar.fill", text: "详细学习统计")
                        FeatureRow(icon: "star.fill", text: "成就系统激励")
                    }
                }
                
                Spacer()
                
                Text("© 2024 English Vocabulary App")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
