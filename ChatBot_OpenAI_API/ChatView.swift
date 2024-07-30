import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    
    init(character: CharacterType) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(character: character))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.messages, id: \.id) { message in
                        HStack {
                            if message.role == .user {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(GlassmorphismCard(color: Color.blue.opacity(0.7)))
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(GlassmorphismCard(color: Color.white.opacity(0.2)))
                                    .cornerRadius(12)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            
            HStack {
                TextField("メッセージを入力", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)
                    .frame(minHeight: CGFloat(40))
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Text("送信")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .opacity(0.8)
                }
                .padding(.trailing, 8)
            }
            .padding(.vertical, 8)
            .background(Color(UIColor.white).opacity(0.8))
            .cornerRadius(12)
            .padding()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.red.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("チャット", displayMode: .inline)
    }
}

#Preview{
    CharacterSelectionView()
}
