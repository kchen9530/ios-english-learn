import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let sampleWord = Word(context: viewContext)
        sampleWord.id = UUID().uuidString
        sampleWord.english = "accomplish"
        sampleWord.chinese = "完成，实现"
        sampleWord.category = "Business"
        sampleWord.difficulty = "Medium"
        sampleWord.example = "She was able to accomplish her goals through hard work."
        sampleWord.dateAdded = Date()

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "VocabularyModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        loadInitialData()
    }
    
    private func loadInitialData() {
        let context = container.viewContext
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                VocabularyData.loadWords(into: context)
                try context.save()
            }
        } catch {
            print("Error loading initial data: \(error)")
        }
    }
}
