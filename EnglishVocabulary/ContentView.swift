import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            StudyView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("学习")
                }
                .tag(0)
            
            QuizView()
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                    Text("测验")
                }
                .tag(1)
            
            ProgressView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("进度")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear.fill")
                    Text("设置")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
