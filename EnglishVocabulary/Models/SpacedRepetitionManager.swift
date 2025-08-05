import Foundation
import CoreData

class SpacedRepetitionManager: ObservableObject {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getWordsForReview() -> [Word] {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        
        do {
            let allWords = try context.fetch(request)
            var wordsForReview: [Word] = []
            
            for word in allWords {
                if shouldReviewWord(word) {
                    wordsForReview.append(word)
                }
            }
            
            return wordsForReview.shuffled()
        } catch {
            print("Error fetching words for review: \(error)")
            return []
        }
    }
    
    private func shouldReviewWord(_ word: Word) -> Bool {
        guard let wordId = word.id else { return true }
        
        let sessionRequest: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        sessionRequest.predicate = NSPredicate(format: "wordId == %@", wordId)
        
        do {
            let sessions = try context.fetch(sessionRequest)
            if let session = sessions.first {
                if let nextReview = session.nextReview {
                    return Date() >= nextReview
                }
            }
            return true
        } catch {
            print("Error checking word review status: \(error)")
            return true
        }
    }
    
    func recordStudyResult(for word: Word, correct: Bool) {
        guard let wordId = word.id else { return }
        
        let sessionRequest: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        sessionRequest.predicate = NSPredicate(format: "wordId == %@", wordId)
        
        do {
            let sessions = try context.fetch(sessionRequest)
            let session: StudySession
            
            if let existingSession = sessions.first {
                session = existingSession
            } else {
                session = StudySession(context: context)
                session.wordId = wordId
                session.easeFactor = 2.5
                session.interval = 1
                session.repetitions = 0
            }
            
            session.lastReviewed = Date()
            
            if correct {
                session.correct += 1
                session.repetitions += 1
                
                if session.repetitions == 1 {
                    session.interval = 1
                } else if session.repetitions == 2 {
                    session.interval = 6
                } else {
                    session.interval = Int32(Float(session.interval) * session.easeFactor)
                }
                
                session.easeFactor = max(1.3, session.easeFactor + (0.1 - (5 - 4) * (0.08 + (5 - 4) * 0.02)))
            } else {
                session.incorrect += 1
                session.repetitions = 0
                session.interval = 1
                session.easeFactor = max(1.3, session.easeFactor - 0.2)
            }
            
            session.nextReview = Calendar.current.date(byAdding: .day, value: Int(session.interval), to: Date())
            
            updateUserProgress(correct: correct)
            try context.save()
            
        } catch {
            print("Error recording study result: \(error)")
        }
    }
    
    private func updateUserProgress(correct: Bool) {
        let progressRequest: NSFetchRequest<UserProgress> = UserProgress.fetchRequest()
        
        do {
            let progressArray = try context.fetch(progressRequest)
            let progress: UserProgress
            
            if let existingProgress = progressArray.first {
                progress = existingProgress
            } else {
                progress = UserProgress(context: context)
                progress.totalWordsStudied = 0
                progress.totalCorrect = 0
                progress.totalIncorrect = 0
                progress.streakDays = 0
            }
            
            progress.totalWordsStudied += 1
            
            if correct {
                progress.totalCorrect += 1
            } else {
                progress.totalIncorrect += 1
            }
            
            let total = progress.totalCorrect + progress.totalIncorrect
            if total > 0 {
                progress.accuracy = Float(progress.totalCorrect) / Float(total)
            }
            
            updateStreak(progress: progress)
            
        } catch {
            print("Error updating user progress: \(error)")
        }
    }
    
    private func updateStreak(progress: UserProgress) {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastStudyDate = progress.lastStudyDate {
            if calendar.isDate(lastStudyDate, inSameDayAs: today) {
                return
            } else if calendar.isDate(lastStudyDate, equalTo: calendar.date(byAdding: .day, value: -1, to: today)!, toGranularity: .day) {
                progress.streakDays += 1
            } else {
                progress.streakDays = 1
            }
        } else {
            progress.streakDays = 1
        }
        
        progress.lastStudyDate = today
    }
}
