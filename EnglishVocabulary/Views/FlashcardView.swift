import SwiftUI

struct FlashcardView: View {
    let word: Word
    let onResult: (Bool) -> Void
    
    @State private var isFlipped = false
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isFlipped ? Color.blue.opacity(0.1) : Color.white)
                .shadow(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.blue, lineWidth: 2)
                )
            
            VStack(spacing: 20) {
                if !isFlipped {
                    VStack(spacing: 15) {
                        Text("英文单词")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(word.english ?? "")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("点击查看中文释义")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                } else {
                    VStack(spacing: 15) {
                        Text(word.english ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Divider()
                        
                        Text(word.chinese ?? "")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        if let example = word.example, !example.isEmpty {
                            Text("例句:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(example)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        if let category = word.category {
                            Text("分类: \(category)")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(30)
        }
        .frame(height: 400)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .offset(dragOffset)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.6)) {
                isFlipped.toggle()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    withAnimation(.spring()) {
                        if abs(value.translation.x) > 100 {
                            if value.translation.x > 0 {
                                onResult(true)
                            } else {
                                onResult(false)
                            }
                        }
                        dragOffset = .zero
                        isFlipped = false
                    }
                }
        )
        
        if isFlipped {
            VStack {
                Spacer()
                
                HStack(spacing: 40) {
                    Button(action: {
                        withAnimation(.spring()) {
                            onResult(false)
                            isFlipped = false
                        }
                    }) {
                        VStack {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.red)
                            Text("困难")
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            onResult(true)
                            isFlipped = false
                        }
                    }) {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                            Text("简单")
                                .font(.caption)
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct FlashcardView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let word = Word(context: context)
        word.english = "accomplish"
        word.chinese = "完成，实现"
        word.category = "Business"
        word.example = "She was able to accomplish her goals through hard work."
        
        return FlashcardView(word: word) { _ in }
            .padding()
    }
}
