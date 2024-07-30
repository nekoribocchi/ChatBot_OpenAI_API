import Foundation
import SwiftUI

struct CharacterSelectionView: View {
    @State private var selectedCharacter: CharacterType? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.red.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    Text("どのキャラクターと話す？")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                    
                    Button(action: {
                        selectedCharacter = .cute
                    }) {
                        Text("うさぎちゃん")
                            .font(.headline)
                            .padding()
                            .frame(width: 200)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(20)
                            .foregroundColor(.red)
                            .shadow(color: .pink.opacity(0.3), radius: 10, x: 0, y: 10)
                    }
                    .navigationDestination(isPresented: Binding<Bool>(
                        get: { selectedCharacter == .cute },
                        set: { if !$0 { selectedCharacter = nil } }
                    )) {
                        ChatView(character: .cute)
                    }
                    
                    Button(action: {
                        selectedCharacter = .uncle
                    }) {
                        Text("くまきちさん")
                            .font(.headline)
                            .padding()
                            .frame(width: 200)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(20)
                            .foregroundColor(.purple)
                            .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 10)
                    }
                    .navigationDestination(isPresented: Binding<Bool>(
                        get: { selectedCharacter == .uncle },
                        set: { if !$0 { selectedCharacter = nil } }
                    )) {
                        ChatView(character: .uncle)
                    }
                    
                    Button(action: {
                        selectedCharacter = .cool
                    }) {
                        Text("くじらくん")
                            .font(.headline)
                            .padding()
                            .frame(width: 200)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(20)
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 10)
                    }
                    .navigationDestination(isPresented: Binding<Bool>(
                        get: { selectedCharacter == .cool },
                        set: { if !$0 { selectedCharacter = nil } }
                    )) {
                        ChatView(character: .cool)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview{
    CharacterSelectionView()
}
